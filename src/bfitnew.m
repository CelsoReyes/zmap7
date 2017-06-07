function bfitnew(newcat)
    %bfitnew.m                      A.Allmann  10/94
    %  modified  Stefan Wiemer 12/94
    %
    %   Calculates Freq-Mag functions (b-value) for a catalog
    %   works on newcat
    global cluscat mess bfig backcat fontsz cb1 cb2 cb3
    global ttcat xt3 bvalsum3
    report_this_filefun(mfilename('fullpath'));

    [existFlag,figNumber]=figure_exists('frequency-magnitude distribution - 2',1);
    bfigWin=~existFlag;
    if bfigWin
        bfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
            'Units','normalized','NumberTitle','off',...
            'Name','frequency-magnitude distribution - 1',...
            'MenuBar','none',...
            'visible','on',...
            'pos',[ 0.300  0.4 0.5 0.5]);

        uicontrol('Units','normal',...
            'Position',[.0 .65 .08 .06],'String','Save ',...
             'Callback',{@calSave9,xt3, bvalsum3})

        matdraw

    end

    figure_w_normalized_uicontrolunits(bfig);
    delete gca; delete(gca);delete(gca); hold on; axis off
    uicontrol('Style','Pushbutton',...
        'Callback','myprint',...
        'Units','normalized',...
        'String','Print','Position',[0.02 .93 .08 .05]);

    uicontrol('Style','Pushbutton',...
        'Callback','close;welcome('' '','' '');done',...
        'Units','normalized',...
        'String','Close','Position',[0.02 .73 .08 .05]);
    uicontrol('Style','Pushbutton',...
        'Callback','clinfo(8)',...
        'Units','normalized',...
        'String','Info','Position',[0.02 .83 .08 .05]);

    uicontrol('Units','normal',...
        'Position',[.0 .55 .10 .06],'String','Automatic',...
         'Callback','bdiff(newcat)');

    maxmag = max(newcat(:,6));
    mima = min(newcat(:,6));
    if mima > 0 mima = 0;end

    % number of mag units
    nmagu = (maxmag*10)+1;

    bval = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);

    [bval,xt2] = hist(newcat(:,6),(mima:0.1:maxmag));
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:mima);


    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);
    orient tall
    rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
    axes('position',rect);

    semilogy(xt3,bvalsum3,'-.m')
    hold on
    semilogy(xt3,bvalsum3,'om')
    grid
    xlabel('Magnitude','FontWeight','bold','FontSize',fontsz.m)
    ylabel('Cumulative Number','FontWeight','bold','FontSize',fontsz.m)
    set(gca,'Color',[cb1 cb2 cb3 ])
    set(gca,'XLim',[min(newcat(:,6))-0.5  max(newcat(:,6))+0.3])
    set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')

    set(gcf,'visible','on');

    str=['Please select two magnitudes    '
        ' for a the straight line fit.   '
        ' Wait until after the selection '
        ' before pressing Info or Close. '];

    welcome('b-value fit',str)

    figure_w_normalized_uicontrolunits(bfig)
    seti = uicontrol('Units','normal',...
        'Position',[.4 .01 .2 .05],'String','Select Mag1 ');

    pause(1)

    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = ginput(1);
    tt3=num2str(fix(100*M1b(1))/100);
    text( M1b(1),M1b(2),['|: M1=',tt3] )
    set(seti,'String','Select Mag2');

    pause(0.1)

    M2b = [];
    M2b = ginput(1);
    tt4=num2str(fix(100*M2b(1))/100);
    text( M2b(1),M2b(2),['|: M2=',tt4] )

    pause(0.1)
    delete(seti)

    ll = xt3 > M1b(1) & xt3 < M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    [p,s] = polyfit(x,y,1);                   % fit a line to background
    f = polyval(p,x);
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'b');                         % plot linear fit to backg
    set(ttm,'LineWidth',2)
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = std(y - polyval(p,x));      % standard deviation of fit

    hh = gca;
    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt2=num2str(std_backg);
    tt1=num2str(p);

    rect=[0 0 1 1];
    h2=axes('position',rect);
    set(h2,'visible','off');

    txt1=text(.16, .18,['B-Value: ',tt1]);
    set(txt1,'FontWeight','bold','FontSize',fontsz.m)
    txt1=text(.16, .1,['Standard Deviation: ',tt2]);
    set(txt1,'FontWeight','bold','FontSize',fontsz.m)

    uicontrol('Style','Pushbutton',...
        'Callback','bfitnew(newcat)',...
        'Units','normalized',...
        'String','Repeat','Position',[0.85 .02 .12 .08]);

    axes(hh)

