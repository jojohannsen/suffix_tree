class ValueRange

  attr_accessor :startOffset, :endOffset

  def initialize(startOffset, endOffset)
    @startOffset = startOffset
    @endOffset = endOffset
  end

  def length
    return @endOffset - @startOffset + 1
  end

end

class KCommonVisitor < BaseVisitor

  def initialize(dataSource)
    @dataSource = dataSource

    #
    # key = common to at least this many (2, 3, ...)
    # value = [ startOffset, endOffset ] of value sequence
    #
    @commonTo = {}

    #
    # set up initial values
    #
    (0..64).each do |value|
      @commonTo[value] = ValueRange.new(0,-1)
    end
    super()
  end

  def postVisit(node)
    nCommon = self.countCommon(node.dataSourceBit)
    currentCommonLength = @commonTo[nCommon].endOffset - @commonTo[nCommon].startOffset + 1
    if (node.valueDepth > currentCommonLength) then
      @commonTo[nCommon].startOffset = node.incomingEdgeEndOffset - node.valueDepth + 1
      @commonTo[nCommon].endOffset = node.incomingEdgeEndOffset
      if (nCommon > 2) then
        longestLength = node.valueDepth
        (1..(nCommon-1)).each do |offset|
          testLength = @commonTo[offset].endOffset - @commonTo[offset].startOffset + 1
          if (testLength < longestLength) then
            @commonTo[offset].startOffset = @commonTo[nCommon].startOffset
            @commonTo[offset].endOffset = @commonTo[nCommon].endOffset
          end
        end
      end
    end
  end

  def longestStringCommonTo(numberInCommon)
    return @commonTo[numberInCommon].length, @dataSource.valueSequence(@commonTo[numberInCommon].startOffset, @commonTo[numberInCommon].endOffset)
  end

  def countCommon(bits)
    result = 0
    scanner = 1
    bits = bits.to_i
    (1..32).each do
      if ((scanner & bits) != 0) then
        result += 1
      end
      scanner = scanner << 1
    end
    result
  end
end