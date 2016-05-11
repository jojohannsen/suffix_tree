class BFS
  def initialize(visitor)
    @visitor = visitor
    @q = Array.new
  end

  def traverse(node)
    @q.unshift(node)

    while (@q.size > 0) do
      node = @q.pop
      if (@visitor.preVisit(node)) then
        if (node.children != nil)  then
          node.children.values.each do |child|
            @q.unshift(child)
          end
        end
      end
    end

  end
end