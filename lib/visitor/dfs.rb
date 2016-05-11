class DFS
  def initialize(visitor)
    @visitor = visitor
  end

  def traverseChildren(children)
    if (children != nil)
      children.each do |key,value|
        self.traverse(value)
      end
    end
  end

  def traverse(node)
    if (@visitor.preVisit(node)) then
      self.traverseChildren(node.children)
      @visitor.postVisit(node)
    end
  end
end

class OrderedDFS < DFS
  def initialize(visitor)
    super(visitor)
  end

  def traverseChildren(children)
    if (children != nil)
      children.keys.sort.each do |key|
        self.traverse(children[key])
      end
    end
  end
end