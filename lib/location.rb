require_relative 'node'

#
#  This class keeps track of the next value to check in a suffix tree
#
#  If we are located at a node, there are several options for the next value
#  which are in the map of value-to-node.
#
#  If we are not on a node, there is an incoming edge with at least one value
#  so we store the offset of that value in the data source
#
#  The location can never be onNode at a leaf, but can be at a leaf with
#  an incomingEdgeOffset at or past the leaf's incomingEdgeStartOffset
#
class Location
  attr_reader :node, :onNode, :incomingEdgeOffset

  #
  #  optional parameters needed for testing
  #
  def initialize(node, onNode = true, incomingEdgeOffset = Node::UNSPECIFIED_OFFSET)
    @node = node
    @onNode = onNode
    @incomingEdgeOffset = incomingEdgeOffset
  end

  #
  #  traverse to parent, return the range of characters covered
  #
  def traverseUp
    incomingEdgeStart = @node.incomingEdgeStartOffset
    if (@onNode) then
      incomingEdgeEnd = @node.incomingEdgeEndOffset
    else
      incomingEdgeEnd = @incomingEdgeOffset - 1
    end
    @node = @node.parent
    @incomingEdgeOffset = Node::UNSPECIFIED_OFFSET
    @onNode = true
    return incomingEdgeStart, incomingEdgeEnd
  end

  def traverseSuffixLink
    self.jumpToNode(@node.suffixLink)
  end

  #
  #  From the current Node with a given child value, traverse past that value
  #
  def traverseDownChildValue(value)
    @node = @node.children[value]
    if (@node.incomingEdgeLength == 1) then
      @onNode = true
      @incomingEdgeOffset = Node::UNSPECIFIED_OFFSET
    else
      @onNode = false
      @incomingEdgeOffset = @node.incomingEdgeStartOffset + 1
    end
  end

  #
  #  From the current location that does NOT have a suffix link, either because it
  #  is on an edge or because it is on a newly created internal node, traverse
  #  to the next suffix
  #
  #  Returns true if it actually traversed, otherwise false
  #
  def traverseToNextSuffix(dataSource)
    if (@node.isRoot) then
      return false
    end
    upStart, upEnd = self.traverseUp
    if (@node.isRoot) then
      if (upStart < upEnd) then
        self.traverseSkipCountDown(dataSource, upStart + 1, upEnd)
      else
        @onNode = true
      end
    else
      @node = @node.suffixLink
      self.traverseSkipCountDown(dataSource, upStart, upEnd)
    end
    return true
  end

  #
  #  From the current location on a Node, traverse down assuming the characters
  #  on the path exist, which allows skip/count method to be used to move down.
  #
  def traverseSkipCountDown(dataSource, startOffset, endOffset)
    done = false
    while (!done) do
      @node = @node.children[dataSource.valueAt(startOffset)]
      if (@node.isLeaf) then
        @onNode = false
        @incomingEdgeOffset = @node.incomingEdgeStartOffset + (endOffset - startOffset + 1)
      else
        incomingEdgeLength = @node.incomingEdgeLength
        startOffset += incomingEdgeLength
        remainingLength = endOffset - startOffset + 1
        @onNode = (remainingLength == 0)
        # if remaining length is negative, it means we have past where we need to be
        # by that amount, incoming edge offset is set to end reduced by that amount
        if (remainingLength < 0) then
          @incomingEdgeOffset = @node.incomingEdgeEndOffset + remainingLength + 1
        else
          @incomingEdgeOffset = @node.incomingEdgeStartOffset
        end
      end

      done = (@node.isLeaf || (remainingLength <= 0))
    end
  end

  def traverseDownEdgeValue()
    @incomingEdgeOffset += 1
    if (!@node.isLeaf && (@incomingEdgeOffset > @node.incomingEdgeEndOffset)) then
      @onNode = true
    end
  end

  def matchDataSource(dataSource, matchThis)
    matchThis.each_with_index do |value, index|
      if (!self.matchValue(dataSource, value)) then
        break
      end
    end
    self
  end

  def matchValue(dataSource, value)
    if (@onNode) then
      if (@node.children.has_key?(value)) then
        self.traverseDownChildValue(value)
        return true
      end
    else
      if (dataSource.valueAt(@incomingEdgeOffset) == value) then
        self.traverseDownEdgeValue()
        return true
      end
    end
    return false
  end

  #
  #  get the depth of the location
  #
  #  Requires nodes with "valueDepth" property (nodeFactory with :valueDepth=>true, followed by traversal with ValueDepthVisitor)
  #
  def depth
    if (@onNode) then
      return @node.valueDepth
    else
      return @node.parent.valueDepth + @incomingEdgeOffset - @node.incomingEdgeStartOffset
    end
  end

  def jumpToNode(node)
    @node = node
    @onNode = true
    @incomingEdgeOffset = Node::UNSPECIFIED_OFFSET
  end

end