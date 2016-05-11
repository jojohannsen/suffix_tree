#
#  Only makes sense from OrderedDFS
#
class SuffixOffsetVisitor

  attr_reader :result

  def initialize
    @result = []
  end

  def preVisit(node)
    if (node.isLeaf) then
      @result << node.suffixOffset
    end
    return true
  end

  def postVisit(node)
    # do nothing
  end

end