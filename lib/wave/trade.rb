class Trade
  # need to create a Trade class which stores info such as mfe, mae, and atr
  attr_accessor :trade_type, :price
  attr_reader :mfe, :mae, :atr_at_entry, :size

  def initialize( trade_type, price, index=1, size=1 )
    raise "Not a valid trade type" unless [:l, :s].include? trade_type
    @trade_type = trade_type
    @price = price
    @size = size
    @mfe = 0
    @mae = 0
    @atr_at_entry = $data.atr[ index ] if $data
  end
  
  def update( ohlc, index=1 )
    if trade_type == :l
      @mfe = [ohlc[:high] - @price, @mfe].max if ohlc[:high] - @price > 0
      @mae = [ohlc[:low] - @price, @mae].min if ohlc[:low] - @price < 0
    else
      @mfe = [@price - ohlc[:low], @mfe].max if @price - ohlc[:low] > 0
      @mae = [@price - ohlc[:high], @mae].min if @price - ohlc[:high] < 0
    end
  end
  
  def long?
    @trade_type == :l ? true : false
  end
  
  def short?
    @trade_type == :s ? true : false
  end
end