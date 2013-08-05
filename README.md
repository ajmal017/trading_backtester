#Trading strategy back tester
###Currency trading strategy back tester
Takes in CSV files as input and outputs results of the trading strategy for the given strategy for the given period.

###Input
Create a folder at "wave3/data" and put the input CSV files within.
Then, open wave3/lib/wave.rb and modify the name of the file. For example, if you have a data file named "usdjpy60.csv" in your "wave3/data" folder:

    # in wave3/lib/wave.rb
    ...
    file = "data/usdjpy60.csv"
    ...

and save.

###How to run the program
After navigating to the file in your console, run the program by:

    $ ruby lib/wave.rb

###Output
Output will provide a list of results using different stop loss levels. The stop loss levels used are defined in ./lib/wave/god.rb and can be changed to suit your trading security and desired risk levels.

###Interpretation of results
* Ending balance: The ending balance after trading with the given strategy, starting with initial investment of $1000.
* Loss cut: The loss cut distance from the entry point, based on ./lib/wave/god.rb
* E_ratio: The E-Ratio is defined as Maximum Favorable Excursion (MFE) / Maximum Averse Excursion (MAE). The higher the better.
* Trade count: Number of trades made for the given strategy over the given period.
* Win count: Number of trades exited with a profit.
* Loss count: Number of trades exited with a loss.
* Average win: The average profit earned over all the win trades.
* Average loss: The average loss suffered over all the loss trades.
* Maximum win: The most profitable trade traded over the period.
* Maximum loss: The largest single loss incurred over the period.

###Disclaimer
The results are merely suggestive and not to be taken seriously.