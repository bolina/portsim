function [ p ] = BuildPortfolio(time_index, price_data, use_data, capital, PHOR, alg)
%%Returns an array containing optimal weights for an allocation of capital
%%over the provided stocks based on an argument-specified algorithm

%Parameters
%time_index - index of the date specified to build a portfolio on
%price_data - matrix containing price data for stocks on many dates
%use_data - matrix specifying which stocks are usable on a given date
%capital - total capital allocated for building a portfolio
%PHOR - size, in days, of the price history window 
%alg - which construction algorithm should be used

    %risk free rate
    rfr = 0.001;
    
    %transaction cost of trading
    tr_cost = 0.0003;
    
    %Account for transaction costs when reallocating a portfolio
    capital = capital*(1-tr_cost);
    
    %construct the portfolio using the chosen algorithm
    switch alg
        case 'simple_uniform'
            p = SimpUni();
        case 'markowitz'
            p = Markowitz();
        otherwise
            error('Unknown Selection Algorithm');
    end
    
    %construct a simple uniform portfolio placing an equal amount of
    %capital into each available stock
    function [ port ] = SimpUni()
        pr = price_data(time_index,2:end);
        us = use_data(time_index,2:end);
        port = pr.*us;
        num_use = 0;
        for i=1:length(us)
            if(us(i)==1 && port(i)>0)
                num_use = num_use+1;
            end
        end
        unit_cap = capital/num_use;
        for j=1:length(port)
            if (port(j)>0)
                port(j)=unit_cap/port(j);
            end
        end
    end

    function [ port ] = Markowitz()    
        %risk free rate
        rfr = 0.001;
        start_time = time_index-PHOR;
        
        %extract price data within history window
        pr = price_data(start_time:time_index, 2:end);
        dimen = size(pr);
        
        curr_500 = use_data(time_index, 2:end);
        
        num_use = length(curr_500(curr_500~=0));
        
        stock_values = zeros(dimen(1), num_use);
        for row=1:dimen(1)
            used = 0;
            for col=1:dimen(2)
                if (curr_500(col) == 1)
                    used = used+1;
                    stock_values(row, used) = pr(row,col).*curr_500(col);
                end
            end     
        end
        
        %disp(stock_values(1:8,1:8));
        dimen = size(stock_values);
        returns = zeros(dimen);
        %fill returns with the day by day return on each stock
        for row=2:dimen(1)
           for col=1:dimen(2)
                cur_val = stock_values(row, col);
                pre_val = stock_values(row-1,col);
                if (pre_val ~= 0)
                    returns(row, col) = (cur_val-pre_val)/pre_val;
                end
           end
        end
        
        %add a column representing an investment in a risk free instrument
        returns = [returns ones(dimen(1),1).*rfr];
        
        avg_r = mean(returns);
        %overall_avg = mean(avg_rates);
        cvr = cov(returns);
        
        t_rate = min(avg_r);
        port_weights = quadprog(cvr, zeros(length(cvr)), -1, zeros(1,length(cvr)), avg_r', t_rate);
        port = port_weights/sum(port_weights);
    end

end