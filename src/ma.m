function [b_value_ma, a_value_ma, b_error_ma] = ma(mag,cumnum)

    % compute the slope, intercept, and their errors using
    % "Major Axis" regression.
    % the inputs are two column vectors.
    % e.g. [b,a,e] = ma(X,Y) were X and Y are column vectors of the same length.
    % outputs are the b and a values and the standard error.

    report_this_filefun(mfilename('fullpath'));

    X = [mag cumnum];
    m = mean(X);
    ssx = (X(:,1)-m(1))'*(X(:,1)-m(1));
    ssy = (X(:,2)-m(2))'*(X(:,2)-m(2));
    ssxy = (X(:,1)-m(1))'*(X(:,2)-m(2));

    % MAJOR AXIS REGRESSION
    [V,D] = eig(cov(X));
    % the slope of the line in the direction of max. variance
    b_value_ma = V(2,2)/V(1,2);
    a_value_ma = m(2) - (b_value_ma * m(1));

    % the standard error in the slopes
    r = ssxy/(sqrt(ssx.*ssy));
    b_error_ma = abs(b_value_ma)*sqrt((1-r^2)/length(X));

