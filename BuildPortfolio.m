function [ p ] = BuildPortfolio(price_data, use_data)
%%Returns an array containing optimal weights for an allocation of capital
%%over the provided stocks based on an argument-specified algorithm

%Parameters
%time_index - index of the date specified to build a portfolio on
%price_data - matrix containing price data for stocks on many dates
%use_data - matrix specifying which stocks are usable on a given date
%capital - total capital allocated for building a portfolio
%PHOR - size, in days, of the price history window 
%alg - which construction algorithm should be used

    params = Config();
    
    lambda = params.lambda;
    PHOR = params.PHOR;
    
    %construct the portfolio using the chosen algorithm
    switch params.alg
        case 'simple_uniform'
            p = SimpUni();
        case 'markowitz'
            p = Markowitz();
        case 'mdd'
            p = MDD();
        case 'min_mdd'
            p = MinMDD();
        case 'var_weighted'
            p = VarWeighted();
        otherwise
            error('Unknown Selection Algorithm');
    end
   
    %construct a simple uniform portfolio placing an equal amount of
    %capital into each available stock
    function [ port ] = SimpUni()
        port = zeros(1, length(use_data));
        universe = find(use_data);
        num_use = length(universe);
        for i=1:num_use
           port(universe(i)) = 1/num_use; 
        end
    end

    function [ port ] = Markowitz()
        [~, returns, universe] = WindowData(price_data, use_data);
                
        avg_r = mean(returns);
        min_r = min(avg_r);
        max_r = max(avg_r);
        
        cvr = cov(returns);

        L = length(cvr);
        opts = optimset('Algorithm','active-set','Display','off');
        
        target = lambda*max_r + (1-lambda)*min_r;
        theta = quadprog(cvr, zeros(L,1), [], [], avg_r, target, zeros(L,1), ones(L,1), zeros(L,1), opts);
        p_wts = theta;
        
        %normalize the weights so that they sum to 1
        p_wts = p_wts/sum(p_wts);
        
        port = zeros(1, length(use_data));
        
        for i=1:length(universe)
           port(universe(i)) = p_wts(i);
        end
    end

    function [ port ] = MDD()
        [stock_values, ~, universe] = WindowData(price_data, use_data);
        
        dimen = size(stock_values);
        R = zeros(dimen);
        %fill R with the day by day cumulative return for each stock
        for row=2:dimen(1)
           for col=1:dimen(2)
                cur_val = stock_values(row, col);
                org_val = stock_values(1,col);
                if (org_val ~= 0)
                    R(row, col) = (cur_val-org_val)/org_val;
                end
           end
        end
        
        num_use = length(universe);
        %uniform weights
        uni = ones(num_use,1)/num_use;
        draw = R*uni;
        
        %Code to Calculate Maximum Drawdown over this period when using
        %a uniform portfolio allocation
        DD = zeros(length(draw));
        MDD = 0;  
        peak = -99999;
        for i = 1:length(draw)
          if (draw(i) > peak && draw(i) ~= 0) 
            peak = draw(i);
          end
          %DD(i) = (peak - draw(i)) / peak;
          DD(i) = peak-draw(i);
          if (DD(i) > MDD)
            MDD = DD(i);
          end
        end
        
        Ot = zeros(PHOR+1,1);
        It = eye(PHOR+1);
        On = zeros(num_use, 1);
        
        f = -1*[0; Ot; R(end, 1:end)'];
        A = [Ot It -1*R; Ot -1*It R; [It Ot]+[Ot -1*It] Ot*On'];
        b = [lambda*MDD*ones(PHOR+1,1); Ot; Ot];
        Aeq = [1 Ot' On'; 0 Ot' ones(1,num_use)];
        beq = [0; 1];
        LB = [0; Ot; On];
        UB = [99999; 99999*ones(PHOR+1,1); ones(num_use, 1)];
        
        opts = optimset('Display','none');
        
        [X, ~, EXITFLAG] = linprog(f,A,b,Aeq,beq,LB,UB,[],opts);
        if (EXITFLAG ~= 1)
           disp(EXITFLAG);
           error('Error solving linear program');
        end
            
        p_wts = X(PHOR+3:end)';
        
        port = zeros(1, length(use_data));
        
        for i=1:length(universe) 
           port(universe(i)) = p_wts(i);
        end
        
    end

    function [ port ] = VarWeighted()
        [~, returns, universe] = WindowData(price_data, use_data);
        
        sigma = std(returns);
        p_wts = zeros(length(sigma));
        
        for i=1:length(sigma)
            p_wts(i) = 1/sigma(i);
        end

        %normalize the weights so that they sum to 1
        p_wts = p_wts/sum(p_wts);
        
        port = zeros(1, length(use_data));
        
        for i=1:length(universe)
           port(universe(i)) = p_wts(i);
        end
    end

    function [ port ] = MinMDD()
        [stock_values, returns, universe] = WindowData(price_data, use_data);
        
        dimen = size(stock_values);
        R = zeros(dimen);
        %fill R with the day by day cumulative return for each stock
        for row=2:dimen(1)
           for col=1:dimen(2)
                cur_val = stock_values(row, col);
                org_val = stock_values(1,col);
                if (org_val ~= 0)
                    R(row, col) = (cur_val-org_val)/org_val;
                end
           end
        end
        
        avg_r = mean(returns);
        min_r = min(avg_r);
        max_r = max(avg_r);
        target = lambda*max_r + (1-lambda)*min_r;
        
        num_use = length(universe);
        Ot = zeros(PHOR+1,1);
        It = eye(PHOR+1);
        On = zeros(num_use, 1);
        f = [0; Ot; On; 1];
        A = [0 Ot' -1*R(end, 1:end) 0; Ot It -1*R -1*ones(PHOR+1,1); Ot -1*It R Ot; [It Ot]+[Ot -1*It] Ot*On' Ot];
        b = [-1*target; -1*ones(PHOR+1,1); Ot; Ot];
        Aeq = [1 Ot' On' 0];
        beq = [0];
        LB = [0; Ot; On; 0];
        UB = [99999; 99999*ones(PHOR+1,1); ones(num_use, 1); 1000];
        
        opts = optimset('Display','none');
        X = linprog(f,A,b,Aeq,beq,LB,UB,[],opts);
        
        p_wts = X(PHOR+3:end-1)';

        %normalize the weights so that they sum to 1
        p_wts = p_wts/sum(p_wts);
        
        port = zeros(1, length(use_data));
        
        for i=1:length(universe)
           port(universe(i)) = p_wts(i);
        end
    end
end