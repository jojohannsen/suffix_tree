require 'rspec'
require_relative '../lib/node'
require_relative '../lib/node_factory'
require_relative '../lib/data/string_data_source'

describe "NodeFactory class" do

  let(:dataSource) { StringDataSource.new "mississippi" }
  let(:alphaDataSource) { StringDataSource.new "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz" }
  let(:alphaNodeFactory) { NodeFactory.new alphaDataSource }

  describe '#initialize' do
    it "accepts a dataSource" do
      nodeFactory = NodeFactory.new dataSource
      expect(nodeFactory.dataSource).to eq dataSource
    end
  end

  describe '#configure' do
    it "keeps a hash of configuration options for how nodes get built" do
      nodeFactory = NodeFactory.new dataSource
      hash = {
          :generalized_suffix_tree => true,
          :track_value_depth => true,
#          :save_previous_value => true, for this test we verify default "false" remains
      }
      nodeFactory.setConfiguration(hash)
      configuration = nodeFactory.configuration
      expect(configuration[:generalized_suffix_tree]).to eq hash[:generalized_suffix_tree]
      expect(configuration[:track_character_depth]).to eq hash[:track_character_depth]
      expect(configuration[:previousValue]).to eq false
    end

    it "by default does not save previous value" do
      nodeFactory = NodeFactory.new dataSource
      root = nodeFactory.newRoot
      leaf = nodeFactory.addLeaf(root, 'i', 1)
      internal = nodeFactory.splitEdgeAt(leaf, 4)
      leaf2 = nodeFactory.addLeaf(internal, 'x', 7)
      expect(defined? leaf.previousValue).to eq nil
      expect(defined? internal.previousValue).to eq nil
      expect(defined? leaf2.previousValue).to eq nil
    end

    it "configuration turns on previous value saving" do
      nodeFactory = NodeFactory.new dataSource
      hash = {
          :previousValue => true
      }
      nodeFactory.setConfiguration(hash)
      root = nodeFactory.newRoot
      leaf = nodeFactory.addLeaf(root, 'm', 0)
      expect(leaf.previousValue).to eq nil

      leaf = nodeFactory.addLeaf(root, 'i', 1)
      expect(leaf.previousValue).to eq 'm'

      leaf2 = nodeFactory.addLeaf(root, 's', 2)
      expect(leaf2.previousValue).to eq 'i'

      internal = nodeFactory.splitEdgeAt(leaf, 4)
      expect(internal.previousValue).to eq nil

      leaf3 = nodeFactory.addLeaf(internal, 'x', 7)
      expect(leaf3.previousValue).to eq 's'
      leaf3 = nodeFactory.addLeaf(internal, 'x', 7)
      expect(leaf3.previousValue).to eq 's'
    end

    it "tracks value depth of nodes" do
      nodeFactory = NodeFactory.new dataSource
      hash = {
          :valueDepth => true
      }
      nodeFactory.setConfiguration(hash)
      root = nodeFactory.newRoot
      leaf = nodeFactory.addLeaf(root, 'i', 1)
      internal = nodeFactory.splitEdgeAt(leaf, 4)
      expect(internal.valueDepth).to eq 3
    end

    it "tracks value depth of nodes" do
      nodeFactory = NodeFactory.new dataSource
      nodeFactory.setConfiguration({
                                       :valueDepth => true
                                   })
      root = nodeFactory.newRoot
      expect(root.valueDepth).to eq 0
      leaf = nodeFactory.addLeaf(root, 'i', 1)
      internal = nodeFactory.splitEdgeAt(leaf, 8)
      internal2 = nodeFactory.splitEdgeAt(internal, 4)
      expect(internal.valueDepth).to eq 7
      expect(internal2.valueDepth).to eq 3
      internal3 = nodeFactory.splitEdgeAt(internal, 6)
      expect(internal3.valueDepth).to eq 5
    end
  end

  describe "#newRoot" do
    it "creates a new root node with node_id=1" do
      nodeFactory = NodeFactory.new dataSource
      root = nodeFactory.newRoot
      expect(root.nodeId).to eq 1
      expect(root.children.length).to eq 0
      expect(nodeFactory.nextNodeId).to eq 2
    end

    it "resets each time newRoot is called" do
      nodeFactory = NodeFactory.new dataSource
      root1 = nodeFactory.newRoot
      root2 = nodeFactory.newRoot
      expect(root1.nodeId).to eq 1
      expect(root2.nodeId).to eq 1
    end
  end

  describe "#addLeaf" do
    it "adds a leaf node" do
      nodeFactory = NodeFactory.new dataSource
      root = nodeFactory.newRoot
      child = nodeFactory.addLeaf(root, 'a', 3)
      aChild = root.children['a']
      expect(aChild).to eq child
      expect(root.children['a'].parent).to eq root
    end
  end

  describe "#splitEdgeAtOffset" do
    it "splits a long edge" do

      root = alphaNodeFactory.newRoot
      level1 = alphaNodeFactory.addLeaf(root, 'a', 0)
      expect(level1.parent).to eq root
      expect(level1.incomingEdgeStartOffset).to eq 0
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      level2 = alphaNodeFactory.splitEdgeAt(level1, 26)
      expect(level2.parent).to eq root
      expect(level1.parent).to eq level2
      expect(level2.incomingEdgeStartOffset).to eq 0
      expect(level2.incomingEdgeEndOffset).to eq 25
      expect(level1.incomingEdgeStartOffset).to eq 26
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      level3 = alphaNodeFactory.splitEdgeAt(level1, 29)
      expect(level3.parent).to eq level2
      expect(level2.parent).to eq root
      expect(level3.incomingEdgeStartOffset).to eq 26
      expect(level3.incomingEdgeEndOffset).to eq 28
      expect(level1.incomingEdgeStartOffset).to eq 29
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
    end

    it "splits edge and returns that node" do
      nodeFactory = NodeFactory.new dataSource
      root = nodeFactory.newRoot
      child = nodeFactory.addLeaf(root, 'm', 0)
      middleNode = nodeFactory.splitEdgeAt(child, 3)
      expect(middleNode.parent).to eq (root)
      expect(middleNode.incomingEdgeStartOffset).to eq 0
      expect(middleNode.incomingEdgeEndOffset).to eq 2
      expect(middleNode.isInternal).to eq true
      expect(child.parent).to eq (middleNode)
      expect(child.incomingEdgeStartOffset).to eq 3
      expect(child.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      expect(child.isLeaf).to eq true
    end

    it "splits nodes correctly" do
      root = nodeFactory2.newRoot
      level1 = nodeFactory2.addLeaf(root, 'a', 0)
      expect(root.children['a']).to eq level1
      level2 = nodeFactory2.splitEdgeAt(level1, 26)
      expect(root.children['a']).to eq level2
      expect(level2.parent).to eq root
      expect(level2.incomingEdgeStartOffset).to eq 0
      expect(level2.incomingEdgeEndOffset).to eq 25
      expect(level1.parent).to eq level2
      expect(level1.incomingEdgeStartOffset).to eq 26
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
    end

    it "handles multiple splits" do
      root2 = nodeFactory2.newRoot
      rLevel1 = nodeFactory2.addLeaf(root2, 'a', 0)
      expect(rLevel1.incomingEdgeStartOffset).to eq 0
      expect(rLevel1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      rLevel2 = nodeFactory2.splitEdgeAt(rLevel1, 26)
      expect(rLevel2.children.length).to eq 1
      expect(rLevel2.isInternal).to eq true
      expect(rLevel2.incomingEdgeStartOffset).to eq 0
      expect(rLevel2.incomingEdgeEndOffset).to eq 25
      expect(rLevel1.isLeaf).to eq true
      expect(rLevel1.incomingEdgeStartOffset).to eq 26
      expect(rLevel1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
    end

    let(:dataSource2)  { StringDataSource.new("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")}
    let(:nodeFactory2) { NodeFactory.new dataSource2 }
  end
end
