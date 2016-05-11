require_relative 'string_data_source'
require_relative 'file_data_source'

class DataSourceFactory

  STRING_DATA_SOURCE = 'string'
  FILE_DATA_SOURCE = 'file'

  def newDataSource(dataSourceType, dataSourceValue)
    if (dataSourceType == STRING_DATA_SOURCE) then
      return StringDataSource.new(dataSourceValue)
    elsif (dataSourceType == FILE_DATA_SOURCE) then
      return FileDataSource.new(dataSourceValue)
    end
  end
end