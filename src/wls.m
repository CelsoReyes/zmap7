function [A,B,err] = wls(x,y)
    %WEIGHTED LINEAR LEAST SQUARES REGRESSION
    %	WLS(x,y) finds the A and B coefficients of A log cumalative frequency
    %curve and the error.
    
    %report_this_filefun(mfilename('fullpath'));
    
    global S % output of POLYFIT used for error estimates
    mima = min(x);
    if any(size(x) ~= size(y))
        error('X and Y vectors must be the same size.')
    end
    x = x(:);
    y = y(:);
    l = isinf(y); y(l) = [];x(l) = [];
    % weight the values
    wx = ones(1,ceil(sum(10.^(y))));  wy = wx; k=1;
    for i = 1:length(x)
        wx(k:floor(10.^(y(i))+k-1)) = wx(k:floor(10.^(y(i))+k-1))*x(i);
        wy(k:floor(10.^(y(i))+k-1)) = wy(k:floor(10.^(y(i))+k-1))*(10.^y(i));
        k = floor(10.^(y(i)) + k);
    end
    x = wx;
    y = log10(wy);
    
    clear wx
    clear wy
    l = x  > mima;
    
    %[B, A,err ] = ma(x',y');
    %b2 = -abs(B);
    
    if length(x(l)) > 5
        [p,S] = polyfit(x(l),y(l),1);
    else
        p = [NaN NaN] ;
    end
    A = p(2);
    B = p(1) ;
    
    [~,err] = polyval(p,x,S);
    err = mean(err);
end

