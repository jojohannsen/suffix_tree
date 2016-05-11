require_relative 'base_visitor'

class LeafCountVisitor < BaseVisitor
  def initialize
    super
  end

  def postVisit(node)
    if (node.children != nil) then
      node.children.values.each do |child|
        node.leafCount += child.leafCount
      end
    end
  end
end
