function [ ] = SimPlot( cap_arr, period_ror, prices )
%%Plots the capital value of the portfolio versus time and the rate of 
%%return experienced in each trading period

%Parameters
%cap_arr - array containing the capital value of the simulation portfolio
%          on each day in the simulation
%period_ror - array containing the rate of return experienced between each
%             trading period, defined by NHOR, in the simulation
    
    subplot(2,2,[3 4]);
    plot(1:1000,prices(1:1000,11),1:1000,prices(1:1000,2),1:1000,prices(1:1000,3),1:1000,prices(1:1000,4),1:1000,prices(1:1000,5),1:1000,prices(1:1000,6),1:1000,prices(1:1000,7),1:1000,prices(1:1000,8),1:1000,prices(1:1000,9),1:1000,prices(1:1000,10));
    title('Prices for 10 Random Stocks');
    subplot(2,2,1);
    plot(1:length(period_ror),period_ror);
    title('Trading Period Rate of Return');
    subplot(2,2,2);
    plot(1:length(cap_arr),cap_arr);
    title('Capital Value versus Time');

end

