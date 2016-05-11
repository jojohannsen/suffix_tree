require 'rspec'
require_relative '../lib/location'
require_relative '../lib/node'
require_relative '../lib/node_factory'
require_relative '../lib/data/string_data_source'

describe 'Location class' do

  let(:dataSource)  { StringDataSource.new("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")}
  let(:nodeFactory) { NodeFactory.new dataSource }
  let(:root) { nodeFactory.newRoot }
  let(:level1) { nodeFactory.addLeaf(root, 'a', 0) }    # level1 is entire string
  let(:level2) { nodeFactory.splitEdgeAt(level1, 26) }  # root -> level2(0, 25) -> level1(26, 51)
  let(:level3) { nodeFactory.splitEdgeAt(level1, 29) }  # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
  let(:linkNode) { nodeFactory.addLeaf(root, 'b', 2) }

  def forceLazyLoad
    location = Location.new(root)
    location = Location.new(level1)
    location = Location.new(level2)
    location = Location.new(level3)
  end

  describe "#new" do
    it "starts at a node" do
      location = Location.new(root)
      expect(location.node).to eq root
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
    end
  end

  describe "#jumpToNode" do
    it "sets location to node starting at another" do
      location = Location.new(level1)
      location.jumpToNode(level2)
      expect(location.node).to eq level2
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
    end
  end

  describe "#traverseUp" do
    # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
    it "goes to parent node starting from node" do
      # this is weird, but if I don't force the lazy loading test failes
      forceLazyLoad
      location = Location.new(level3)
      startOffset, endOffset = location.traverseUp
      expect(location.node).to eq level2
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
      expect(startOffset).to eq 26
      expect(endOffset).to eq 28
    end

    # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
    it "goes to parent node starting from leaf" do
      forceLazyLoad
      leafNode = nodeFactory.addLeaf(level3, 'c', 3)
      location = Location.new(leafNode, false, 6)
      startOffset, endOffset = location.traverseUp
      expect(location.node).to eq level3
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
      expect(startOffset).to eq 3
      expect(endOffset).to eq 5
    end

    # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
    it "goes to parent node starting at mid-edge from internal node" do
      forceLazyLoad
      leafNode = nodeFactory.addLeaf(level3, 'x', 38)
      location = Location.new(leafNode, false, 48)
      startOffset, endOffset = location.traverseUp
      expect(location.node).to eq level3
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
      expect(startOffset).to eq 38
      expect(endOffset).to eq 47
    end
  end

  describe "#traverseSuffixLink" do
    it "follows suffix link" do
      forceLazyLoad
      level3.suffixLink = linkNode
      location = Location.new(level3)
      location.traverseSuffixLink
      expect(location.node).to eq linkNode
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
    end
  end

  # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
  #                a, z             a,c               d,z
  describe "#traverseDownChildValue" do
    it "ends on child node if child edge has one value" do
      forceLazyLoad
      testNode = nodeFactory.addLeaf(level2, 'c', 2)
      location = Location.new(level2)
      location.traverseDownChildValue('c')
      expect(location.node).to eq testNode
      expect(location.onNode).to eq false
      expect(location.incomingEdgeOffset).to eq 3
    end

    it "ends on second character of child edge when that edge has more than one value" do
      forceLazyLoad
      leafNode = nodeFactory.addLeaf(level2, 'c', 2)
      internalNode = nodeFactory.splitEdgeAt(leafNode, 7)
      location = Location.new(internalNode)
      location.traverseDownChildValue('h')
      expect(location.node).to eq leafNode
      expect(location.onNode).to eq false
      expect(location.incomingEdgeOffset).to eq 8
    end
  end

  # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
  #                a, z   "a"       a,c    "d"        d,z
  describe "#traverseSkipDownCount" do
    it "checks single character to get to next node" do
      forceLazyLoad
      leaf = nodeFactory.addLeaf(level2, 'c', 2)
      # root -> level2(0, 25) -> level3(26,28) -> level1 (29,51)
      #                a, z   "a"       a,c    "d"        d,z
      #                       "c"  leaf(2,51)
      location = Location.new(level2)
      location.traverseSkipCountDown(dataSource, 2, 10)
      expect(location.node).to eq leaf
      expect(location.onNode).to eq false
      expect(location.incomingEdgeOffset).to eq 11
    end

    # 1:root -> 3:level2(0, 25) -> 4:level3(26,28) -> 2:level1 (29,-1)
    #                    a, z   "a"         a,c    "d"          d,z
    it "traverses multiple nodes down" do
      forceLazyLoad
      location = Location.new(root)
      location.traverseSkipCountDown(dataSource, 0, 33)
      expect(location.node).to eq level1
      expect(location.incomingEdgeOffset).to eq 34
      expect(location.onNode).to eq false
    end
  end

end
