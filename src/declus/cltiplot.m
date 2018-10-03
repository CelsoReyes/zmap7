function cltiplot(var1)
    % create a cumulative number curve of a selected area valid for all catalog types in Cluster Menu or Cluster
    %
    % cumulative number versus time
    % Time of events with a Magnitude greater than ZG.CatalogOpts.BigEvents.MinMag will
    % be shown on the curve.
    %
    %A.Allmann
    
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
    [t0b, teb] = bounds(ZG.newt2.Date) ;
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
            'Callback', @back_menu_cb);
        
        op2=uimenu(op1,'label','P-Value');
        uimenu(op2,'label','manual',...
            'callback',@callbackfun_007);
        uimenu(op2,'label','automatic',...
            'callback',@callbackfun_008);
        uimenu(op2,'label','with time',MenuSelectedField(),@callbackfun_009);
        uimenu(op2,'label','with magnitude',MenuSelectedField(),@callbackfun_010);
        
    end
    
    %% callback functions
    function back_menu_cb(~,~)
        if ~isempty(pyy)
            cltiplot(3);
            pyy=[];
        end
    end

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
        printdlg;
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
function cllta(var1)
    % calculate the LTA-function of a given graph calculates a z-value using a given window length winlen_days
    % operates on ZG.ttcat
    %
    % A.Allmann
    global xt cumu cumu2 pyy
    global file1 freq_field freq_slider par5
    ZG=ZmapGlobal.Data;
    replaceMainCatalog(ZG.newt2);
    
    % initial values
    %
    max_freq = 20;
    min_freq = days(par5);
    if var1==1                       %default
        winlen_days = 13*par5            % for bin of 28 days, winlen_days = 13 is about 1 year
        
    elseif var1==2
        winlen_days = round(ZG.compare_window_dur_v3/days(par5));
        
        if (winlen_days<min_freq)
            winlen_days=min_freq;
        end
        if (winlen_days>max_freq)
            winlen_days=max_freq;
        end
        pause(0.1)
        set(freq_field,'String',num2str(years(ZG.compare_window_dur_v3)));
        set(freq_slider,'Value',years(ZG.compare_window_dur_v3));
    end
    
    [t0b, teb] = bounds(ZG.primeCatalog.Date) ;
    n = ZG.primeCatalog.Count;
    tdiff = round((teb - t0b)/days(par5));
    ZG.compare_window_dur_v3 = days(winlen_days*days(par5));
    
    pause(0.1)
    %
    % make the interface
    %
    clf reset
    orient tall
    rect = [0.2,  0.25, 0.65, 0.70];
    axes('position',rect)
    str2 = [file1];
    title(str2)
    set(gcf,'Units','normalized');
    
    freq_field=uicontrol('Style','edit',...
        'Position',[.40 .00 .12 .06],...
        'Units','normalized','String',num2str(years(ZG.compare_window_dur_v3)),...
        'callback',@callbackfun_001);
    
    freq_slider=uicontrol('BackGroundColor',[ 0.8 0.8 0.8],'Style','slider',...
        'Position',[.30 .10 .45 .06],...
        'Units','normalized','Value',years(ZG.compare_window_dur_v3),'Max',max_freq,'Min',min_freq,...
        'callback',@callbackfun_002);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.9 .30 .10 .05],...
        'Units','normalized','callback',@cb_close,'String','Close');
    
    %uicontrol('Units','normal','Position',[.9 .90 .10 .05],'String','Print ', 'callback',@callbackfun_004)
    
    %uicontrol('Units','normal','Position',[.9 .80 .10 .05],'String','Save', 'callback',@callbackfun_005)
    
    uicontrol('Units','normal','Position',[.9 .70 .10 .05],'String','Back ', 'callback',@cb_back)
    
    uicontrol('Units','normal','Position',[.9 .60 .10 .05],'String','Info ', 'callback',@cb_info)
    
    
    
    %
    % calculate the lta value
    %
    ncu=length(xt);
    lta=zeros(1,ncu);
    winlen_days=round(ZG.compare_window_dur_v3/ZG.bin_dur);
    %
    %  calculated mean, var etc
    %
    for i = 1:tdiff-winlen_days
        mean1 = mean(cumu(1:ncu));
        mean2 = mean(cumu(i:i+winlen_days));
        var1 = cov(cumu(1:ncu));
        var2 = cov(cumu(i:i+winlen_days));
        lta(i+round(winlen_days/2)) = (mean1 - mean2)/(sqrt(var1/ncu+var2/(winlen_days)));
    end     % for i
    
    %
    % plot  the data
    %
    set(gca,'NextPlot','replace')
    pyy = plotyy(xt,cumu2,'ob',xt,lta,'r',[0 0 0 NaN NaN NaN NaN min(lta)*3-1 max(lta*3)+1  ]);
    
    xlabel('Time in [years]')
    ylabel('Cumulative Number')
    str2 = ['LTA of ' file1];
    title(str2)
    
    y2label('z-value')
    grid
    
    
    drawnow;
    
    
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur_v3=years(str2double(mysrc.String));
        delete(pyy);
        cllta(2);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur_v3=years(mysrc.Value);
        delete(pyy);
        cllta(2);
    end
    
    function cb_close(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        pyy=[];
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        print;
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        sav_lta;
    end
    
    function cb_back(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clf;
        cltiplot(3);
    end
    
    function cb_info(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(5);
    end
end

function sav_lta() 
    report_this_filefun();
    
    str = [];
    [newmatfile, newpath] = uiputfile(ZmapGlobal.Data.Directories.output,'*.m', 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs
    
    
    s = [xt  ; cumu2 ; lta   ];
    fid = fopen([newpath newmatfile],'w') ;
    fprintf(fid,'%6.2f  %6.2f %6.2f\n',s);
end


%%
%
%
%
%
%
%

%%
function cltipval(var1)
    % calculate P-values for different time or magnitude windows
    %
    %
    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata
    %
    % finds the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters
    % all values are calculated for different time or magnitude windows
    %
    % Input: Earthquake Catalog of an Cluster Sequence

    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations
    %         A and B values of the Gutenberg Relation based on k
    %         Plots to compare different magnitude or time windows

    % Create an input window for magnitude thresholds and
    % plot cumulative number versus time to allow input of start and end
    % time
    % A.Allmann


    global file1             
    global bgevent clust original newclcat
    global backcat cluscat
   global  clu te1
    global xt cumu cumu2
    global freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button
    global p c dk tt pc loop nn pp nit t err1x err2x ieflag isflag
    global cstep pstep tmpcat ts tend eps1 eps2
    global sdc sdk sdp qp bb loopcheck
    global callcheck mtpl tmm
    global freq_field5
    global magn mp mc mk msdk msdp msdc ctiplo
    global tmp1 tmp2 tmp3 tmp4 omori hpndl1


    if var1==1 | var1==2              %magnitude or time estimate
        mtpl = findobj('Type','Figure','Name','P-Value Estimate');
        if ~isempty(mtpl)
            figure(mtpl);
            clf
        else
            mtpl=figure_w_normalized_uicontrolunits(...
                'Name','P-Value Estimate',...
                'NumberTitle','off',...
                'NextPlot','new',...
                'visible','off',...
                'Units','normalized',...
                'Position',[ 0.435  0.8 0.5 0.8]);
        end
        
        ZG.newt2=ZG.ttcat;
        %calculate start -end time of overall catalog
        [t0b, teb] = bounds(ZG.newt2.Date) ;
        tdiff=days(teb-t0b);       %time difference in days
        par3=tdiff/100;
        par5=par3;
        if par5>.5
            par5=par5/5;
        end

        % calculate cumulative number versus time and bin it
        %
        n = ZG.newt2.Count;
        if par3>=1
            [cumu, xt] = hist(ZG.newt2.Date,(t0b:days(par3):teb));
        else
            [cumu, xt] = hist(ZG.newt2.Date-ZG.newt2.Date(1),(0:par5:tdiff));
        end
        cumu2 = cumsum(cumu);

        % plot time series
        %
        orient tall
        rect = [0.22,  0.5, 0.55, 0.45];
        ctiplo=axes('position',rect);
        set(gca,'NextPlot','add')
        cplot = plot(xt,cumu2,'ob');
        set(gca,'visible','off')
        ctiplo2 = plot(xt,cumu2,'r');
        if exist('stri', 'var')
            v = axis;
            tea = text(v(1)+0.5,v(4)*0.9,stri) ;
            set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold');
        end

        strib = [file1];

        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,...
            'Color','r')

        grid
        if par3>=1
            xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        else
            xlabel(['Time in days relative to ',num2str(t0b)],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        end
        ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

        % Make the figure visible
        %
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on')

        gcf;
        rect=[0 0 1 1];
        h2=axes('Position',rect);
        set(h2,'visible','off');

        str =  ['\newline \newline \newlinePlease select start and end time of the P-Value plot\newlineClick first with the left Mouse Button at your start position\newlineand then with the left Mouse Button at the end position'];
        te = text(0.2,0.37,str) ;

        set(te,'FontSize',14);
        set(mtpl,'Visible','on');

        disp('Please select start and end time of the P-value plot. Click first with the left Mouse Button at your start position and then at the end position.')


        seti = uicontrol('Units','normal',...
            'Position',[.4 .01 .2 .05],'String','Select Time1 ');


        XLim=get(ctiplo,'XLim');
        M1b = [];
        M1b= ginput(1);
        tt3= M1b(1);
        tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
        text( M1b(1),M1b(2),['|: T1=',tt4] )
        set(seti,'String','Select Time2');

        pause(0.1)
        M2b = [];
        M2b = ginput(1);
        tt3= M2b(1);
        tt5=num2str((tt3-0.22)*(XLim(2)-XLim(1))*(1/.55)+XLim(1));
        text( M2b(1),M2b(2),['|: T2=',tt5] )

        pause(0.1)
        delete(seti)

        watchoff
        watchoff

        set(te,'visible','off');

        tmp2=min(ZG.ttcat(:,6));
        freq_field1= uicontrol('Style','edit',...
            'Position',[.43 .35 .1 .04],...
            'Units','normalized','String',num2str(tmp2),...
            'callback',@callbackfun_001);

        tmp1=max(ZG.ttcat(:,6));
        freq_field2=uicontrol('Style','edit',...
            'Position',[.76 .35 .1 .04],...
            'Units','normalized','String',num2str(tmp1),...
            'callback',@callbackfun_002);
        tmp3=str2double(tt4);
        if tmp3 < 0
            tmp3=0;
        end

        freq_field3=uicontrol('Style','edit',...
            'Position',[.43 .28 .1 .04],...
            'Units','normalized','String',num2str(tmp3),...
            'callback',@callbackfun_003);

        tmp4=str2double(tt5);
        freq_field4=uicontrol('Style','edit',...
            'Position',[.76 .28 .1 .04],...
            'Units','normalized','String',num2str(tmp4),...
            'callback',@callbackfun_004);


        txt1 = text(...
            'Position',[0.1 0.37   ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Magnitude:    Min: ');

        txt2 = text(...
            'Position',[0.6 0.37  ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Max :');


        txt3 = text(...
            'Position',[0.1 0.3 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Time:             Min:');

        txt4 = text(...
            'Position',[0.6 0.3 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Max :');


        if var1==1                        %magnitude window

            txt5 = text(...
                'Position',[0.2 0.22 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Magnitude Steps: ');
            magn=tmp2;
            freq_field5=uicontrol('Style','edit',...
                'Position',[.55 .2 .2 .04],...
                'Units','normalized','String',num2str(magn),...
                'callback',@callbackfun_005);
            set(freq_field5,'String',num2str(magn));
            tmm=0;
            text(0.54,0.17,'Vector (e.g. 1: 0.1: 3): ');
        elseif var1==2            %time windows
            txt5 = text(...
                'Position',[0.2 0.22 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','End Times : ');

            magn=tmp4;
            freq_field5=uicontrol('Style','edit',...
                'Position',[.55 .2 .2 .04],...
                'Units','normalized','String',num2str(magn),...
                'callback',@callbackfun_006);
            set(freq_field5,'String',num2str(magn));
            tmm=3;
            text(0.54,0.17,'Vector (e.g. 1: 0.5: 7): ');
        end

        Info_p = uicontrol('Style','Pushbutton',...
            'String','Info ',...
            'Position',[.3 .05 .10 .06],...
            'Units','normalized','callback',@callbackfun_007);
        if var1==2
            set(Info_p, 'callback',@callbackfun_008);
        end
        close_p =uicontrol('Style','Pushbutton',...
            'Position', [.45 .05 .10 .06 ],...
            'Units','normalized','callback',@callbackfun_009,...
            'String','Close');
        print_p = uicontrol('Style','Pushbutton',...
            'Position',[.15 .05 .1 .06],...
            'Units','normalized','Callback',  @(~,~)printdlg,...
            'String','Print');
        labelPos= [.6 .05 .2 .06];
        labelList=['Mainshock| Main-Input| Sequence' ];
        hpndl1 =uicontrol(...
            'style','popup',...
            'units','normalized',...
            'position',labelPos,...
            'string', labelList,...
            'callback',@callbackfun_010);
        figure(mess);
        clf;
        str =  ['\newline \newline \newlinePlease give in parameters in green fields\newlineThis parameters will be used as the threshold\newline for the P-Value.\newlineAfter input push GO to continue. '];
        te = text(0.01,0.9,str) ;

        set(te,'FontSize',12);
        set(gca,'visible','off');

    elseif var1==3  ||  var1==4  ||  var1==5  %Mainshock/Maininput/Sequence

        mp=zeros(length(magn),1);mc=mp;mk=mp;msdp=mp;msdc=mp;msdk=mp;

        wai=waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Omori-Parameters - Percent done');
        drawnow

        for i=1:length(magn)       %different magnitude steps
            waitbar(i/length(magn))
            %set the error test values
            eps1=.0005;
            eps2=.0005;

            %set the parameter starting values
            PO=1.1;
            CO=0.1;

            %set the initial step size
            pstep=.05;
            cstep=.1;
            pp=PO;
            pc=CO;
            nit=0;
            ieflag=0;
            isflag=0;
            err1x=0;
            err2x=0;
            ts=0.0000001;

            %Build timecatalog

            mains=find(ZG.ttcat(:,6)==max(ZG.ttcat(:,6)));
            mains=ZG.ttcat(mains(1),:);         %biggest shock in sequence
            if var1==4  %input of maintime of sequence(normally onset of high seismicity)
                if i==1
                    figure(mtpl);
                    seti = uicontrol('Units','normal',...
                        'Position',[.4 .01 .2 .05],'String','Select Maintime');
                    XLim=get(ctiplo,'XLim');
                    M1b = [];
                    M1b= ginput(1);
                    tt3= M1b(1);
                    tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
                    text( M1b(1),M1b(2),['|: T1=',tt4] )
                    tt4=str2double(tt4);
                    delete(seti);


                    if tt4>tmp3          %maintime after selected starttime of sequence
                        tt4=tmp3;
                        disp('maintime was set to starttime of estimate')
                    end
                    figure(wai);
                end
            end                   %end of input maintime

            if par3<1             %if cumulative number curve is in days

                if var1==4        %first event in sequence is mainevent if maininput
                    mains=find(ZG.ttcat(:,3)>(days(tt4)+ZG.ttcat(1,3)));
                    mains=ZG.ttcat(mains(1),:);
                end

                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=days(tmp3)+ZG.ttcat(1,3) &    ZG.ttcat(:,3)<=days(tmp4)+ZG.ttcat(1,3)),:);
                tmp6=days(tmp3)+ZG.ttcat(1,3);

            else                 %cumulative number curve is in  years

                if var1==4           %first event in sequence in mainevent if maininput
                    mains=find(ZG.ttcat(:,3)>tt4);
                    mains=ZG.ttcat(mains(1),:);
                end

                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=tmp3 & ZG.ttcat(:,3)<=tmp4),:);
                tmp6=tmp3;
            end
            tmp2=magn(i);
            tmpcat=tmpcat(find(tmpcat(:,6)>=tmp2 & tmpcat(:,6)<=tmp1),:);

            if var1 ==3 | var1==4
                ttt=find(tmpcat(:,3)>mains(1,3));
                tmpcat=tmpcat(ttt,:);
                tmpcat=[mains; tmpcat];
                ts=(tmp6-mains(1,3))*365;
                if ts<=0
                    ts=0.0000001;
                end
            end
            tmeqtime=clustime(tmpcat);
            tmeqtime=tmeqtime-tmeqtime(1);     %time in days relative to first eq
            tmeqtime=tmeqtime(2:length(tmeqtime));

            tend=tmeqtime(length(tmeqtime)); %end time
            %Loop begins here
            nn=length(tmeqtime);
            loop=0;
            tt=tmeqtime(nn);
            t=tmeqtime;

            MIN_CSTEP = 0.000001;
            MIN_PSTEP = 0.00001;
    
            % moved into MyPvalClass
            loopcheck=ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');  % call of function who calculates parameters

            if loopcheck<499
                mp(i)=p;              %storage of p,k,c +standard deviations
                msdp(i)=sdp;
                mk(i)=dk;
                msdk(i)=sdk;
                mc(i)=c;
                msdc(i)=sdc;
            else
                mp(i)=NaN;
                msdp(i)=NaN;
                mk(i)=NaN;
                msdk(i)=NaN;
                mc(i)=NaN;
                msdc(i)=NaN;
            end
            if msdp>mp
                msdp=mp;
            elseif msdk>mk
                msdk=mk;
            elseif msdc>mc
                msdc=mc;
            end
        end                    %end for

        delete(wai)
        cltipval(9);
    elseif var1==6  ||  var1==7  ||  var1==8

        mp=zeros(length(magn),1);mc=mp;mk=mp;msdp=mp;msdc=mp;msdk=mp;
        wai=waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Omori-Parameters - Percent done');
        drawnow
        for i=1:length(magn)       %different magnitude steps
            waitbar(i/length(magn))
            %set the error test values
            eps1=.0005;
            eps2=.0005;

            %set the parameter starting values
            PO=1.1;
            CO=0.1;

            %set the initial step size
            pstep=.05;
            cstep=.1;
            pp=PO;
            pc=CO;
            nit=0;
            ieflag=0;
            isflag=0;
            err1x=0;
            err2x=0;
            ts=0.0000001;

            %Build timecatalog

            mains=find(ZG.ttcat(:,6)==max(ZG.ttcat(:,6)));
            mains=ZG.ttcat(mains(1),:);         %biggest shock in sequence
            if var1==7  %input of maintime of sequence(normally onset of high seismicity)
                if i==1
                    figure(mtpl);
                    seti = uicontrol('Units','normal',...
                        'Position',[.4 .01 .2 .05],'String','Select Maintime');
                    XLim=get(ctiplo,'XLim');
                    M1b = [];
                    M1b= ginput(1);
                    tt3= M1b(1);
                    tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
                    text( M1b(1),M1b(2),['|: T1=',tt4] )
                    tt4=str2double(tt4);
                    delete(seti);

                    if tt4>tmp3          %maintime after selected starttime of sequence
                        tt4=tmp3;
                        disp('maintime was set to starttime of estimate')
                    end
                    figure(wai);
                end
            end                   %end of input maintime

            if par3<1             %if cumulative number curve is in days

                if var1==7        %first event in sequence is mainevent if maininput
                    mains=find(ZG.ttcat(:,3)>(days(tt4)+ZG.ttcat(1,3)));
                    mains=ZG.ttcat(mains(1),:);
                end

                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=days(tmp3)+ZG.ttcat(1,3) &    ZG.ttcat(:,3)<=magn(i)/365+ZG.ttcat(1,3)),:);
                tmp6=days(tmp3)+ZG.ttcat(1,3);

            else                 %cumulative number curve is in  years

                if var1==7           %first event in sequence in mainevent if maininput
                    mains=find(ZG.ttcat(:,3)>tt4);
                    mains=ZG.ttcat(mains(1),:);
                end

                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=tmp3 & ZG.ttcat(:,3)<=magn(i)),:);
                tmp6=tmp3;
            end
            tmpcat=tmpcat(find(tmpcat(:,6)>=tmp2 & tmpcat(:,6)<=tmp1),:);

            if var1 ==6 | var1==7
                ttt=find(tmpcat(:,3)>mains(1,3));
                tmpcat=tmpcat(ttt,:);
                tmpcat=[mains; tmpcat];
                ts=(tmp6-mains(1,3))*365;
                if ts<=0
                    ts=0.0000001;
                end
            end
            tmeqtime=clustime(tmpcat);
            tmeqtime=tmeqtime-tmeqtime(1);     %time in days relative to first eq
            tmeqtime=tmeqtime(2:length(tmeqtime));

            tend=tmeqtime(length(tmeqtime)); %end time
            %Loop begins here
            nn=length(tmeqtime);
            loop=0;
            tt=tmeqtime(nn);
            t=tmeqtime;
            
            MIN_CSTEP = 0.000001;
            MIN_PSTEP = 0.00001;
            % moved into MyPvalClass
            loopcheck=ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');%call of function who calculates parameters

            if loopcheck<499
                mp(i)=p;              %storage of p,k,c +standard deviations
                msdp(i)=sdp;
                mk(i)=dk;
                msdk(i)=sdk;
                mc(i)=c;
                msdc(i)=sdc;
            else
                mp(i)=NaN;
                msdp(i)=NaN;
                mk(i)=NaN;
                msdk(i)=NaN;
                mc(i)=NaN;
                msdc(i)=NaN;
            end
            if msdp>mp
                msdp=mp;
            elseif msdk>mk
                msdk=mk;
            elseif msdc>mc
                msdc=mc;
            end
        end                    %end for
        delete(wai)
        cltipval(9);


    elseif var1==9              %plot the results
        omori=findobj('Name','Omori-Parameters','-and','Type','Figure');

        if ~isempty(omori)
            figure(omori);
            clf;
        else
            omori=figure_w_normalized_uicontrolunits(....
                'Name','Omori-Parameters',...
                'NumberTitle','off',...
                'NextPlot','new',...
                'visible','off',...
                'Units','normalized',...
                'Position',[ 0.435  0.8 0.5 0.8]);
        end
        
        %plot p-value + standard deviation
        rect = [0.15,  0.7, 0.65, 0.26];
        mpplot=axes('position',rect,'box','on');
        set(gca,'NextPlot','add')
        plot(magn,mp,'ob')
        if tmm==0
            xlabel('Minimum Magnitude ');
        else
            xlabel('End Time of Estimate');
        end
        ylabel('p-value');
        errorbar(magn,mp,msdp);
        grid;

        %plot  k-value + standard deviation
        rect= [0.15,  0.38, 0.65, 0.26];
        mkplot=axes('position',rect,'box','on');
        set(gca,'NextPlot','add')
        plot(magn,mk,'ob')
        if tmm==0
            xlabel('Minimum Magnitude ');
        else
            xlabel('End Time of Estimate');
        end
        ylabel('k-value');
        errorbar(magn,mk,msdk)
        grid


        %plot c-value +  standard deviation
        rect=[0.15,  0.06, 0.65, 0.26];
        mctiplo=axes('position',rect,'box','on');
        set(gca,'NextPlot','add')
        plot(magn,mc,'ob');
        if tmm==0
            xlabel('Minimum Magnitude ');
        else
            xlabel('End Time of Estimate');
        end
        ylabel('c-value');
        errorbar(magn,mc,msdc)
        grid
    end




function callbackfun_001(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  tmp2=str2double(freq_field1.String);
       freq_field1.String=num2str(tmp2);
end
 
function callbackfun_002(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  tmp1=str2double(freq_field2.String);
     freq_field2.String=num2str(tmp1);
end
 
function callbackfun_003(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  tmp3=str2double(freq_field3.String);
    freq_field3.String=num2str(tmp3);
end
 
function callbackfun_004(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  tmp4=str2double(freq_field4.String);
   freq_field4.String=num2str(tmp4);
end
 
function callbackfun_005(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  magn=str2num(freq_field5.String);
end
 
function callbackfun_006(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  magn=str2num(freq_field5.String);
end
 
function callbackfun_007(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  clinfo(18);
end
 
function callbackfun_008(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  clinfo(19);
end
 
function callbackfun_009(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  set(mtpl,'visible','off');
end
 
function callbackfun_010(mysrc,myevt)

  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  in2=get(hpndl1,'Value')+2+tmm;
  cltipval(in2);
end
 



end

