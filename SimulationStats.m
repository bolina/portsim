function [ ann_return ann_sharpe avg_dd ] = SimulationStats( c )
%%Calculates and displays several summary statistics for the simulation

%Parameters
%c - array containing the capital valuations of the portfolios constructed
%    over each day in the simulation

%Return Values
%ann_return - annual rate of return for series c
%ann_sharpe - annual sharpe ratio for series c
%avg_dd - average annual maximum drawdown for series c

    %average number of trading days in a year
    DAYS = 250;
    
    %number of trading years
    num_years = ceil(length(c)/DAYS);
    
    %array for storing maximum drawdown of each year
    max_draws = zeros(1, num_years);
    
    %calculate daily cumulative rate of return and store in cror 
    cror = zeros(1, length(c));
    for i=2:length(c)
       cror(i) = (c(i)-c(i-1))/c(1); 
    end
    
    %for each trading year in the simulation,
    %calculate maximum drawdown
    for i=1:num_years
        if (length(cror)-DAYS*(i-1) < DAYS)
            slice = cror(1+(i-1)*DAYS:end);
        else
            slice = cror(1+(i-1)*DAYS:DAYS+(i-1)*DAYS);
        end
        peak = -99999;
        DD = zeros(1, length(slice));
        for j=1:length(slice)
            %code to calculate maximum annual draw downs
            if (slice(j) > peak && slice(j) ~= 0) 
                peak = slice(j);
            else
                DD(j) = peak - slice(j);
                if (DD(j) > max_draws(i))
                    max_draws(i) = DD(j);
                end
            end
        end
    end
    
    %calculate daily rate of return and store in ror 
    ror = zeros(1, length(c));
    for i=2:length(c)
       ror(i) = (c(i)-c(i-1))/c(i-1); 
    end
    
    avg_daily = mean(ror);
    daily_std = std(ror);
    
    ann_return = avg_daily*DAYS;
    ann_sharpe = (avg_daily/daily_std)*sqrt(250);
    avg_dd = mean(max_draws);
    
end

