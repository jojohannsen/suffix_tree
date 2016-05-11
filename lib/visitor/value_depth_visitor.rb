require_relative '../node'

class ValueDepthVisitor < BaseVisitor
  def initialize
    super
  end

  def preVisit(node)
    if (node.isInternal) then
      node.valueDepth = node.parent.valueDepth + node.incomingEdgeLength
    elsif (node.isLeaf) then
      node.valueDepth = Node::LEAF_DEPTH
    end
    return true
  end
end


class DeepestValueDepthVisitor < BaseVisitor
  attr_reader :deepestValueDepth, :deepestValueDepthNode

  def initialize
    @deepestValueDepthNode = nil
    @deepestValueDepth = 0
    super
  end

  def postVisit(node)
    if (node.valueDepth > @deepestValueDepth) then
      @deepestValueDepth = node.valueDepth
      @deepestValueDepthNode = node
    end
  end
end