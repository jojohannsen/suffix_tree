require_relative 'base_data_source'

class StringDataSource < BaseDataSource

  def initialize(s)
    @s = s
    super()
  end

  def numberValues
    return @s.length
  end

  def valueAt(offset)
    value = @s[ offset - @startOffset ]
    if (value == nil) then
      return self.nextDataSourceValueAt(offset)
    else
      return value
    end
  end

  # substring
  def toString(startOffset, endOffset)
    if (endOffset >= startOffset) then
      return @s[startOffset..endOffset]
    else
      return @s[startOffset..(@s.length - 1)]
    end
  end
end