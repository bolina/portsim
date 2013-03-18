function [ clusters error ] = ClusterStocks(k, price_data, use_data) 

%clusters - a cell array containing k clusters of stocks, the stocks are
%           identified by their index in the price_data matrix
%error - a measure of the quality of the clustering, a higher error denotes
%        lower quality

    [~, returns, universe] = WindowData(price_data, use_data);
    num_use = length(universe);
    
    %average daily return for each stock
    mu = mean(returns, 2);
    
    %standard deviation of the returns for each stock
    s = std(returns,[],2);
    
    %per contains the performance of each stock's returns relative to its
    %average return and standard deviation. 1 if better, -1 if worse, 0 if
    %within the standard deviation
    dimen = size(returns);
    per = zeros(dimen);
    for i=1:dimen(1)
       for j=1:dimen(2)
           if ( returns(i,j)-mu(i) > mu(i)+s(i) )
               per(i,j) = 1;
           elseif ( returns(i,j)-mu(i) < mu(i)-s(i) )
               per(i,j) = -1;
           else
               per(i,j) = 0;
           end
       end
    end

    %matrix to hold the cross correlations between each stock's performance
    cors = zeros(num_use);
    
    centers = zeros(1,k);
    for i=1:k
        if (i>1)
            %correlations for the previously selected center
            c_cors = cors(index,:);
            min = 9999;
            %find the index of the stock least correlated with the previous 
            %center, making sure that it is not already a center
            for m=1:num_use
                cor = c_cors(m);
                if(cor < min && isempty(find(centers==m, 1)))
                   min = cor;
                   index = m;
                end
            end
        else
            %select the first center randomly
            index = round(rand(1)*(num_use-1))+1; 
        end
        %compute the cross correlations between the stock selected as a 
        %center and each other stock
        for j=1:num_use 
            cors(index, j) = xcorr(per(:,index),per(:,j),0,'coeff'); 
        end
        centers(i) = index;
    end
    
    misfit = 0;
    fit = 0;
    clusters = cell(1,k);   
    %for each stock, find the center most correlated with its performance,
    %then assign the stock to that center's cluster
    for n=1:num_use
        best_fit = -1;
        max = -9999;
        for o=1:k
            row = centers(o);
            if (cors(row,n) > max)
               max = cors(row,n);
               best_fit = o;
            end
            if(isnan(cors(row,n))==0)
                misfit = misfit+cors(row,n);
            end
        end
        %if no center is correlated with the stock, assign it randomly
        if (best_fit == -1)
            best_fit = round(rand(1)*(k-1))+1;
            max = 0;
        end
        fit = fit + max;
        misfit = misfit - max;
        clusters{best_fit} = [clusters{best_fit} universe(n)];
    end
    error = fit - misfit/(k-1);
end