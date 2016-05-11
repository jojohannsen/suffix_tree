class BaseDataSource
  attr_accessor :startOffset

  def initialize(startOffset = 0)
    @nextDataSource = nil
    @startOffset = startOffset
  end

  def each_with_index(offset = 0)
    while ((value = self.valueAt(offset)) != nil) do
      yield value, offset
      offset += 1
    end
  end

  def extendWith(dataSource, startOffset)
    if (@nextDataSource == nil) then
      @nextDataSource = dataSource
      dataSource.startOffset = startOffset
    else
      @nextDataSource.extendWith(dataSource, startOffset)
    end
  end

  def has_terminator?
    false
  end

  def nextDataSourceValueAt(offset)
    if (@nextDataSource != nil) then
      return @nextDataSource.valueAt(offset)
    else
      return nil
    end
  end

  def valueSequence(startOffset, endOffset)
    result = ""
    (startOffset..endOffset).each do |offset|
      result += self.valueAt(offset)
    end
    result
  end
end