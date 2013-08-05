require 'bigdecimal'
require_relative "price_data"
require_relative "trade"

class Broker
  attr_accessor :account_balance, :spread, :trade
  attr_reader :records, :mfes, :maes, :change_recorder, :loss_cut
  
  def initialize( account_balance, loss_cut=account_balance )
    @spread = 0
    @account_balance = account_balance
    @records = [account_balance]
    @change_recorder = []
    @mfes = [0]
    @maes = [0]
    @trade = nil                              # will be of Trade class
    @loss_cut = BigDecimal.new( loss_cut, 2 ) #BigDecimal.new( -0.25, 2 ) # -@account_balance * 0.02
    @trade_size = ( @account_balance * 0.02 / @loss_cut.abs ).to_i
  end
  
  def enter_long( price )
    if short?
      close_position( price )
    else
      set_trade_size
      @trade = Trade.new( :l, price + @spread )
    end
  end
  
  def enter_short( price )
    if long?
      close_position( price )
    else
      set_trade_size
      @trade = Trade.new( :s, price - @spread )
    end
  end
  
  def long?
    @trade ? @trade.long? : false
  end
  
  def short?
    @trade ? @trade.short? : false
  end
  
  def in_position?
    long? or short?
  end
  
  def loss_cut?( ohlc, i )
    if long?
      ( ohlc[:low] - @trade.price ) < @loss_cut
    elsif short?
      ( @trade.price - ohlc[:high] ) < @loss_cut
    else
      0
    end
  end
  
  def close_position( price )
    return unless long? or short?
    record_results( price )
    @trade = nil
  end
  
  alias_method :exit_long, :close_position
  alias_method :exit_short, :close_position
  
  def update( ohlc, i=1 )
    if long?
      @trade.send( :update, ohlc, i )
      if loss_cut?( ohlc, i )
        close_position( @trade.price + @loss_cut )
      elsif @account_balance + (ohlc[:low] - @trade.price) * @trade_size < 0
        close_position( ohlc[:low] )
      else
        do_nothing
      end
    elsif short?
      @trade.send( :update, ohlc, i )
      if loss_cut?( ohlc, i )
        close_position( @trade.price - @loss_cut )
      elsif @account_balance + (@trade.price - ohlc[:high]) * @trade_size < 0
        close_position( ohlc[:high] )
      else
        do_nothing
      end
    end
  end
  
  def do_nothing
    @records << @account_balance.round(2)
  end
  
  def e_ratio
    n, d = @mfes.inject(:+), @maes.inject(:+).abs
    d != 0 ? (n / d).round(2) : 0                        # makes sure denominator is non-zero
  end
  
  private
  
    def record_results( price )
      if @trade.trade_type == :l
        profit = ( price - @trade.price - @spread ) * @trade_size
        @account_balance += profit
        @change_recorder << profit
      else
        profit = ( @trade.price - price - @spread ) * @trade_size
        @account_balance += profit
        @change_recorder << profit
      end
      @records << @account_balance.round(2)
      @mfes << @trade.mfe
      @maes << [@trade.mae, @loss_cut].max
    end
    
    def set_trade_size
      @trade_size = ( @account_balance * 0.04 / @loss_cut.abs ).to_i 
    end
    
end