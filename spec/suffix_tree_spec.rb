require 'rspec'

require_relative '../lib/data/string_data_source'
require_relative '../lib/data/word_data_source'
require_relative '../lib/suffix_tree'
require_relative '../lib/visitor/data_source_visitor'
require_relative '../lib/visitor/dfs'
require_relative '../lib/visitor/leaf_count_visitor'
require_relative '../lib/visitor/tree_print_visitor'
require_relative '../lib/visitor/value_depth_visitor'


describe 'suffix tree' do

  it 'should create suffix tree' do

    st = SuffixTree.new('$')
    stringData = StringDataSource.new("mississippi")
    st.addDataSource(stringData)
    expect(st.root).to_not eq(nil)
    expect(st.root.children.length).to eq(5)
    mChild = st.root.children['m']
    expect(mChild).to_not eq(nil)
    expect(mChild.isLeaf).to eq(true)
    expect(mChild.suffixOffset).to eq(0)
    iChild = st.root.children['i']
    expect(iChild).to_not eq(nil)
    expect(iChild.isInternal).to eq(true)
    expect(iChild.children.length).to eq(3)
    expect(iChild.suffixOffset).to eq(1)
    sChild = st.root.children['s']
    expect(sChild.isInternal).to eq(true)
    expect(sChild.children.length).to eq(2)
    pChild = st.root.children['p']
    expect(pChild.isInternal).to eq(true)
    expect(pChild.children.length).to eq(2)
  end

  it "builds tree with one leaf" do
    dataSource = StringDataSource.new("a")
    st = SuffixTree.new
    st.addDataSource(dataSource)
    expect(st.root.children.length).to eq (1)
    location = st.location
    expect(location.onNode).to eq (true)
    expect(location.node).to eq(st.root)
  end

  it "builds tree with two leaf" do
    dataSource = StringDataSource.new("ab")
    st = SuffixTree.new
    st.addDataSource(dataSource)
    expect(st.root.children.length).to eq (2)
    child1 = st.root.children['a']
    expect(child1.suffixOffset).to eq(0)
    child2 = st.root.children['b']
    expect(child2.suffixOffset).to eq(1)
    location = st.location
    expect(location.onNode).to eq (true)
    expect(location.node).to eq(st.root)
  end

  it "builds mississippi tree" do
    dataSource = StringDataSource.new("mississippi")
    st = SuffixTree.new
    st.setDataSource(dataSource)

    sio = StringIO.new()
    tpv = TreePrintVisitor.new(dataSource, sio)
    dfs = DFS.new(tpv)

    st.addValue('m', 0)

    expect(st.root.children['m'].nodeId).to eq(2)
    location = st.location
    expect(location.onNode).to eq (true)
    expect(location.node.nodeId).to eq (1)

    st.addValue('i', 1)

    expect(st.root.children['i'].nodeId).to eq(3)
    expect(location.onNode).to eq (true)
    expect(location.node.nodeId).to eq (st.root.nodeId)

    st.addValue('s', 2)

    expect(st.root.children['s'].nodeId).to eq(4)
    expect(location.onNode).to eq (true)
    expect(location.node.nodeId).to eq (st.root.nodeId)

    st.addValue('s', 3)

    rootSchild = st.root.children['s']
    expect(rootSchild.nodeId).to eq (4)
    expect(rootSchild.incomingEdgeStartOffset).to eq(2)
    expect(rootSchild.incomingEdgeEndOffset).to eq(Node::CURRENT_ENDING_OFFSET)
    expect(location.onNode).to eq (false)
    expect(location.incomingEdgeOffset).to eq (3)

    st.addValue('i', 4)

    # should have added an internal node and a leaf node
    # internal node should be the 's' child of root, with a suffix link pointing to root
    rootSchild = st.root.children['s']
    expect(rootSchild.suffixLink).not_to eq (nil)
    expect(rootSchild.suffixLink).to eq(st.root)
    expect(location.onNode).to eq (false)
    expect(location.incomingEdgeOffset).to eq (2)
    rootSchild = st.root.children['s']
    suffix3_nodeId = rootSchild.children['s'].nodeId
    expect(rootSchild.incomingEdgeStartOffset).to eq(2)
    expect(rootSchild.incomingEdgeEndOffset).to eq(2)

    # these next 3 should not should only update the location incomingEdgeOffset
    st.addValue('s', 5)

    expect(location.incomingEdgeOffset).to eq (3)
    expect(location.onNode).to eq (false)

    st.addValue('s', 6)

    expect(location.incomingEdgeOffset).to eq (4)
    expect(location.onNode).to eq (false)

    st.addValue('i', 7)

    expect(location.incomingEdgeOffset).to eq (5)
    expect(location.onNode).to eq (false)

    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(true)
    slNode = location.node
    expect(slNode.suffixLink).to eq(nil)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(false)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(true)
    expect(slNode.suffixLink).not_to eq(nil)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(false)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(true)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(false)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(true)
    result = st.extend('p', 8)

    expect(result).to eq (true)
    expect(location.onNode).to eq(true)
    result = st.extend('p', 8)

    expect(result).to eq (false)
    expect(location.onNode).to eq(true)

    st.addValue('p', 9)

    expect(location.onNode).to eq (false)
    expect(location.incomingEdgeOffset).to eq(9)

    st.addValue('i', 10)

    dfs.traverse(st.root)
    expected_tree = <<-TREESTR
