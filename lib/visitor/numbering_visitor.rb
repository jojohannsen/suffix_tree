require_relative '../node'
require_relative 'base_visitor'

# monkey patching dfsNumber and numberNodesInSubtree
module NodeExtensions
  # set by first pass traversal with NumberingVisitor
  attr_accessor :dfsNumber

  # numberNodesInSubtree detects proper ancestor of two nodes, where ancestor is lca
  # binaryTreeHeight is required for building runs
  attr_accessor :numberNodesInSubtree, :binaryTreeHeight

  # set by second pass traversal with IvVisitor, a run is the path with a single
  # (lowest in tree) node with the greatest binaryTreeHeight.  runHead and runTail
  # are the nodes that span the run.
  attr_accessor :runHead, :runTail

  # set by third pass with RunBitVisitor, sets bits for each ancestor run
  attr_accessor :runBits
end

class Node
  prepend NodeExtensions
end

class BitUtil
  def initialize
    @masks = [ 0xffff, 0xff ]
    @rightTable = [ 0 ]
    @leftTable = [ 0 ]

    (1..255).each do |val|
      @rightTable << rightOneBit(val)
      @leftTable << leftOneBit(val)
    end
  end

  def rightBit(n)
    shiftCount, n = shiftToByteRight(n)
    @rightTable[n & 0xff] + shiftCount
  end

  def leftBit(n)
    shiftCount, n = shiftToByteLeft(n)
    @leftTable[n & 0xff] + shiftCount
  end

  def bitGreaterThanOrEqualTo(startOffset, v1, v2)
    map = (1 << (startOffset - 1))
    while (startOffset < 64) do
      if (((v1 & map) != 0) && ((v2 & map) != 0)) then
        return startOffset
      else
        startOffset += 1
        map = map << 1
      end
    end
  end

  def leftMostBitToRightOf(bitNumber, n)
    mask = getMask(bitNumber + 1)
    return leftBit(n & mask)
  end

  private

  def getMask(bitNumber)
    # assume 64 bit numbers
    0xffffffffffffffff >> bitNumber
  end

  def shiftToByteRight(n)
    shiftCount = 0
    if ((n & 0xffffffff) == 0) then
      n = n >> 32
      shiftCount += 32
    end
    if ((n & 0xffff) == 0) then
      n = n >> 16
      shiftCount += 16
    end
    if ((n & 0xff) == 0) then
      n = n >> 8
      shiftCount += 8
    end
    return shiftCount, n
  end

  def shiftToByteLeft(n)
    shiftCount = 0
    if ((n & 0xffffffff00000000) != 0) then
      n = n >> 32
      shiftCount += 32
    end
    if ((n & 0xffff0000) != 0) then
      n = n >> 16
      shiftCount += 16
    end
    if ((n & 0xff00) != 0) then
      n = n >> 8
      shiftCount += 8
    end
    return shiftCount, n
  end

  def rightOneBit(n)
    mask = 1
    result = 1
    while ((n & mask) == 0) do
      mask = mask << 1
      result += 1
    end
    return result
  end

  def leftOneBit(n)
    mask = 1 << 7
    result = 8
    while ((n & mask) == 0) do
      mask = mask >> 1
      result -= 1
    end
    return result
  end
end

# use BaseVisitor counters to set the values
class NumberingVisitor < BaseVisitor
  def initialize
    @bitCalculator = BitUtil.new
    super
  end

  def preVisit(node)
    super(node)
    node.dfsNumber = @preCounter
    node.binaryTreeHeight = @bitCalculator.rightBit(@preCounter)
    return true
  end

  def postVisit(node)
    node.numberNodesInSubtree = @preCounter - node.dfsNumber + 1
  end
end

# set the height of the complete binary tree node that each node maps to
class RunDefiningVisitor
  def preVisit(node)
    # every node gets the runTail set correctly
    # runHead is ONLY valid in the runTail node
    node.runHead = node.runTail = node
    parentDfsNumber = 0
    parentDfsNumber = node.parent.dfsNumber if (node.parent != nil)
    return true
  end

  def postVisit(node)
    # the child with a greatest binaryTreeHeight larger than the current node's binaryTreeHeight
    # is the runTail, the current node is the runHead (which we need to set in runTail)
    if (node.children != nil) then
      maxBinaryTreeHeight = node.binaryTreeHeight
      maxBinaryTreeHeightNode = nil
      node.children.values.each do |child|
        if (child.runTail.binaryTreeHeight > maxBinaryTreeHeight) then
          maxBinaryTreeHeight = child.runTail.binaryTreeHeight
          maxBinaryTreeHeightNode = child
        end
      end
      if (maxBinaryTreeHeightNode != nil) then
        node.runTail = maxBinaryTreeHeightNode.runTail

        # runHead is ONLY valid in the runTail node,
        # the alternative is to traverse from runTail to node whenever runHead changes
        # (or to do this only on final change)
        node.runTail.runHead = node
      end
    end
  end
end

class RunBitVisitor
  def initialize(startNode)
    startNode.runBits = 0
  end

  def preVisit(node)
    if (node.parent != nil) then
      node.runBits = node.parent.runBits
    end
    node.runBits = node.runBits | getBit(node.runTail.binaryTreeHeight)
    return true
  end

  def postVisit(node)
  end

  private
  def getBit(n)
    1 << (n-1)
  end
end

class LeafNodeCollector
  attr_reader :suffixToLeaf

  def initialize
    @suffixToLeaf = {}
  end

  def preVisit(node)
    if (node.children == nil) then
      @suffixToLeaf[node.suffixOffset] = node
    end
    return true
  end

  def postVisit(node)
  end
end

class LeastCommonAncestorPreprocessing
  def initialize(startNode)
    dfs = OrderedDFS.new(NumberingVisitor.new)
    dfs.traverse(startNode)
    dfs = OrderedDFS.new(RunDefiningVisitor.new)
    dfs.traverse(startNode)
    dfs = DFS.new(RunBitVisitor.new(startNode))
    dfs.traverse(startNode)
  end
end