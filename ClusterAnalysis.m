function [ c ] = ClusterAnalysis(price_data, use_data)
%%Builds and evaluates portfolios over the given time period.

%Parameters
%price_data - matrix containing price data for stocks over many days
%use_data - matrix specifying which stocks are usable on a given date

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
            use = use_data(date_index, 2:end);
            all_pr = price_data(1:date_index, 2:end);
            
            start_time = date_index-params.PHOR;
            pr = price_data(start_time:date_index, 2:end);
            dim = size(pr);
            
            %break usable stocks into correlated clusters
            clusters = ClusterStocks(params.k, all_pr, use);
            
            ports = zeros(params.k, length(use));
            
            %build a portfolio for each individual cluster
            %
            super_prices = zeros(dim(1),params.k);
            for l=1:params.k
                c_use = zeros(1,length(use));
                members = clusters{l};
                for s=1:length(members)
                    c_use(members(s)) = 1;
                    for t=1:dim(1)
                       super_prices(t,l) =  super_prices(t,l) + pr(t,members(s));
                    end
                end
                ports(l,:) = BuildPortfolio(pr, c_use);
            end
            
            %denote each super stock as usable
            super_use = ones(1, params.k);
            
            %build a portfolio at the current time using the super stocks
            super_port = BuildPortfolio(super_prices, super_use);
            
            %the final portfolio will be constructed by multiplying the
            %weight given to each super stock by the individual weights
            %given to each stock within the super stock
            port = zeros(1,length(use));
            for u=1:length(super_port)
                port = port+(super_port(u)*ports(u,:));
            end 
            
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