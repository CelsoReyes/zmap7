function y = frac(x)

    %FRAC
    %
    %	FRAC(X) returns the fractional part of a real number.

    report_this_filefun(mfilename('fullpath'));

    y = x - fix(x);
