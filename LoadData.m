function [ m r ] = LoadData(pricefile, usefile)
%%Loads price and use data for stocks from the given text files

%     tempm = ReadData(pricefile);
%     tempr = ReadData(usefile);
%     m = CellConvert(tempm);
%     r = CellConvert(tempr);
    
%     function [ data ] = ReadData(filename)
%         data_file = fopen(filename, 'r');
%         
%         line = fgetl(data_file);
%         row = 1;
%         while ischar(line)
%             parts = strread(line, '%s', 'delimiter', ' ');
%             assert(length(parts) > 2);
%             parts = parts';
%             for i=1:length(parts)
%                 if (i==1)
%                     data(row, i) = strcat(parts(1), {' '}, parts(2));
%                 elseif (i > 2)
%                     data(row, i-1) = parts(i);
%                 end
%             end
%             row = row+1;
%             line = fgetl(data_file);
%         end
%         fclose(data_file);
%     end

%    text = fileread(pricefile);

    m = dlmread(pricefile);
    r = dlmread(usefile);

end