require_relative 'base_visitor'

class DataSourceVisitor < BaseVisitor
  def initialize
    super
  end

  def postVisit(node)
    if (node.children != nil) then
      node.children.values.each do |child|
        node.dataSourceBit |= child.dataSourceBit
      end
    end
  end
end