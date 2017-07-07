function  plohist(ts,ts2)

    report_this_filefun(mfilename('fullpath'));

    [n,x] = hist(ts,0:0.1:8.0);
    subplot(211),bar(x,n);
    axis([ 0 8 0 max(n)+10 ]);

    [n,x] = hist(ts2,0:0.1:8.0);
    subplot(212),bar(x,n);
    axis([ 0 8 0 max(n)+10 ]);
