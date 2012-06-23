function [ m r ] = LoadData(pricefile, usefile, numeric)
%%Loads price and use data for stocks from the given text files

%%Parameters
%pricefile - name of text file to read price data from
%usefile - name of text file to read use data from
%numeric - boolean indicator if text file is all numeric data

    if (numeric)
        %if file contains only numeric data, use built-in dlmread
        m = dlmread(pricefile);
        r = dlmread(usefile);
    else
        %if file contians mixed data use ReadData function
        m = ReadData(pricefile);
        r = ReadData(usefile);
    end

    function [ data ] = ReadData(filename)
        %open filename for reading
        data_file = fopen(filename, 'r');

        %read data into a character array
        char_data = fread(data_file,inf,'*char').';

        %reading is completed so close the file handle
        fclose(data_file);

        %split character array around whitespace
        parts = regexp(char_data,'\s+','split');
        parts = parts(1:end-1);

        num_cols = 0;
        %search for the next appearance of a date to determine the number
        %of columns needed for the data
        for i=2:length(parts)
           %match a datestring
           match = regexp(parts(i), '\d{1,2}-\w+-\d{4}');

           %if the element matches a datestring, set the index and
           %break out of the loop
           if (match{1})
               num_cols = i-1;
               break;
           end
        end

        %reshape the parts array into a matrix with the correct dimensions
        temp_data = reshape(parts, num_cols, []).';

        dimen = size(temp_data);
        dates = zeros(dimen(1),1);
        %store datenums in dates
        for j=1:dimen(1)
            temp_date = [temp_data{j,1} temp_data{j,2}];
            dates(j) = datenum(temp_date);
        end

        %convert stock information from string to double
        stock_info = str2double(temp_data(1:end,3:end));

        %concatenate datenums and stock doubles
        data = [dates stock_info];
    end

end