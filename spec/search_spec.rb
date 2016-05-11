require 'rspec'
require_relative '../lib/location'
require_relative '../lib/node'
require_relative '../lib/node_factory'
require_relative '../lib/data/string_data_source'
require_relative '../lib/data/file_data_source'
require_relative '../lib/visitor/bfs'
require_relative '../lib/visitor/leaf_count_visitor'
require_relative '../lib/visitor/value_depth_visitor'
require_relative '../lib/visitor/dfs'
require_relative '../lib/visitor/node_count_visitor'
require_relative '../lib/search/searcher'
require_relative '../lib/suffix_tree'

describe "Search class" do

  let (:dataSource) { StringDataSource.new("mississippi") }
  let (:nodeFactory) { NodeFactory.new dataSource }
  let (:rootNodeId) { nodeFactory.nextNodeId }
  let (:fileDataSource) { FileDataSource.new(File.join('spec', 'fixtures', "mississippi.txt")) }
  let (:fileNodeFactory) { NodeFactory.new fileDataSource }

  describe '#find' do

    it 'finds all substrings' do
      hash = {
          :valueDepth => true
      }
      st = SuffixTree.new(nil, hash)
      st.addDataSource(dataSource)

      searcher = Searcher.new(dataSource, st.root)
      expect(searcher.findString("m")).to eq ([0])
      expect(searcher.findString("i")).to eq ([1,4,7])
      expect(searcher.findString("s")).to eq ([2,3,5,6])
      expect(searcher.findString("p")).to eq ([8,9])
      expect(searcher.findString("x")).to eq ([])
      expect(searcher.findString("mi")).to eq ([0])
      expect(searcher.findString("is")).to eq ([1,4])
      expect(searcher.findString("ss")).to eq ([2,5])
      expect(searcher.findString("si")).to eq ([3,6])
      expect(searcher.findString("ip")).to eq ([7])
      expect(searcher.findString("pp")).to eq ([8])
      expect(searcher.findString("pi")).to eq ([9])
      expect(searcher.findString("mis")).to eq ([0])
      expect(searcher.findString("iss")).to eq ([1,4])
      expect(searcher.findString("ssi")).to eq ([2,5])
      expect(searcher.findString("ssx")).to eq ([])
      expect(searcher.findString("sis")).to eq ([3])
      expect(searcher.findString("sip")).to eq ([6])
      expect(searcher.findString("ipp")).to eq ([7])
      expect(searcher.findString("ppi")).to eq ([8])
      expect(searcher.findString("miss")).to eq ([0])
      expect(searcher.findString("issi")).to eq ([1,4])
      expect(searcher.findString("ssis")).to eq ([2])
      expect(searcher.findString("siss")).to eq ([3])
      expect(searcher.findString("ssip")).to eq ([5])
      expect(searcher.findString("sipp")).to eq ([6])
      expect(searcher.findString("ippi")).to eq ([7])
      expect(searcher.findString("missi")).to eq ([0])
      expect(searcher.findString("issis")).to eq ([1])
      expect(searcher.findString("ssiss")).to eq ([2])
      expect(searcher.findString("sissi")).to eq ([3])
      expect(searcher.findString("issip")).to eq ([4])
      expect(searcher.findString("ssipp")).to eq ([5])
      expect(searcher.findString("sippi")).to eq ([6])
      expect(searcher.findString("missis")).to eq ([0])
      expect(searcher.findString("ississ")).to eq ([1])
      expect(searcher.findString("ssissi")).to eq ([2])
      expect(searcher.findString("sissip")).to eq ([3])
      expect(searcher.findString("issipp")).to eq ([4])
      expect(searcher.findString("ssippi")).to eq ([5])
      expect(searcher.findString("mississ")).to eq ([0])
      expect(searcher.findString("ississi")).to eq ([1])
      expect(searcher.findString("ssissip")).to eq ([2])
      expect(searcher.findString("sissipp")).to eq ([3])
      expect(searcher.findString("issippi")).to eq ([4])
      expect(searcher.findString("mississi")).to eq ([0])
      expect(searcher.findString("ississip")).to eq ([1])
      expect(searcher.findString("ssissipp")).to eq ([2])
      expect(searcher.findString("sissippi")).to eq ([3])
      expect(searcher.findString("mississip")).to eq ([0])
      expect(searcher.findString("ississipp")).to eq ([1])
      expect(searcher.findString("ssissippi")).to eq ([2])
      expect(searcher.findString("ssissippix")).to eq ([])
      expect(searcher.findString("mississipp")).to eq ([0])
      expect(searcher.findString("ississippi")).to eq ([1])
      expect(searcher.findString("mississippi")).to eq ([0])
    end

    it 'finds all substrings' do
      st = SuffixTree.new(nil, { :valueDepth => true })
      st.addDataSource(fileDataSource)

      st.addValue('m',11)
      st.addValue('i',12)
      st.addValue('$',13)
      searcher = Searcher.new(dataSource, st.root)
      expect(searcher.findString("m")).to eq ([0,11])         # 2 m's now
      expect(searcher.findString("i")).to eq ([1,4,7,10,12])  # final "i" of mississippi now explicit, and there's another as well
      expect(searcher.findString("s")).to eq ([2,3,5,6])
      expect(searcher.findString("p")).to eq ([8,9])
      expect(searcher.findString("x")).to eq ([])
      expect(searcher.findString("mi")).to eq ([0,11])        # "mi" is now at end as well
      expect(searcher.findString("is")).to eq ([1,4])
      expect(searcher.findString("ss")).to eq ([2,5])
      expect(searcher.findString("si")).to eq ([3,6])
      expect(searcher.findString("ip")).to eq ([7])
      expect(searcher.findString("pp")).to eq ([8])
      expect(searcher.findString("pi")).to eq ([9])
      expect(searcher.findString("mis")).to eq ([0])
      expect(searcher.findString("iss")).to eq ([1,4])
      expect(searcher.findString("ssi")).to eq ([2,5])
      expect(searcher.findString("ssx")).to eq ([])
      expect(searcher.findString("sis")).to eq ([3])
      expect(searcher.findString("sip")).to eq ([6])
      expect(searcher.findString("ipp")).to eq ([7])
      expect(searcher.findString("ppi")).to eq ([8])
      expect(searcher.findString("miss")).to eq ([0])
      expect(searcher.findString("issi")).to eq ([1,4])
      expect(searcher.findString("ssis")).to eq ([2])
      expect(searcher.findString("siss")).to eq ([3])
      expect(searcher.findString("ssip")).to eq ([5])
      expect(searcher.findString("sipp")).to eq ([6])
      expect(searcher.findString("ippi")).to eq ([7])
      expect(searcher.findString("missi")).to eq ([0])
      expect(searcher.findString("issis")).to eq ([1])
      expect(searcher.findString("ssiss")).to eq ([2])
      expect(searcher.findString("sissi")).to eq ([3])
      expect(searcher.findString("issip")).to eq ([4])
      expect(searcher.findString("ssipp")).to eq ([5])
      expect(searcher.findString("sippi")).to eq ([6])
      expect(searcher.findString("missis")).to eq ([0])
      expect(searcher.findString("ississ")).to eq ([1])
      expect(searcher.findString("ssissi")).to eq ([2])
      expect(searcher.findString("sissip")).to eq ([3])
      expect(searcher.findString("issipp")).to eq ([4])
      expect(searcher.findString("ssippi")).to eq ([5])
      expect(searcher.findString("mississ")).to eq ([0])
      expect(searcher.findString("ississi")).to eq ([1])
      expect(searcher.findString("ssissip")).to eq ([2])
      expect(searcher.findString("sissipp")).to eq ([3])
      expect(searcher.findString("issippi")).to eq ([4])
      expect(searcher.findString("mississi")).to eq ([0])
      expect(searcher.findString("ississip")).to eq ([1])
      expect(searcher.findString("ssissipp")).to eq ([2])
      expect(searcher.findString("sissippi")).to eq ([3])
      expect(searcher.findString("mississip")).to eq ([0])
      expect(searcher.findString("ississipp")).to eq ([1])
      expect(searcher.findString("ssissippi")).to eq ([2])
      expect(searcher.findString("ssissippix")).to eq ([])
      expect(searcher.findString("mississipp")).to eq ([0])
      expect(searcher.findString("ississippi")).to eq ([1])
      expect(searcher.findString("mississippi")).to eq ([0])
    end
  end

  describe "#matchDataSource" do
    it "returns root location if nothing matches" do
      st = SuffixTree.new(nil, { :valueDepth => true })
      st.addDataSource(dataSource)
      searcher = Searcher.new(dataSource, st.root)
      xDataSource = StringDataSource.new("xxx")
      location = searcher.matchDataSource(xDataSource)
      expect(location.onNode).to eq true
      expect(location.node).to eq st.root
      expect(location.depth).to eq 0
    end

    it "finds location that we can use to get suffix offset" do
      st = SuffixTree.new('$', { :valueDepth => true })
      st.addDataSource(dataSource)
      searcher = Searcher.new(dataSource, st.root)
      location = searcher.matchDataSource(StringDataSource.new "i")
      result = []
      location.node.each_suffix do |suffixOffset|
        result << suffixOffset
      end
      expect(result).to eq [ 10, 7, 4, 1 ]
    end
  end
end
