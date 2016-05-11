class TreePrintVisitor
  ALL_LEVELS = -1

  def initialize(dataSource, io, level=ALL_LEVELS)
    @indentation = 0
    @dataSource = dataSource
    @io = io
    @level = level
  end

  def nodeToStr(node)
    if (node.isRoot) then
      "ROOT"
    else
      "#{@dataSource.toString(node.incomingEdgeStartOffset, node.incomingEdgeEndOffset)}"
    end
  end

  def preVisit(node)
    @io.print "#{" "*@indentation}#{self.nodeToStr(node)}\n"
    if (@level == ALL_LEVELS) || (@indentation < @level) then
      @indentation += 1
      return true
    else
      return false
    end
  end

  def postVisit(node)
    @indentation -= 1
  end
end

class DfsTreePrintVisitor < TreePrintVisitor
  def nodeToStr(node)
    "#{node.dfsNumber} #{node.suffixOffset}, #{node.runTail.binaryTreeHeight}/#{node.runTail.dfsNumber} #{super}"
  end
end

class BasicDfsTreePrintVisitor < TreePrintVisitor
  def nodeToStr(node)
    "#{node.dfsNumber} #{node.suffixOffset}, #{super}"
  end
end