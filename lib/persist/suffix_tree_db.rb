require_relative '../node'

class SuffixTreeDB
  def initialize(textFile)
    @textFile = File.open(textFile, "w")
    @dataValues = []
    @dataValueIdx = 0
  end

  def val(node)
    if (node == nil) then
      return 0
    else
      return node.nodeId
    end
  end

  def persist(node)
    @textFile.print "#{node.nodeId} #{val(node.parent)} #{node.incomingEdgeStartOffset} #{node.incomingEdgeEndOffset} #{node.suffixOffset} #{val(node.suffixLink)}"
    if (node.children != nil) then
      node.children.values.each do |childNode|
        @textFile.print " #{childNode.nodeId}"
      end
    end
    @textFile.print " 0\n"
  end

  def readInt()
    if (@dataValueIdx >= @dataValues.length) then
      if (@textFile.eof?) then
        return 0
      end
      line = @textFile.readline()
      if (line == nil) then
        return 0
      else
        line.chomp!
        @dataValueIdx = 0
        @dataValues = line.split
      end
    end

    result = @dataValues[@dataValueIdx].to_i
    @dataValueIdx += 1
    return result
  end
end

class SuffixTreeBuilder
  attr_reader :suffixCount

  def initialize(stdb, dataSource)
    @suffxTreeDB = stdb
    @dataSource = dataSource
    @root = nil
    @unresolvedParents = {}
    @unresolvedSuffixLinks = {}
    @unresolvedChildren = {}
    @allNodes = {}
  end

  def buildNode
    nodeId = @suffxTreeDB.readInt()
    if (nodeId > 0) then
      node = resolveNodeId(nodeId)
      resolve(nodeId, node)
      @allNodes[nodeId] = node
      @root = node if (@root == nil)
      resolveParent(node, @suffxTreeDB.readInt())
      node.incomingEdgeStartOffset = @suffxTreeDB.readInt()
      node.incomingEdgeEndOffset = @suffxTreeDB.readInt()
      @suffixCount = node.suffixOffset = @suffxTreeDB.readInt()
      resolveSuffixLink(node, @suffxTreeDB.readInt())
      childNodeId = @suffxTreeDB.readInt()
      while (childNodeId != 0) do
        resolveChild(node, childNodeId)
        childNodeId = @suffxTreeDB.readInt()
      end
      return node
    end
    return false
  end

  private

  def resolveParent(node, nodeId)
    if (@allNodes.has_key?(nodeId)) then
      node.parent = @allNodes[nodeId]
    else
      resolveEntry(node, nodeId, @unresolvedParents)
    end
  end

  def resolveSuffixLink(node, nodeId)
    if (@allNodes.has_key?(nodeId)) then
      node.suffixLink = @allNodes[nodeId]
    else
      resolveEntry(node, nodeId, @unresolvedSuffixLinks)
    end
  end

  def resolveChild(node, nodeId)
    if (@allNodes.has_key?(nodeId)) then
      childNode = @allNodes[nodeId]
      if (node.children == nil) then
        node.children = {}
      end
      node.children[@dataSource.valueAt(childNode.incomingEdgeStartOffset)] = childNode
    else
      resolveEntry(node, nodeId, @unresolvedChildren)
    end
  end

  def resolveEntry(node, nodeId, theList)
    if (nodeId > 0) then
      theList[nodeId] = node
    end
  end

  def resolveNodeId(nodeId)
    if @allNodes.has_key?(nodeId) then
      @allNodes[nodeId]
    else
      Node.new(nodeId)
    end
  end

  def resolve(nodeId, node)
    if (@unresolvedParents.has_key?(nodeId)) then
      print "Unresolved parent value #{nodeId}\n"
      @unresolvedParents[nodeId].parent = node
      @unresolvedParents.delete(nodeId)
    end
    if (@unresolvedChildren.has_key?(nodeId) && (node.incomingEdgeStartOffset >= 0)) then
      unfinishedNode = @unresolvedChildren[nodeId]
      if (unfinishedNode.children == nil) then
        unfinishedNode.children = {}
      end
      unfinishedNode.children[@dataSource.valueAt(node.incomingEdgeStartOffset)] = node
      @unresolvedChildren.delete(nodeId)
    end
    if (@unresolvedSuffixLinks.has_key?(nodeId)) then
      unfinishedNode = @unresolvedSuffixLinks[nodeId]
      unfinishedNode.suffixLink = node
      @unresolvedSuffixLinks.delete(nodeId)
    end
  end
end