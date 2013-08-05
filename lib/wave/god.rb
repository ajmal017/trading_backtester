require_relative "trader"

$ACCOUNT_BALANCE ||= 1000

class God
  attr_accessor :traders, :data, :histories
  def initialize( data=nil )
    @traders = []
    $data = data
    @histories = []
  end
  
  def create_traders( n )
    [-0.1, -0.15, -0.18, -0.2, -0.22, -0.25, -0.3, -0.5].each_with_index do |k, i|
      @traders << [i, Trader.new( $ACCOUNT_BALANCE, k )]
    end
    # n.times { @traders << Trader.new( $ACCOUNT_BALANCE ) }
  end
  
  def test_traders
    @traders.map do |trader|
      @histories << trader[1].send( :test )
    end
  end
  
  def read_data( file )
    @data = $data = PriceData.new( file )
  end
  
  def see_results
    @histories.sort {|a, b| a[:records][-1] <=> b[:records][-1] }.map do |trade_result|
      puts "##############################################"
      trade_result.each_with_index do |pair, index|
        puts "#{pair[0]}: #{pair[1]}" unless index==0
      end
      puts "##############################################"
    end
  end
end