ROOT
 mississippi
 i
  ssi
   ssippi
   ppi
  ppi
 s
  si
   ssippi
   ppi
  i
   ssippi
   ppi
 p
  pi
  i
TREESTR
    expect(sio.string).to eq (expected_tree)

    expect(location.onNode).to eq (true)
    expect(location.node.nodeId).to eq (13)
  end

  it "builds suffix tree of words" do
    wordDataSource = WordDataSource.new File.join('spec', 'fixtures', "chapter1.txt")
    st = SuffixTree.new(nil, { :leafCount => true, :valueDepth => true })
    st.addDataSource(wordDataSource)

    root = st.root
    expect(root.nodeId).to eq 1
    lcv = DFS.new(LeafCountVisitor.new)
    lcv.traverse(st.root)
    deepVal = DeepestValueDepthVisitor.new
    dfs = DFS.new(deepVal)
    dfs.traverse(st.root)
    expect(st.nodeFactory.valuePath(deepVal.deepestValueDepthNode)).to eq "in spite of his"
  end

  it "converts tree to suffix array" do
    dataSource = StringDataSource.new "mississippi"
    st = SuffixTree.new('$')
    st.addDataSource dataSource

    suffix_array = []
    st.root.each_suffix do |suffixOffset|
      suffix_array << suffixOffset
    end
    expect(suffix_array).to eq [11, 10, 7, 4, 1, 0, 9, 8, 6, 3, 5, 2]
  end

  describe "builds generalized suffix trees" do
    let(:alphaDataSource) { StringDataSource.new "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqr" }
    let(:alphaNodeFactory) { NodeFactory.new alphaDataSource }
    let(:secondDataSource) { StringDataSource.new "asjdfkjaskdjfkajlxxxxxxxjklmnopqrstuvwxyzabcsdf;laksjdf aksjd"}

    it "builds generalized suffix tree" do
      st = SuffixTree.new('$', {:valueDepth => true})
      st.addDataSource alphaDataSource
      st.addDataSource secondDataSource

      deepVal = DeepestValueDepthVisitor.new
      dfs = DFS.new(deepVal)
      dfs.traverse(st.root)
      expect(st.nodeFactory.valuePath(deepVal.deepestValueDepthNode,'')).to eq "jklmnopqrstuvwxyzabc"
    end

    let(:src1) { StringDataSource.new "abcd" }
    let(:src2) { StringDataSource.new "cxyz" }

    it "uses multiple data sources" do
      st = SuffixTree.new(nil, {:valueDepth => true, :dataSourceBit => true})
      st.addDataSource src1
      st.addDataSource src2

      deepVal = DeepestValueDepthVisitor.new
      dfs = DFS.new(deepVal)
      dfs.traverse(st.root)
      expect(st.nodeFactory.valuePath(deepVal.deepestValueDepthNode,'')).to eq "c"
      dataSourceVisitor = DataSourceVisitor.new
      dfs = DFS.new(dataSourceVisitor)
      dfs.traverse(st.root)
      expect(deepVal.deepestValueDepthNode.dataSourceBit).to eq 3
      expect(st.root.dataSourceBit).to eq 3
      expect(st.root.children['a'].dataSourceBit).to eq 1
      expect(st.root.children['x'].dataSourceBit).to eq 2
      expect(deepVal.deepestValueDepthNode.children['d'].dataSourceBit).to eq 1
      expect(deepVal.deepestValueDepthNode.children['x'].dataSourceBit).to eq 2
    end
  end

end
