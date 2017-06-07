function y = f(x)

    report_this_filefun(mfilename('fullpath'));

    global les n
    y = les - (x/(1-x) - (n*x^n)/(1 - x^n))  ;
