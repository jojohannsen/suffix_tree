class Node
  # Leaf nodes use this due to Rule 1: once a leaf, always a leaf
  CURRENT_ENDING_OFFSET = -1

  # Root uses this, it has no incoming edge, yet as a Node has incoming edge offset properties
  UNSPECIFIED_OFFSET = -2

  # Leaf nodes get special depth, since they vary as characters get added
  LEAF_DEPTH = -3

  attr_accessor :incomingEdgeStartOffset, :incomingEdgeEndOffset, :suffixOffset
  attr_accessor :parent, :suffixLink, :children
  attr_reader :nodeId

  def initialize(nodeId, suffixOffset = UNSPECIFIED_OFFSET)
    @nodeId = nodeId
    @incomingEdgeStartOffset = UNSPECIFIED_OFFSET
    @incomingEdgeEndOffset = UNSPECIFIED_OFFSET
    @suffixOffset = suffixOffset

    @parent = nil
    @suffixLink = nil
    @children = nil
  end

  def isRoot
    return @parent == nil
  end

  def isLeaf
    return @incomingEdgeEndOffset == CURRENT_ENDING_OFFSET
  end

  def isInternal
    return !isLeaf && !isRoot
  end

  def incomingEdgeLength
    return @incomingEdgeEndOffset - @incomingEdgeStartOffset + 1
  end

  #
  #  some algorithms require additional accessors, allow these to be created dynamically
  #
  def createAccessor(name)
    self.class.send(:attr_accessor, name)
  end

  #
  #  suffix offset enumerator (not sure this belongs here)
  #
  def each_suffix
    if (self.isLeaf) then
      yield suffixOffset
    else
      children.keys.sort.each do |key|
        children[key].each_suffix do |suffixOffset|
          yield suffixOffset
        end
      end
    end
  end
end