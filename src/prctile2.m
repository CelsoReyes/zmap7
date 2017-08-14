function y = prctile(x,p)
    %PRCTILE gives the percentiles of the sample in X.
    %	Y = PRCTILE(X,P) returns a value that is greater than P percent
    %	of the values in X. For example, if P = 50  Y is the median of X.
    %
    %	P may be either a scalar or a vector. For scalar P, Y is a row
    %	vector containing Pth percentile of each column of X. For vector P,
    %	the ith row of Y is the P(i) percentile of each column of X.

    %	Copyright (c) 1993 by The MathWorks, Inc.
    %	$Revision: 1399 $  $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    % report_this_filefun(mfilename('fullpath'));

    [prows, pcols] = size(p);
   if prows ~= 1  && pcols ~= 1
        error('P must be a scalar or a vector.');
    end

    if any(p > 100) | any(p < 0)
        error('P must take values between 0 and 100');
    end

    xx = sort(x);
    [m,n] = size(x);

    if m==1 | n==1
        m = max(m,n);
        n = 1;
        q = 100*(0.5:m - 0.5)./m;
        xx = [min(x); xx(:); max(x)];
    else
        q = 100*(0.5:m - 0.5)./m;
        xx = [min(x); xx; max(x)];
    end


    q = [0 q 100];

    y = interp1(q,xx,p);

