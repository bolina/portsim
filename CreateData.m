function [ m r ] = CreateData(num_stocks, num_days, num_use, record)
%%Generates data for a given number of stocks over a given number of days
%%The generated data can also be written to the text files, 
%%'RandomPriceData.txt'and 'RandomUseData.txt'

%Parameters    
%num_stocks - # of stocks to generate data for
%num_days - # of days to generate data for
%num_use - # of stocks that will have nonzero use values in any time period
%record - flag indicating whether data should be written to file or not

%Return Values
%m - price data represented as a matrix of dates and prices
%r - use data represented as dates and a zero and non-zero matrix

    %Assertion to prevent indexing errors
    assert(num_use < num_stocks);
    
    %%%%%Generating Price Data%%%%%
    
    %Create and fill dates matrix with num_days days
    dates = zeros(num_days, 1);
    temp_date = addtodate(now, num_days.*-1, 'day');
    for i=0:num_days-1
        dates(i+1, 1) = addtodate(temp_date, i, 'day');
    end
    
    %Lower and upper limits for random prices generated
    lower = 0;
    upper = 50;
    
    %Generate random numbers to use as prices for the stocks
    rand_nums = rand(num_days, num_stocks);
    rand_nums = lower + (upper-lower).*rand_nums;

    %Concatenate dates and rand_num matrices to form price data matrix m
    m = [dates rand_nums];
    
    %%%%%Generating use data%%%%%
    
    %Initialize a matrix of zeros big enough to hold use data for 
    %num_stocks stocks over num_days days
    use_matrix = zeros(num_days, num_stocks);
    
    %Iterate over each row/day and randomly select num_use stocks that
    %will be able to be used on that day
    for i=1:num_days   
        %Generate a random permutation of integers from 1 to num_stocks
        indices = randperm(num_stocks);
        
        %Take the first num_use of these integers to use as indices
        indices = indices(1:num_use);
        
        %Set the value at each random index to 1
        for j=1:num_use
            use_matrix(i, indices(j)) = 1;
        end
    end
    
    %Concatenate dates and use_matrix to form use data matrix r
    r = [dates use_matrix];
    
    if (record)
        %Write generated data to text files
        dlmwrite('RandomPriceData.txt', m, 'delimiter', '\t');
        dlmwrite('RandomUseData.txt', r, 'delimiter', '\t');
    end
    
%    %Subfunction for writing data matrices to text files
%     function [] = WriteData(filename, data)
%         %Open or create a text file for writing
%         data_file = fopen(filename, 'w');
%     
%         %Write the generated data to the text file
%         for row=1:num_days
%             for col=1:num_stocks+1
%                 if (col==1)
%                  %Use datestr() to convert the datenum to a string
%                     fprintf(data_file, '%s ', datestr(data(row,col)));
%                 else
%                     fprintf(data_file, '%5.2f ', data(row,col));
%                 end
%             end
%             fprintf(data_file, '\n');
%         end    
%         fclose(data_file);
%     end

end