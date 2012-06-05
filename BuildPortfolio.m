function [ p ] = BuildPortfolio(time, price_data, use_data, capital, PHOR, num_use, alg)
%%Returns an array contain

%Parameters
%time - date that the portfolio is to be constructed on
%price_data - matrix containing price data for stocks on many dates
%use_data - matrix specifying which stocks are usable on a given date
%capital - total capital allocated for building a portfolio
%PHOR -
%num_use - number of usable stocks on any given day
%alg - which construction algorithm should be used

    %If time is passed as a string, convert it to datenum
    build_time = time;
    if (ischar(build_time))
        build_time = datenum(time);
    end
    date_info = datevec(build_time);

    %Construct the portfolio using the chosen algorithm
    switch alg
        case 'simple_uniform'
            p = SimpUni();
        otherwise
            error('Unknown Selection Algorithm');
    end
    
    %Construct a simple uniform portfolio placing an equal amount of
    %capital into each available stock
    function [ port ] = SimpUni()
        unit_cap = capital/num_use;
        [pr us] = GetTimeData(date_info);
        port = pr.*us;
        for i=1:length(port)
            if (port(i)~=0)
                port(i)=unit_cap/port(i);
            end
        end
    end

    function [ prices usable ] = GetTimeData(date_vec)
        dimen = size(price_data);
        prices = zeros(1, dimen(2)-1);
        for i=1:dimen(1)
            temp_date_info = datevec(price_data(i, 1));
            if (CompareDates(temp_date_info, date_vec, 3))
                prices = price_data(i,2:end);
            end
        end
        dimen = size(use_data);
        usable = zeros(1, dimen(2)-1);
        for i=1:dimen(1)
            temp_date_info = datevec(use_data(i, 1));
            if (CompareDates(temp_date_info, date_vec, 3))
                usable = use_data(i,2:end);
            end
        end
    end
end