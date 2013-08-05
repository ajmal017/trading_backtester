require_relative 'wave/god'

# n, m = ARGV[0].to_i, ARGV[1].to_i

god = God.new

# Data file specified and read
file = "data/usdjpy60.csv"



god.read_data( file )
god.create_traders(1)
god.test_traders
god.see_results