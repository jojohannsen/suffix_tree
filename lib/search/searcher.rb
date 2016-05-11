require_relative '../visitor/bfs'
require_relative '../visitor/suffix_offset_visitor'
require_relative '../data/string_data_source'

#
#  Searcher finds matches in a tree
#
#  It needs the tree root, and the data source used to make the tree
#  This assumes the tree was made with a single data source.
#
#  "find" really should be finding matches from a different data source (not a string)
#
class Searcher
  def initialize(treeDataSource, treeRoot)
    @dataSource = treeDataSource
    @root = treeRoot
  end

  #
  #  match dataSource values, return location in the suffix tree where the match stopped
  #
  def matchDataSource(dataSource)
    location = Location.new(@root)
    location.matchDataSource(@dataSource, dataSource)
    location
  end

  def findNode(dataSource)
    location = Location.new(@root)
    if (location.matchDataSource(@dataSource, dataSource).depth == dataSource.numberValues) then
      return location.node
    else
      return nil
    end
  end

  #
  #  returns the list of suffix offset values where the searchString has been found
  #
  def findString(searchString)
    node = self.findNode(StringDataSource.new(searchString))
    return self.findResults(node)
  end


  def findWord(searchString)
    node = self.findNode(SingleWordDataSource.new(searchString))
    return self.findResults(node)
  end

  def findResults(node)
    if (node != nil) then
      soCollector = SuffixOffsetVisitor.new
      so = BFS.new(soCollector)
      so.traverse(node)
      return soCollector.result.sort
    else
      return []
    end
  end

  # match a string starting at a specific location,
  # returning the character depth of the resulting match
  def findAtLocation(location, s)
    location.matchString(@dataSource, s)
    return location.depth
  end
end