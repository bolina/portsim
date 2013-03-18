function [ params ] = Config()
    params.start_time = '09/11/1989';
    params.total_time = 5614;
    params.PHOR = 60;
    params.NHOR = 20;
    params.capital = 1;
    params.lambda = 0.4;
    params.tr_cost = 0.0003;
    params.k = 3;
    params.alg = 'mdd';
    params.pricefile = 'stock_prices.txt';
    params.usefile = 'S&P100NoRFR.txt';
end