function [ ] = SimPlot( cap_arr, period_ror )
%%Plots the capital value of the portfolio versus time and the rate of 
%%return experienced in each trading period

%Parameters
%cap_arr - array containing the capital value of the simulation portfolio
%          on each day in the simulation
%period_ror - array containing the rate of return experienced between each
%             trading period, defined by NHOR, in the simulation

    subplot(2,1,1);
    plot(1:length(period_ror),period_ror);
    title('Trading Period Rate of Return');
    subplot(2,1,2);
    plot(1:length(cap_arr),cap_arr);
    title('Capital Value versus Time');

end

