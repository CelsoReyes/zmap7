function fn= get_confidence_function(pval)
    % GET_CONFIDENCER_FUNCTION returns a function with the following signature:
    % function [ans] = conf_fun(p, c, k, t)
    %   where p = pvalues as n x 1
    %   where c = cvalues as n x 1
    %   where k = kvalues as n x 1
    %   where t = amount of time after the main shock, as m x 1 duration
    %
    %   returns an n x m matrix of values
    %
    % the exact function is determined by the pval
    
    %although I'm returning anonymous functions, I could also return "real" functions
    switch pval
        case 1
            fn = @(~,c,k,t) k.*log(days(t')./c+1);
        otherwise
            fn = @(p,c,k,t) k./(p-1).*(c.^(1-p)-(days(t')+c).^(1-p));
    end
end
    