require 'csv'

class PriceData
  attr_reader :data, :true_range, :atr, :tenkan, :kijun, :chikou, :senkou_a, :senkou_b
  def initialize( file )
    # data should be a csv file with [data,time,open,high,low,close,vol] structure
    @data = CSV.table( file )
    @true_range = @data.by_col[:true_range]
    @atr = @data.by_col[:atr]
    
    @tenkan = data.by_col[:tenkan].dup
    @kijun = data.by_col[:kijun].dup
    @chikou = data.by_col[:chikou].dup
    @senkou_a = data.by_col[:senkou_a].dup
    @senkou_b = data.by_col[:senkou_b].dup
  end
end