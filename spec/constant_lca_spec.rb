require 'rspec'
require_relative '../lib/data/string_data_source'
require_relative '../lib/suffix_tree'
require_relative '../lib/visitor/dfs'
require_relative '../lib/visitor/numbering_visitor'

describe 'Preprocesses suffix tree to allow constant time least-common-ancestor' do

  let (:dataSource) { StringDataSource.new("mississippi$") }

  it 'should find least-common-ancestor of any two leaf' do
    st = SuffixTree.new
    st.addDataSource(dataSource)
    dfs = OrderedDFS.new(NumberingVisitor.new)
    dfs.traverse(st.root)
    dfs = OrderedDFS.new(RunDefiningVisitor.new)
    dfs.traverse(st.root)
    dfs = DFS.new(RunBitVisitor.new(st.root))
    dfs.traverse(st.root)
    leafNodeCollector = LeafNodeCollector.new
    dfs = DFS.new(leafNodeCollector)
    dfs.traverse(st.root)
    leafNodeCollector.suffixToLeaf.keys.sort.each do |key|
      print "#{key} #{leafNodeCollector.suffixToLeaf[key].dfsNumber}\n"
    end
  end
end
