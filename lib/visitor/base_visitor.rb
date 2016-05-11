class BaseVisitor
  attr_accessor :preCounter, :postCounter

  def initialize
    @preCounter = 0
    @postCounter = 0
  end

  def preVisit(node)
    @preCounter += 1
    return true
  end

  def postVisit(node)
    @postCounter += 1
  end
end