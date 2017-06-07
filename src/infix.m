function y = infix(x)
    %INFIX
    %	infix(x) rounds the elements of x to integers toward +/- infinity
    %	depending on the sign of x.  If x > 0, infix(x) --> +inf; if
    %	x < 0, infix(x) --> -inf.

    report_this_filefun(mfilename('fullpath'));

    if x > 0
        y = ceil(x);
    else
        y = floor(x);
    end
