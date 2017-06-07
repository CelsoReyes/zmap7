function corrmbms(x,y,ord)

    report_this_filefun(mfilename('fullpath'));
    %

    figure_w_normalized_uicontrolunits('pos',[100 100 900 500]);

    axes('pos',[0.55 0.15 0.4 0.7]);
    mi = floor(min([x ; y]));
    ma = ceil(max([x ; y]));

    [rho, xvec, yvec] = density(x,y,0.1,0.1,[mi ma mi ma]);
    pcolor(xvec,yvec,rho);
    hold on
    shading interp
    set(gca,'FontSize',12,'FontWeight','normal','TickDir','out','Ticklength',[0.02 0.02])
    set(gcf,'renderer','zbuffer');

    j = jet;
    j = [1 1 1 ; j];
    colormap(j)

    dia = [0 0 ; 10 10];
    plot(dia(:,1),dia(:,2),'k-.');
    xlabel('M1')
    set(gca,'Yticklabel',[]);
    axes('pos',[0.1 0.15 0.4 0.7]);
    global p
    l = x > 0 & y > 0;
    x = x(l); y = y(l);

    %plot(x,y,'.')
    plot(x,y,'k.')
    axis([ mi ma mi ma]);
    set(gca,'FontSize',12,'FontWeight','normal','TickDir','out','Ticklength',[0.02 0.02])

    ylabel('M2')
    xlabel('M1')

    [p,s] = polyfit(x,y,ord)
    f = polyval(p,(min(x):0.1:max(x)));

    hold on
    plot(dia(:,1),dia(:,2),'b-.');
    r = corrcoef(x,y);
    r = r(1,2);
    stri = [ 'p = ' num2str(p(1),2) '*m + ' num2str(p(2),2)  ];
    stri2 = [ 'r = ' num2str(r,2) ];
    text(mi+0.5,ma-0.5,stri);;
    text(mi+0.5,ma-0.8,stri2);
    mb2 = polyval(p,x);

    plot(x,mb2,'r')
    matdraw
    
