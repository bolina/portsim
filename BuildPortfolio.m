function [ p ] = BuildPortfolio(time_index, price_data, use_data, capital, PHOR, num_use, alg)
%%Returns an array contain

%Parameters
%time_index - index of the date specified to build a portfolio on
%price_data - matrix containing price data for stocks on many dates
%use_data - matrix specifying which stocks are usable on a given date
%capital - total capital allocated for building a portfolio
%PHOR -
%num_use - number of usable stocks on any given day
%alg - which construction algorithm should be used

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
        unit_cap = capital/num_use;
        pr = price_data(time_index,2:end);
        us = use_data(time_index,2:end);
        port = pr.*us;
        for i=1:length(port)
            if (port(i)~=0)
                port(i)=unit_cap/port(i);
            end
        end
    end
end