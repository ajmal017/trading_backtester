require_relative "broker"

class Trader
  attr_accessor :broker
  attr_reader :name
  
  def initialize( account_balance, loss_cut=account_balance )
    @name = "Trader-#{object_id}"
    @broker = Broker.new( account_balance, loss_cut )
  end

  ######################################################################  
  ### Trading Strategies tailored towards the particular trader go here.
  ######################################################################

  def enter_long?( ohlc, i )
    if ohlc[:close] > $data.kijun[i]
      $data.tenkan[i-1] <= $data.kijun[i-1] && $data.tenkan[i] > $data.kijun[i]
    end
    
# Experiment here.
    # if ohlc[:close] > $data.kijun[i]
    #   $data.tenkan[i-1] <= $data.kijun[i-1] && $data.tenkan[i] > $data.kijun[i]
    # end
    
    # if ohlc[:close] > $data.kijun[i]
    #   $data.senkou_a[i-1] <= $data.senkou_b[i-1] && $data.senkou_a[i] > $data.senkou_b[i]
    # end
  end
  
  def enter_short?( ohlc, i )
    if ohlc[:close] < $data.kijun[i]
      $data.tenkan[i-1] >= $data.kijun[i-1] && $data.tenkan[i] < $data.kijun[i]
    end
    
    # if ohlc[:close] < $data.kijun[i]
    #   $data.senkou_a[i-1] >= $data.senkou_b[i-1] && $data.senkou_a[i] < $data.senkou_b[i]
    # end
  end
  
  def exit_long?( ohlc, i )
    # ohlc[:close] < $data.tenkan[i]
    ohlc[:close] <= $data.kijun[i]
  end
  
  def exit_short?( ohlc, i )
    # ohlc[:close] > $data.tenkan[i]
    ohlc[:close] >= $data.kijun[i]
  end

###################################################################
  
  def test
    $data.data.each_with_index do |ohlc, i|
      if in_position?
        determine_whether_to_exit( ohlc, i )
      else
        determine_whether_to_enter( ohlc, i )
      end
    end
    trade_results = @broker.change_recorder
    trade_count = trade_results.count
    win_count = trade_results.select {|t| t > 0 }.count
    loss_count = trade_count - win_count
    average_win = trade_results.select {|c| c > 0 }.inject(:+) / win_count
    average_loss = trade_results.select {|c| c < 0 }.inject(:+) / loss_count
    max_win = trade_results.max
    max_loss = trade_results.min
    
    { records:@broker.records, ending_balance:@broker.records[-1],
      loss_cut:@broker.loss_cut.to_f, e_ratio:e_ratio, trade_count:trade_count,
      win_count:win_count, loss_count:loss_count, average_win:average_win,
      average_loss:average_loss, max_win:max_win, max_loss:max_loss }
  end
  
  def e_ratio
    @broker.send( :e_ratio )
  end
  
  def enter_long( price )
    @broker.send( :enter_long, price )
  end
  
  def enter_short( price )
    @broker.send( :enter_short, price )
  end
  
  def exit_long( price )
    @broker.send( :exit_long, price )
  end
  
  def exit_short( price )
    @broker.send( :exit_short, price )
  end
  
  def in_position?
    @broker.send( :in_position? )
  end
  
  private
  
    def determine_whether_to_exit( ohlc, i )
      @broker.send( :update, ohlc, i )
      if exit_long?( ohlc, i )
        exit_long( ohlc[:close] )
      elsif exit_short?( ohlc, i )
        exit_short( ohlc[:close] )
      end
    end
  
    def determine_whether_to_enter( ohlc, i )
      if enter_long?( ohlc, i )
        enter_long( ohlc[:close] )
      elsif enter_short?( ohlc, i )
        enter_short( ohlc[:close] )
      else
        @broker.send( :do_nothing )
      end
    end
    
end