require_relative 'base_data_source'

class WordDataSource < BaseDataSource
  attr_reader :words, :numberWordsInFile

  def initialize(filePath, regex = "/[^a-z0-9\-\s]/i")
    @filePath = filePath
    @words = []
    @regex = regex
    File.open(filePath, "r") do |file|
      file.each_line do |line|
        line.chomp!
        if (self.process(line)) then
          break
        end
      end
    end
    @numberWordsInFile = @words.length
  end

  def numberValues
    return @words.length
  end

  def process(line)
    line = self.preprocessLine(line)
    return self.processData(line.split)
  end

  def processData(data)
    data.each do |word|
      word = word.chomp(",")
      @words << word
    end
    return false
  end

  def preprocessLine(line)
    line.downcase.gsub(@regex, ' ')
  end

  def valueAt(offset)
    return @words[offset] if (offset < @numberWordsInFile)
    return nil
  end

  def toString(startOffset, endOffset)
    if (endOffset == -1) then
      result = "#{@words[startOffset]} ..*"
    else
      result = ""
      (startOffset..endOffset).each do |offset|
        result += "#{@words[offset]} "
      end
    end
    result
  end
end

class SingleWordDataSource < BaseDataSource
  def initialize(word)
    @word = word
  end

  def numberValues
    return 1
  end

  def valueAt(offset)
    return nil if (offset > 0)
    return @word
  end
end

class ArrayWordDataSource
  attr_reader :wordCounts

  def initialize(wordList, offsetList, size)
    @wordList = wordList
    @offsetList = offsetList
    @size = size
    @wordCounts = createWordCounts
  end

  def valueAt(offset)
    if (offset < @size) then
      return @wordList[@offsetList[offset]]
    else
      return nil
    end
  end

  def verify(word, count)
    if (@wordCounts == nil) then
      createWordCounts
    end
    @wordCounts[word] == count
  end

  def each_word(offset = 0)
    while ((value = self.valueAt(offset)) != nil) do
      yield value
      offset += 1
    end
  end

  private
  def createWordCounts()
    wordCounts = {}
    @wordList.each do |word|
      if (!wordCounts.has_key?(word)) then
        wordCounts[word] = 0
      end
      wordCounts[word] += 1
    end
    wordCounts
  end
end

class DelimitedWordDataSource < WordDataSource
  attr_reader :buckets, :wordCounts, :wordAsEncountered, :wordValueSequence

  def initialize(filePath, lineStateMachine, limit)
    @lineStateMachine = lineStateMachine
    @limit = limit
    @count = 0
    @buckets = {}
    @wordCounts = {}
    @wordValueSequence = []  # list of words in file in terms of index into @wordAsEncountered
    @wordAsEncounteredIndex = {}          # key is word, value is number as encountered
    @wordAsEncountered = []  # array entry added only when a new word is encountered
    @nextWordEncounteredIndex = 0
    super(filePath,"/[^[:print:]]/")
  end

  def bucket
    @lineStateMachine.bucket
  end

  def save
    File.open("#{@filePath}.words", 'w') do |file|
      @wordAsEncountered.each do |word|
        file.write("#{word}\n")
      end
    end
    File.open("#{@filePath}.values", 'wb') do |file|
      file << @wordValueSequence.pack("N*")
    end
    File.open("#{@filePath}.summary", "w") do |file|
      file << "#{@numberWordsInFile} words in file\n"
      file << "#{@nextWordEncounteredIndex} distinct words\n"
      file << "Metadata\n"

      # uh-oh, this seems to reverse the hash in place!
      @lineStateMachine.pages.sort_by(&:reverse).each do |page, wordOffset|
        file << "#{wordOffset} #{page}\n"
      end
    end
  end

  # TODO: fix this, linear metadata search, O(N) should be O(lg N)
  def metaDataFor(offset)
    previousMetadata = "unknown"
    @lineStateMachine.pages.sort_by(&:reverse).each do |metadata, wordOffset|
      if (wordOffset < offset) then
        previousMetadata = metadata
      else
        return previousMetadata
      end
    end
    return previousMetadata
  end

  def wordCount(word)
    return @wordCounts[word] if @wordCounts.has_key?(word)
    return 0
  end

  def processData(data,bucket)
    data.each do |word|
      word = word.chomp(",")
      word = word.chomp(".")
      if (word.length > 0) then
        @words << word
        if (!@wordCounts.has_key?(word)) then
          # we have a new word
          @wordAsEncounteredIndex[word] = @nextWordEncounteredIndex
          @wordAsEncountered << word
          @nextWordEncounteredIndex += 1
          @wordCounts[word] = 0
        end
        @wordCounts[word] += 1
        if (!@buckets[bucket].has_key?(word)) then
          @buckets[bucket][word] = 0
        end
        @buckets[bucket][word] += 1
        @wordValueSequence << @wordAsEncounteredIndex[word]
        @count += 1
        if ((@limit > 0) && (@count >= @limit)) then
          return true
        end
      end
    end
    return false
  end

  def process(line)
    line = self.preprocessLine(line)
    data = @lineStateMachine.process(line, @wordValueSequence.length)
    if (data.length > 0) then
      bucket = @lineStateMachine.bucket
      @buckets[bucket] = {} if (!@buckets.has_key?(bucket))
      return self.processData(data,bucket)
    end
    return false
  end

  def verify(word, count)
    @wordCounts[word] == count
  end

  def has_terminator?
    true
  end

  def terminator
    "END_OF_DOCUMENT"
  end
end
