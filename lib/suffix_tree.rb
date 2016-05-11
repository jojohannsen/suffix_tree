require_relative 'location'
require_relative 'node_factory'
require_relative 'suffix_linker'

#
# Builds a suffix tree from one or more DataSource instances
#
class SuffixTree
  NO_SUFFIX_OFFSET = -1

  # first data source we use
  attr_reader :rootDataSource

  # when there are a sequence of data sources, treat them as one long one, this is where next source starts
  attr_reader :startOffset

  # where we are in the implicit tree building process
  attr_reader :location

  attr_reader :nodeFactory

  # the root of the tree, and the terminal value (for making implicit trees explicit)
  attr_reader :root, :terminalValue

  # keep track of which nodes need suffix links
  attr_reader :suffixLinker

  def initialize(terminalValue = nil, configuration = nil, persister = nil)
    @nextNodeId = 0
    @nodeFactory = NodeFactory.new(nil, persister)
    @nodeFactory.setConfiguration(configuration) if (configuration != nil)
    @root = @nodeFactory.newRoot()
    @rootDataSource = nil
    @location = Location.new(@root)
    @startOffset = 0
    @suffixOffset = 0
    @suffixLinker = SuffixLinker.new
    @terminalValue = terminalValue
  end

  #
  #  Set the data source, but do not add any values from the data source
  #
  def setDataSource(dataSource)
    if (@rootDataSource == nil) then
      @rootDataSource = dataSource
    end
    @nodeFactory.extendDataSource(dataSource, @startOffset)
  end

  #
  #  Add all values in a given dataSource
  #
  def addDataSource(dataSource)
    @suffixOffset = 0
    self.setDataSource(dataSource)
    dataSource.each_with_index(@startOffset) do |value, offset|
      self.addValue(value, offset)
    end
    if (@terminalValue != nil) then
      @lastOffsetAdded += 1
      self.addValue(@terminalValue, @lastOffsetAdded)
    end
    @startOffset = @lastOffsetAdded + 1
  end

  #
  #  Adding one value at a time, rootDataSource must be set for this to work
  #
  def addValue(value, offset)
    while (extend(value, offset)) do
      @suffixLinker.update(@location)
    end
    @lastOffsetAdded = offset
  end

  #
  #  Finish building the tree by adding a value that is not part of the data source
  #
  def finish()
    if (@rootDataSource.has_terminator?) then
      self.addValue(@rootDataSource.terminator, @startOffset)
    end
  end

  #
  #  Extend a single suffix at the current location, returns true if there is another
  #  suffix to extend.
  #
  #  Handles these cases:
  #
  #     On a node:
  #        if there is a child starting with the extension value, traverse down that one value, return FALSE
  #        if no child has the extension value, add a leaf,
  #            if we are at root, return FALSE,
  #            otherwise traverse to the next suffix and return TRUE
  #
  #     On an edge:
  #        if next character has the value, traverse past it, return FALSE
  #        if next character is not the value, split edge at that location, locate at the new node, and return TRUE
  #
  def extend(value,offset)
    if (@location.onNode)
      if (@location.node.children.has_key?(value)) then
        @location.traverseDownChildValue(value)
        return false  # rule 3
      else
        @nodeFactory.addLeaf(@location.node, value, offset)
        return @location.traverseToNextSuffix(@rootDataSource)  # rule 1, traverse returns false when at root
      end
    elsif (@rootDataSource.valueAt(@location.incomingEdgeOffset) == value) then
      @location.traverseDownEdgeValue()
      return false   # found value on edge, rule 3
    else
      newNode = @nodeFactory.splitEdgeAt(@location.node, @location.incomingEdgeOffset)
      @suffixLinker.nodeNeedingSuffixLink(newNode)
      @location.jumpToNode(newNode)
      return true   # rule 2
    end
  end

end