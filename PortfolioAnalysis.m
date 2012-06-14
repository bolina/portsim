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

    %if time is passed as a string, convert it to datenum
    curr_time = start_time;
    if (ischar(curr_time))
        curr_time = datenum(time);
    end
    date_info = datevec(curr_time);

    %iterate over the price data until the starting date is found
    date_index = 1;
    while( CompareDates( datevec(price_data(date_index, 1) ), date_info, 3) ~= 1)
        date_index = date_index+1;
        assert(date_index <= dimen(1));
    end

    %allocate an empty array with space for each day of the simulation
    c = zeros(1, total_time);
    
    %initialize current capital
    curr_cap = capital;
    
    %loop over the number of days in the simulation constructing a new
    %portfolio at the beginning and after every NHOR days
    for k=1:total_time
        if (k == 1 || mod(k,NHOR) == 0)
            %build a portfolio at the current time using the selected algorithm
            port = BuildPortfolio(date_index, price_data, use_data, curr_cap, PHOR, num_use, alg);
        end
        
        %calculate the capital value of the portfolio on each day and
        %use this value as the new current capital value
        curr_cap = CalcCapital(date_index, port);
        
        %store the capital value in the capital array
        c(k) = curr_cap;
        
        %increment the current time by one day
        curr_time = addtodate(curr_time, 1, 'day');
        date_index = date_index+1;
    end

    %helper function which returns the value of a portfolio at a given time
    function [ cap ] = CalcCapital(time_index, portfolio)
        dimen = size(price_data);
        
        %sum up the value of the portfolio by multiplying shares held by
        %their prices at the given time
        sum = 0;
        for j=2:dimen(2)
            sum = sum+(portfolio(j-1)*price_data(time_index, j));
        end
        cap = sum;
    end
end