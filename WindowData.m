function [ stock_values returns universe ] = WindowData(price_data, use_data)
    %universe contains the index of each stock denoted usable by the binary
    %use_data matrix
    universe = find(use_data);

    dimen = size(price_data);
    
    %stock_values will contain prices within the history window for all
    %usable stocks in the universe
    stock_values = zeros(dimen(1), length(universe));
    for row=1:dimen(1)
        for col=1:length(universe)
            stock_values(row, col) = price_data(row, universe(col));
        end    
    end

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
end