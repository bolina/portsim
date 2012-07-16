function [ r ] = SimulationStats( c )
%%Calculates and displays several summary statistics for the simulation

%Parameters
%c - array containing the capital valuations of the portfolios constructed
%    for each day in the simulation

    NHOR = 20;
    %average number of trading days in a year
    DAYS = 250;
    
    %number of trading years
    num_years = ceil(length(c)/DAYS);
    
    %array for storing maximum drawdown of each year
    max_draws = zeros(1, num_years);
    
    %array for storing annual cumulative rate of return for each year
    ann_crors = zeros(1, num_years);
    
    %for each trading year in the simulation,
    %calculate maximum drawdown and annual rate of return
    for i=1:num_years
        if (length(c)-DAYS*(i-1) < DAYS)
            slice = c(1+(i-1)*DAYS:end);
        else
            slice = c(1+(i-1)*DAYS:DAYS+(i-1)*DAYS);
        end
        cror = 0;
        peak = -99999;
        DD = zeros(1, length(slice));
        for j=1:length(slice)
            %storing the sum of day by day returns in cror
            if (j > 1)
                cror = cror+((slice(j)-slice(j-1))/slice(j-1));
            end
            %code to calculate maximum annual draw downs
            if (slice(j) > peak) 
                peak = slice(j);
            else
                DD(j) = 100.0 * (peak - slice(j)) / peak;
                if (DD(j) > max_draws(i))
                    max_draws(i) = DD(j);
                end
            end
        end
        ann_crors(i) = cror;
    end
    
    periods = ceil(length(c)/NHOR);
    r = zeros(1, periods);
    index = 1;
    for i=1:length(c)
        if (i == NHOR)
            r(index) = (c(i)-c(1))/c(1);
            index = index + 1;
        elseif (mod(i,NHOR) == 0)
            r(index) = (c(i)-c(i-NHOR))/c(i-NHOR);
            index = index + 1;
        end
    end
    
    %risk free rate
    rfr = 0.045;
    
    %avg annual cumulative rate of return
    acror = mean(ann_crors);
    
    %calculate sharpe ratio
    sharpe = (acror-rfr)/std(ann_crors);
   
    %avg annual drawdown
    avg_draw = mean(max_draws);
    
    %calculate sterling ratio
    sterling = acror/abs(avg_draw-.1);
    
    disp('Avg Annual Cumulative Rate of Return:');
    disp(acror);
    disp('Max Draw Downs:');
    disp(max_draws);
    disp('Avg Annual Draw Down:');
    disp(avg_draw);
    disp('Sterling Ratio:');
    disp(sterling);
    disp('Sharpe Ratio');
    disp(sharpe);

end

