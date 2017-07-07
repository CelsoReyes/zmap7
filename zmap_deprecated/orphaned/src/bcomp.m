function  bcomp(newcat,d1,d2,d3,d4)
    %  This routine etsimates the b-value of a curve automatically
    %  The b-valkue curve is differenciated and the point
    %  of maximum curvature marked. The b-value will be calculated
    %  using this point and the point half way toward the high
    %  magnitude end of the b-value curve.
    %
    %  Stefan Wiemer 1/95
    %
    think
    %zmap_message_center.set_info('  ','Calculating b-value...')
    global cluscat mess bfig backcat
    global  ttcat
    report_this_filefun(mfilename('fullpath'));
    org = newcat;



    [existFlag,figNumber]=figure_exists('b-value curve',1);
    if existFlag
        figure_w_normalized_uicontrolunits(bfig);
        delete(gca);delete(gca)
        rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
        set(gca,'Yscale','log')
        hold on
        %set(bfig,'visible','off')
    else
        bfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
            'Units','normalized','NumberTitle','off',...
            'Name','b-value curve',...
            'MenuBar','none',...
            'visible','on',...
            'pos',[ 0.300  0.7 0.5 0.5]);

        orient tall
        rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
        set(gca,'Yscale','log')
        
        matdraw

    end

    % first depth

    l = org(:,7) >= d1 & org(:,7) <= d2;
    newcat = org(l,:);

    maxmag = max(newcat.Magnitude);
    mima = min(newcat.Magnitude);
    if mima > 0 ; mima = 0 ; end

    % number of mag units
    nmagu = (maxmag*10)+1;

    bval = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);

    [bval,xt2] = hist(newcat.Magnitude,(mima:0.1:maxmag));
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:mima);


    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);

    hold on
    semilogy(xt3,bvalsum3,'-.m')
    hold on
    semilogy(xt3,bvalsum3,'om')
    difb = [0 diff(bvalsum3) ];

    % Marks the point of maximum curvature
    %
    i = find(difb == max(difb));
    i = length(xt3)-10*min(newcat.Magnitude)

    % Estimate the b-value
    %
    i2 = round(i/3);
    i2 = 1;

    xlabel('Magnitude','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Cumulative Number','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    set(gca,'Color',[1 1 0.6])
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')


    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = [xt3(i) bvalsum3(i)];
    tt3=num2str(fix(100*M1b(1))/100);

    M2b = [];
    M2b =  [xt3(i2) bvalsum3(i2)];
    tt4=num2str(fix(100*M2b(1))/100);

    pause(0.1)

    ll = xt3 >= M1b(1) & xt3 <= M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    [p,s] = polyfit(x,y,1);                   % fit a line to background
    [aw bw,  ew] = wls(x',y')
    p = [bw aw];
    f = polyval(p,x);
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'m');                         % plot linear fit to backg
    set(ttm,'LineWidth',0.5)
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = ew;      % standard deviation of fit


    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt2=num2str(std_backg);
    tt1=num2str(p);

    l = org(:,7) >= d3 & org(:,7) <= d4;
    newcat = org(l,:);

    maxmag = max(newcat.Magnitude);
    mima = min(newcat.Magnitude);
    if mima > 0 ; mima = 0 ; end

    % number of mag units
    nmagu = (maxmag*10)+1;

    bval = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);

    [bval,xt2] = hist(newcat.Magnitude,(mima:0.1:maxmag));
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:mima);


    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);

    hold on
    semilogy(xt3,bvalsum3,'-.b')
    hold on
    semilogy(xt3,bvalsum3,'ob')
    difb = [0 diff(bvalsum3) ];

    % Marks the point of maximum curvature
    %
    i = find(difb == max(difb));
    i = length(xt3)-10*min(newcat.Magnitude)

    % Estimate the b-value
    %
    i2 = round(i/3);
    i2 = 1;

    xlabel('Magnitude','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Cumulative Number','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    set(gca,'Color',color_bg);
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')


    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = [xt3(i) bvalsum3(i)];
    tt3=num2str(fix(100*M1b(1))/100);

    M2b = [];
    M2b =  [xt3(i2) bvalsum3(i2)];
    tt4=num2str(fix(100*M2b(1))/100);

    pause(0.1)

    ll = xt3 >= M1b(1) & xt3 <= M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    [aw bw,  ew] = wls(x',y')
    p = [bw aw];
    f = polyval(p,x);
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'b');                         % plot linear fit to backg
    set(ttm,'LineWidth',0.5)
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg2 = ew;      % standard deviation of fit


    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg2=fix(100*std_backg2)/100;
    tt2b=num2str(std_backg2);
    tt1b=num2str(p);
    set(gca,'XLim',[min(org(:,6))-0.5 max(org(:,6))+0.2]);
    grid
    % Label for the first depth intervall
    txt1=text(.10, -.16,['b  = ',tt1, ' +/- ', tt2, ' ; depth range ' num2str(d1) ' - ' num2str(d2) ' km' ],'units','normalized');
    set(txt1,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','m')
    % Label for the sec depth intervall
    txt1=text(.10, -.22,['b  = ',tt1b, ' +/- ', tt2b, ' ; depth range ' num2str(d3) ' - ' num2str(d4) ' km' ],'units','normalized');
    set(txt1,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','b')


