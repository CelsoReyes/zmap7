function [A,B, S, err] = wls(x,y)
    %WEIGHTED LINEAR LEAST SQUARES REGRESSION
    %	[A, B, S, err] = WLS(x,y) finds the A and B coefficients of A log cumalative frequency
    %curve and the error.
    %      A, B: a- and b- values of a weighted linear regression fit.
    %    err: estimate of the std deviation of the error in predicting a future observation at X by A and B
    %      S: contains fields for triangular factor(R) from QR decomp... see polyfit (used in polyval)
    %    
    %report_this_filefun();
    %partially vectorized version
    
%    global S % output of POLYFIT used for error estimates
    %mima = min(x);
    
    S=[];
    err=inf;
    
    if any(size(x) ~= size(y))
        error('X and Y vectors must be the same size.')
    end
    x = x(:);
    y = y(:);
    l = isinf(y); 
    y(l) = [];
    x(l) = [];
    % weight the values
    teny= 10.^y;
    wx = ones(1,ceil(sum(teny)));  
    wy = wx; 
    fteny=floor(teny);
    ks = cumsum([1; fteny]);
    for i = 1:length(x)
        wx(ks(i):ks(i+1)-1) = wx(ks(i):ks(i+1)-1) * x(i);
        wy(ks(i):ks(i+1)-1) = wy(ks(i):ks(i+1)-1) * teny(i);
    end
    %x = wx;
    %y = log10(wy);
    
    l = wx  > min(x);%mima;
    
    %[B, A,err ] = ma(x',y');
    %b2 = -abs(B);
    
    if sum(l) <= 5
        p = [NaN NaN] ; 
    elseif nargout > 2
        [p,S] = polyfit(wx(l),log10(wy(l)),1);
        if nargout==4 && S.df > 0
            [~,err] = polyval(p,wx,S);
            err = mean(err);
        end
    else
        p = polyfit(wx(l),log10(wy(l)),1);
    end
    A = p(2);
    B = p(1) ;
end

