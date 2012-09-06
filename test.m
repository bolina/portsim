function [cap_values] = test()
    t_time = 1000;
    n_stks = 1000;
    temp_date = addtodate(now, t_time*(-1), 'day');
    NHOR = 20;
    cap = 1;
    [prices uses] = BetterData(n_stks,t_time, -0.05,0.25,0.1);
    cap_values = PortfolioAnalysis(temp_date, t_time, prices, uses, cap, NHOR, 0, 'simple_uniform');
    period_returns = SimulationStats(cap_values, NHOR);
    SimPlot(cap_values, period_returns, prices);
end