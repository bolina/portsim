function [ p ] = BuildPortfolio(time_index, price_data, use_data, capital, PHOR, alg)
%%Returns an array contain

%Parameters
%time_index - index of the date specified to build a portfolio on
%price_data - matrix containing price data for stocks on many dates
%use_data - matrix specifying which stocks are usable on a given date
%capital - total capital allocated for building a portfolio
%PHOR - size, in days, of the price history window 
%alg - which construction algorithm should be used
    
    %transaction cost of trading
    tr_cost = 0.0003;
    
    %construct the portfolio using the chosen algorithm
    switch alg
        case 'simple_uniform'
            p = SimpUni();
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
        capital = capital*(1-tr_cost);
        unit_cap = capital/num_use;
        for j=1:length(port)
            if (port(j)>0)
                port(j)=unit_cap/port(j);
            end
        end
    end
end