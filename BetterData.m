function [ pr use ] = BetterData( num_stocks, num_days, M_F, sig_F, gamma )
%%Generates data for a given number of stocks over a given number of days

%Parameters    
%num_stocks - # of stocks to generate data for
%num_days - # of days to generate data for
%M_F - annual average rate of return for the market
%sig_F - annual volatility of the market factor
%gamma - standard deviation of stock returns

%Return Values
%pr - price data represented as a matrix of dates and prices
%use - use data represented as dates and a zero and non-zero matrix

%%%%% CONSTANTS %%%%%
    %number of trading days in a year
    DAYS = 250;
    %length of each time step
    t = 1/DAYS;
    %min value allowed for sig_R
    min_sig = 0.1;
    %level of stock dependence on the market, in the range 0 to 1
    lam_R = 0.19;

%%%%% DATA CONSTRUCTION %%%%%

    %Create and fill dates matrix with num_days days
    dates = zeros(num_days, 1);
    temp_date = addtodate(now, num_days.*-1, 'day');
    for i=0:num_days-1
        dates(i+1, 1) = addtodate(temp_date, i, 'day');
    end
    
    R = zeros(num_days, num_stocks);
    Rs = zeros(num_days,num_stocks);
    prices = ones(num_days, num_stocks);
    delta = (1-lam_R)*M_F/sqrt(1-lam_R^2);

    M_R = normrnd(delta, gamma, [1 num_stocks]);
    
    for i=2:num_days
       Z = normrnd(0,1);
       %del_F = M_F.*t + sig_F.*Z.*sqrt(t);
       del_F = M_F.*t + sig_F.*Z.*t;
       Y = randn(1,num_stocks);
       for j=1:num_stocks
           %Can't divide by 0
           sig_R = max((lam_R + sqrt(1-lam_R^2).*(M_R(j)/M_F)), min_sig);
           sig_R = min(1, sig_R);
           %del_R = lam_R.*del_F + sqrt(1-lam_R^2).*(M_R(j).*t+sig_R.*Y(j).*sqrt(t));
           del_R = lam_R.*del_F + sqrt(1-lam_R^2).*(M_R(j).*t+sig_R.*Y(j).*t);
           Rs(i,j) = del_R;
           R(i,j) = R(i-1,j) + del_R;
           prices(i,j) = exp(R(i,j));
       end
    end
    
%    plot(1:1000,prices(1:1000,1),1:1000,prices(1:1000,2),1:1000,prices(1:1000,3),1:1000,prices(1:1000,4),1:1000,prices(1:1000,5),1:1000,prices(1:1000,6),1:1000,prices(1:1000,7),1:1000,prices(1:1000,8),1:1000,prices(1:1000,9),1:1000,prices(1:1000,10));
%     disp(Rs);
%     disp(R);
%     disp(prices);
    
    %concatenate dates and prices matrices
    pr = [dates prices];
    
    use = ones(num_days, num_stocks);
    use = [dates use];
    
end

