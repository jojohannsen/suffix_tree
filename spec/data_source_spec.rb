require 'rspec'
require_relative '../lib/data/file_data_source'
require_relative '../lib/data/string_data_source'
require_relative '../lib/data/word_data_source'

describe 'reads data sources' do

  describe 'WordDataSource' do
    it "should read words" do
      wordDataSource = WordDataSource.new(File.join('spec', 'fixtures', "singlePara.txt"))
      expect(wordDataSource.valueAt(0)).to eq "i"
      expect(wordDataSource.valueAt(1)).to eq "was"
      expect(wordDataSource.valueAt(2)).to eq "born"
      expect(wordDataSource.valueAt(8)).to eq "angora"
      expect(wordDataSource.valueAt(16)).to eq "silky-haired"
      expect(wordDataSource.valueAt(19)).to eq "goats"
    end
  end

  describe "#extendWith on a StringDataSource" do
    it "allows a data source to be extended with another" do
      # this is used for making generalized suffix tree from multiple data sources
      # we need ability to treat them as belonging to one large data source
      sd1 = StringDataSource.new "abc"
      sd2 = StringDataSource.new "def"
      sd1.extendWith(sd2, 3)
      expect(sd1.valueAt(0)).to eq "a"
      expect(sd1.valueAt(1)).to eq "b"
      expect(sd1.valueAt(2)).to eq "c"
      val = sd1.valueAt(3)
      expect(sd1.valueAt(3)).to eq "d"
      expect(sd1.valueAt(4)).to eq "e"
      expect(sd1.valueAt(5)).to eq "f"
      expect(sd1.valueAt(6)).to eq nil
    end
  end

  describe "#extendWith on a FileDataSource" do
    it "allows file data sources to be extended" do
      fd1 = FileDataSource.new(File.join('spec', 'fixtures', "mississippi.txt"))
      fd2 = FileDataSource.new(File.join('spec', 'fixtures', "arizona.txt"))
      fd1.extendWith(fd2, 11)
      expect(fd1.valueAt(2)).to eq "s"
      expect(fd1.valueAt(10)).to eq "i"
      expect(fd1.valueAt(11)).to eq "a"
      expect(fd1.valueAt(12)).to eq "r"
      expect(fd1.valueAt(17)).to eq "a"
      expect(fd1.valueAt(18)).to eq nil
    end
  end
end
