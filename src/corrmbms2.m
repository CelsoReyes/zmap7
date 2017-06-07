function [P,R]=corrmbms2(x,y,ord,xt,yt)

    clf
    global p
    l = x > 0 & y > 0;
    x = x(l); y = y(l);

    plot(x,y,'.')
    axis([0 8 0 8 ])
    grid
    ylabel(yt)
    xlabel(xt)
    ;
    [p,s] = polyfit(x,y,ord);
    f = polyval(p,(min(x):0.1:max(x)));

    hold on
    plot(min(x):0.1:max(x),f,'k')
    r = corrcoef(x,y);
    r = r(1,2);
    stri = [ 'p = ' num2str(p(1)) '*m + ' num2str(p(2))  ];
    stri2 = [ 'r = ' num2str(r) ];
    text(1,6.7,stri);
    text(1,6.2,stri2);
    mb2 = polyval(p,x);

    plot(x,mb2,'+g')
    matdraw
    
    P=p;
    R=r;
