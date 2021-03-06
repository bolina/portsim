function [ c ] = PortfolioAnalysis(price_data, use_data)
%%Builds and evaluates portfolios over the given time period.

%Parameters
%start_time - starting date for the simulation
%total_time - total number of days to run the simulation
%price_data - matrix containing price data for stocks over many days
%use_data - matrix specifying which stocks are usable on a given date
%capital - starting capital allocated for building a portfolio
%NHOR - number of days to hold a portfolio before constructing a new one
%alg - which construction algorithm should be used

%Return Values
%c - capital value of the portfolio for each day of the simulation

    params = Config();
    
    %if time is passed as a string, convert it to datenum
    curr_time = params.start_time;
    if (ischar(curr_time))
        curr_time = datenum(curr_time);
    end
    date_info = datevec(curr_time);

    dimen = size(price_data);
    
    %iterate over the price data until the starting date is found
    date_index = 1;
    while(CompareDates( datevec(price_data(date_index, 1) ), date_info, 3) ~= 1)
        date_index = date_index+1;
        assert(date_index <= dimen(1));
    end

    %allocate an empty array with space for each day of the simulation
    c = zeros(1, params.total_time);
    
    %initialize current capital
    curr_cap = params.capital;
    
    %loop over the number of days in the simulation constructing a new
    %portfolio at the beginning and after every NHOR days
    for k=1:params.total_time
        if (k == 1 || mod(k,params.NHOR) == 0)
            %get use data at the time of building the portfolio
            use = use_data(date_index, 2:end);
            
            %get price data for all stocks in the history window
            start_time = date_index-params.PHOR;
            pr = price_data(start_time:date_index, 2:end);
            
            %build a portfolio at the current time using the selected algorithm
            port = BuildPortfolio(pr, use);
            
            %Account for transaction costs when reallocating a portfolio
            curr_cap = curr_cap*(1-params.tr_cost);
            shares = port*curr_cap;
            for n=1:length(shares)
               if (shares(n) > 0)
                   shares(n) = shares(n)/price_data(date_index, n+1);
               end
            end
        end
        
        %calculate the capital value of the portfolio on each day and
        %use this value as the new current capital value
        curr_cap = CalcCapital(date_index, shares);

        %store the capital value in the capital array
        c(k) = curr_cap;
        
        %increment the time index to use data from the next time period
        date_index = date_index+1;
    end

    %helper function which returns the value of a portfolio at a given time
    function [ cap ] = CalcCapital(time_index, shares)
        dimen = size(price_data);
        
        %find the capital sum of the portfolio by multiplying number of 
        %shares held by the price of each share at the given time
        sum = 0;

        for j=2:dimen(2)
            stock_price = price_data(time_index, j);
            if (stock_price == 0 && shares(j-1) ~= 0)
            %Company has either gone out of business or been acquired
                stock_price = RecentPrice(time_index, j);
            end
            sum = sum+(shares(j-1)*stock_price);
        end
        cap = sum;
    end

    function [ pri ] = RecentPrice(time_index, stock_index)
        for i=time_index:-1:time_index-params.PHOR
            if (price_data(i, stock_index) ~= 0)
               pri = price_data(i, stock_index);
               break;
            end
        end
        if (pri < 10)
            pri = 0;
        end
    end
end