function [ c ] = PortfolioAnalysis(start_time, total_time, price_data, use_data, capital, NHOR, PHOR, num_use, alg)
%%Builds and evaluates portfolios over the given time period.

%Parameters
%start_time - starting date for the simulation
%total_time - total number of days to run the simulation
%price_data - matrix containing price data for stocks on many dates
%use_data - matrix specifying which stocks are usable on a given date
%capital - starting capital allocated for building a portfolio
%NHOR - number of days to hold a portfolio before constructing a new one
%num_use - number of usable stocks on any given day
%alg - which construction algorithm should be used

    %calculate the number of periods required to complete the simulation
    periods = total_time/NHOR;
    
    %allocate an array of zeros equal to the number of periods
    c = zeros(1, periods);
    
    %intialize current time and capital values
    curr_time = start_time;
    curr_cap = capital;
    
    %loop over the number of periods building a portfolio in each period
    %and calculating its value at the end of each period
    for k=1:periods
        %build a portfolio at the current time using the selected algorithm
        port = BuildPortfolio(curr_time, price_data, use_data, curr_cap, PHOR, num_use, alg);
        
        %add NHOR days to the current time
        curr_time = addtodate(curr_time, NHOR, 'day');
        
        %calculate the capital value of the portfolio at the new date and
        %use this value as the new current capital value
        curr_cap = CalcCapital(datevec(curr_time), port);
        
        %store the capital value in the capital array
        c(k) = curr_cap;
    end

    %helper function which returns the value of a portfolio at a given time
    function [ cap ] = CalcCapital(time, portfolio)
        dimen = size(price_data);
        
        %iterate over the price data until the correct date is found
        i = 1;
        while( CompareDates( datevec(price_data(i, 1) ), time, 3) ~= 1)
            i = i+1;
            assert(i <= dimen(1));
        end
        
        %sum up the value of the portfolio by multiplying shares held by
        %their prices at the given time
        sum = 0;
        for j=2:dimen(2)
            sum = sum+(portfolio(j-1)*price_data(i, j));
        end
        cap = sum;
    end
end