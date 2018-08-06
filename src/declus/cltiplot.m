function cltiplot(var1)
    % create a cumulative number curve of a selected area valid for all catalog types in Cluster Menu or Cluster
    %
    % A.Allmann
    %
    % cumulative number versus time
    % Time of events with a Magnitude greater than ZG.CatalogOpts.BigEvents.MinMag will
    % be shown on the curve.
    %
    
    global freq_field freq_slider
    global bgevent file1 clust original newclcat
    global backcat cluscat
    global  clu te1
    global clu1 pyy stri statime
    global xt  cumu cumu2
    global close_ti_button mtpl
    global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5
    global tmp1 tmp2 tmp3 tmp4 tmm magn hpndl1 ctiplo
    
    report_this_filefun();
    myFigName='Cumulative Number Plot (Cluster)';
    
    if ~isempty(pyy)
        delete(findobj('Tag','ccum','-and','Type','Figure'));
    end
    % Find out if figure already exists
    %
    
    ccum=findobj('Type','Figure','-and','Name',myFigName);
    
    % Set up the Seismicity Map window
    
    if isempty(ccum)
        ccum = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Tag','ccum',...
            'Position',position_in_current_monitor(ZG.map_len(1)-60, ZG.map_len(2)-40));
        
        set(ccum,'visible','off');
        create_my_menu()
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
            'callback',@callbackfun_001)
        
        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
            'callback',@callbackfun_002);
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
            'callback',@callbackfun_003)
        
    else
        figure(ccum);
    end
    
    set(gca,'NextPlot','replace')
    cla
    watchon;
    
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    
    if var1==1
        if ~isempty(newclcat)
            if ~isempty(backcat)
                if length(newclcat(:,1))>=length(backcat(:,1))
                    ZG.newt2=cluscat;
                else
                    ZG.newt2=newclcat;
                end
            else
                ZG.newt2=newclcat;
            end
        else
            ZG.newt2=cluscat;
        end
    elseif var1==2
        ZG.newt2=ZG.ttcat;
    end
    [ii,i]=sort(ZG.newt2.Date);
    ZG.newt2=ZG.newt2.subset(i);
    statime=[];
    bigmag=max(ZG.newt2.Magnitude);
    % select big events ( > bigmag)
    %
    l = ZG.newt2.Magnitude == bigmag;
    big = ZG.newt2.subset(l);
    %calculate start -end time of overall catalog
    [t0b, teb] = ZG.newt2.DateRange() ;
    n = ZG.newt2.Count;
    tdiff = days(teb - t0b);
    par5=tdiff/100;         %bin length is 1/100 of timedifference(in days)
    if par5>1
        par5=round(par5);
    elseif par5>=.1  &&  par5 <= 1
        par5=.1;
    else
        par5=.02;
    end
    % calculate cumulative number versus time and bin it
    %
    n = ZG.newt2.Count;
    if par5 >=1
        [cumu, xt] = hist(ZG.newt2.Date,(t0b-days(par5):days(par5):teb+days(par5)));
    else
        [cumu, xt] = hist((ZG.newt2.Date-ZG.newt2.Date(1)+days(par5))*365,(0:par5:(tdiff+2*par5)));
    end
    cumu2=cumsum(cumu);
    
    % plot time series
    %
    orient tall
    rect = [0.2,  0.15, 0.55, 0.75];
    axes('position',rect)
    set(gca,'NextPlot','add')
    tiplo = plot(xt,cumu2,'ob');
    set(gca,'visible','off')
    plot(xt,cumu2,'r','Tag','tiplo2');
    
    
    % plot big events on curve
    %
    if length(big) < 4
        f = cumu2(ceil((big(:,3) -t0b)/days(par5)));
        bigplo = plot(big(:,3),f,'xr');
        set(bigplo,'MarkerSize',10,'LineWidth',2.5)
        stri4 = [];
        [le1,le2] = size(big);
        for i = 1:le1
            s = sprintf('  M=%3.1f',big(i,6));
            stri4 = [stri4 ; s];
        end   % for i
        
        te1 = text(big(:,3),f,stri4);
        set(te1,'FontWeight','bold','Color','m','FontSize',ZmapGlobal.Data.fontsz.s)
        
    end %if big
    
    if exist('stri', 'var')
        v = axis;
        tea = text(v(1)+0.5,v(4)*0.9,stri) ;
        set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
    end %% if stri
    
    strib = [file1];
    
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.l,...
        'Color','r')
    
    grid
    if par5>=1
        xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    else
        statime=ZG.newt2.Date(1)-days(par5);
        xlabel(['Time in days relative to ',num2str(statime)],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    end
    ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    % Make the figure visible
    %
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    set(ccum,'Visible','on');
    figure(ccum);
    watchoff(ccum)
    watchoff
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        op1=uimenu('Label','Tools');
        uimenu(op1,'label','AS',...
            'callback',@callbackfun_004)
        
        uimenu(op1,'label','LTA',...
            'callback',@callbackfun_005)
        
        uimenu(op1,'label','Timecut',...
            'callback',@callbackfun_006)
        
        uimenu(op1,'label','Back',...
            'Callback', 'if ~isempty(pyy),cltiplot(3);pyy=[];end');
        
        op2=uimenu(op1,'label','P-Value');
        uimenu(op2,'label','manual',...
            'callback',@callbackfun_007);
        uimenu(op2,'label','automatic',...
            'callback',@callbackfun_008);
        uimenu(op2,'label','with time',MenuSelectedField(),@callbackfun_009);
        uimenu(op2,'label','with magnitude',MenuSelectedField(),@callbackfun_010);
        
    end
    
    %% callback functions
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(4);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        xt=[];
        cumu=[];
        cumu2=[];
        if isempty(pyy)
            set(ccum,'visible','off');
        else
            delete(ccum);
            pyy=[];
        end
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint;
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(gcf,'Pointer','watch');
        clas;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cllta(1);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        timeselect(1);
        cltiplot(3) ;
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ttcat=ZG.newt2;
        clpval(1);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ttcat=ZG.newt2;
        clpval(3);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cltipval(2);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cltipval(1);
    end
end
