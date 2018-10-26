function ctimeplot() 
    % ctimeplot plots the events select by "circle" or by other selection button as a cummultive number versus time plot in window 2.
    % Time of events with a Magnitude greater than ZG.CatalogOpts.BigEvents.MinMag will
    % be shown on the curve.  Operates on ZG.newt2, resets  b  to ZG.newt2,
    %     ZG.newcat is reset to:
    %                       - "primeCatalog" if either "Back" button or "Close" button is         %                          pressed.
    %                       - ZG.newt2 if "Save as Newcat" button is pressed.
    %
    % turned into function by Celso G Reyes 2017
    %
    % Probably replaced by CumTimePlot
    
    ZG=ZmapGlobal.Data;
    msg.infodisp('Plotting cumulative number plot...',' ');
    
    report_this_filefun();
    
    myFigName='Cumulative Number';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    
    % This is the info window text
    %
    ttlStr='The Cumulative Number Window                  ';
    hlpStr1= ...
        ['                                                     '
        ' This window displays the seismicity in the sel-     '
        ' ected area as a cumulative number plot.             '
        ' Options from the Tools menu:                        '
        ' Cuts in magnitude and  depth: Opens input para-     '
        '    meter window                                     '
        ' Decluster the catalog: Will ask for declustering    '
        '     input parameter and decluster the catalog.      '
        ' AS(t): Evaluates significance of seismicity rate    '
        '      changes using the AS(t) function. See the      '
        '      Users Guide for details                        '
        ' LTA(t), Rubberband: dito                            '
        ' Overlay another curve (hold): Allows you to plot    '
        '       one or several more curves in the same plot.  '
        '       select "Overlay..." and then selext a new     '
        '       subset of data in the map window              '
        ' Compare two rates: start a comparison and moddeling '
        '       of two seismicity rates based on the assumption'
        '       of a constant b-value. Will calculate         '
        '       Magnitude Signature. Will ask you for four    '
        '       times.                                        '
        '                                                     '];
    hlpStr2= ...
        ['                                                      '
        ' b-value estimation:    just that                     '
        ' p-value plot: Lets you estimate the p-value of an    '
        ' aftershock sequence.                                 '
        ' Save cumulative number cure: Will save the curve in  '
        '        an ASCII file                                 '
        '                                                      '
        ' The "Keep as ZG.newcat" button in  lower right corner'
        ' will make the currently selected subset of eartquakes'
        ' in space, magnitude and depth the current one. This  '
        ' will also redraw the Map window!                     '
        '                                                      '
        ' The "Back" button will plot the original cumulative  '
        ' number curve without statistics again.               '
        '                                                      '];
    
    global statime
    
    ZG=ZmapGlobal.Data;
    
    cum = myFigFinder();
    
    % Set up the Cumulative Number window
    
    if isempty(cum)
        cum = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Tag','cum',...
            'Position',position_in_current_monitor(ZG.map_len(1)-100, ZG.map_len(2)-20));
        
        winlen_days = days(ZG.compare_window_dur/ZG.bin_dur);
        create_my_menu();
        
        
        uicontrol('Units','normal',...
            'Position',[.0  .85 .08 .06],'String','Info ',...
            'callback',@cb_info)
        
        uicontrol('Units','normal',...
            'Position',[.0  .75 .08 .06],'String','Close ',...
            'callback',@cb_close)
        
        uicontrol('Units','normal',...
            'Position',[.0  .93 .08 .06],'String','Print ',...
            'callback',@cb_print)
        
        
        uicontrol('Units','normal','Position',[.9 .10 .1 .05],'String','Back', 'callback',@cb_back)
        
        uicontrol('Units','normal','Position',[.65 .01 .3 .07],'String','Keep as ZG.newcat', 'callback',@cb_keepas_newcat)
        
        
    end
    figure(cum);
    ht=gca;
    if ZmapGlobal.Data.hold_state
        cumu = 0:1:(tdiff/days(ZG.bin_dur))+2;
        cumu2 = 0:1:(tdiff/days(ZG.bin_dur))-1;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;
        n = ZG.newt2.Count;
        [cumu, xt] = hist(ZG.newt2.Date,(t0b:days(ZG.bin_dur):teb));
        cumu2 = cumsum(cumu);
        
        set(gca,'NextPlot','add')
        axes(ht)
        plot(xt,cumu2,'r','LineWidth',2.5,'Tag','tiplo2');
        
        ZG.hold_state=false
        return
    end
    
    figure(cum);
    delete(findobj(cum,'Type','axes'));
    reset(gca)
    %delete(sicum)
    cla
    watchon;
    
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    if isempty(ZG.newcat)
        ZG.newcat =ZG.primeCatalog;
    end
    
    % select big events ( > ZG.CatalogOpts.BigEvents.MinMag)
    %
    l = ZG.newt2.Magnitude > ZG.CatalogOpts.BigEvents.MinMag;
    big = ZG.newt2.subset(l);
    %big=[];
    %calculate start -end time of overall catalog
    %R
    statime=[];
    par2 = ZG.bin_dur;
    [t0b, teb] = bounds(ZG.primeCatalog.Date) ;
    n = ZG.newt2.Count;
    ttdif=days(teb - t0b);
    if ttdif>10                 %select bin length respective to time in catalog
        ZG.bin_dur = days(ceil(ttdif/300));
    elseif ttdif<=10  &&  ttdif>1
        ZG.bin_dur = days(0.1);
    elseif ttdif<=1
        ZG.bin_dur = days(0.01);
    end
    
    
    if ZG.bin_dur>=1
        tdiff = round((teb-t0b)/ZG.bin_dur);
        %tdiff = round(teb - t0b);
    else
        tdiff = (teb-t0b)/days(ZG.bin_dur);
    end
    
    % calculate cumulative number versus time and bin it
    %
    n = ZG.newt2.Count;
    if ZG.bin_dur >=1
        [cumu, xt] = histcounts(ZG.newt2.Date, 'BinWidth',ZG.bin_dur); % was hist
    else
        [cumu, xt] = hist((ZG.newt2.Date-ZG.newt2.Date(1)+days(ZG.bin_dur))*365,(0:ZG.bin_dur:(tdiff+2*ZG.bin_dur)));
    end
    delt=days(ZG.bin_dur)/2;
    xt = xt(1:end-1) + delt; % convert from bin edges to bin centers
    cumu2=cumsum(cumu);
    % plot time series
    %
    %orient tall
    set(gcf,'PaperPosition',[0.5 0.5 6.5 9.5])
    rect = [0.25,  0.18, 0.60, 0.70];
    axes('position',rect)
    set(gca,'NextPlot','add')
    
    set(gca,'visible','off')
    plot(xt,cumu2,'b','LineWidth',2.5,'Tag','tiplo2');
    
    
    % plot big events on curve
    %
    if ZG.bin_dur>=1
        if ~isempty(big)
            if ceil(big.Date -t0b) > 0
                f = cumu2(ceil((big.Date -t0b)/ZG.bin_dur));
                bigplo = plot(big.Date,f,'xr');
                set(bigplo,'MarkerSize',10,'LineWidth',2.5)
                stri4 = [];
                for i = 1:big.Count
                    s = sprintf('  M=%3.1f',big.Magnitude(i));
                    stri4 = [stri4 ; s];
                end   % for i
                
                te1 = text(big.Date,f,stri4);
                set(te1,'FontWeight','bold','Color','m','FontSize',ZmapGlobal.Data.fontsz.s)
            end
            
            %option to plot the location of big events in the map
            %
            % figure(map);
            % plog = plot(big(:,1),big(:,2),'or');
            %set(plog,'MarkerSize',ms10,'LineWidth',2.0)
            %figure(cum);
            
        end
    end %if big
    
    if exist('stri', 'var')
        v = axis;
        %if ZG.bin_dur>=1
        % axis([ v(1) ceil(teb) v(3) v(4)+0.05*v(4)]);
        %end
        tea = text(v(1)+0.5,v(4)*0.9,stri) ;
        set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
    end %% if stri
    
    strib = [ZG.newt2.Name];
    
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.l,...
        'Color','k','interpreter','none')
    
    grid
    if ZG.bin_dur>=1
        xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    else
        statime=ZG.newt2.Date(1)-days(ZG.bin_dur);
        xlabel(['Time in days relative to ',num2str(statime)],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    end
    ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ht = gca;
    % set(gca,'Color',color_bg);
    
    %clear strib stri4 s l f bigplo plog tea v
    % Make the figure visible
    %
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    figure(cum);
    %sicum = signatur('ZMAP','',[0.65 0.98 .04]);
    %set(sicum,'Color','b')
    axes(ht);
    set(cum,'Visible','on');
    watchoff(cum)
    watchoff(map)
    ZG.bin_dur = par2; assert(isa(par2,'datetime'));
    
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        options = uimenu('Label','Tools ');
        
        uimenu(options,'Label','Cuts in magnitude and depth',MenuSelectedField(),@cb_cut_mag_depth)
        uimenu (options,'Label','Decluster the catalog',MenuSelectedField(),@(~,~)ReasenbergDeclusterClass(catalog));
        uimenu(options,'Label','AS(t)function',MenuSelectedField(),@(~,~)newsta('ast',ZG.newt2));
        uimenu(options,'Label','Rubberband function',MenuSelectedField(),@(~,~)newsta('rub',ZG.newt2));
        uimenu(options,'Label','LTA(t) function ',MenuSelectedField(),@(~,~)newsta('lta',ZG.newt2));
        uimenu(options,'Label','Overlay another curve (hold)',MenuSelectedField(),@cb_overlayanothercurve)
        uimenu(options,'Label','Compare two rates ( No fit)',MenuSelectedField(),@(~,~)dispma3())
        
        op4 = uimenu(options,'Label','b-value estimation');
        uimenu(op4,'Label','manual',MenuSelectedField(),@(~,~)bfitnew(ZG.newt2))
        uimenu(op4,'Label','automatic',MenuSelectedField(),@(~,~)bdiff(ZG.newt2))
        uimenu(op4,'Label','b with depth',MenuSelectedField(),@(~,~)bwithde(ZG.newt2))
        uimenu(op4,'Label','b with time',MenuSelectedField(),@(~,~)bwithti(ZG.newt2))
        
        op5 = uimenu(options,'Label','p-value estimation');
        uimenu(op5,'Label','manual',MenuSelectedField(),@cb_man_pval_estimation)
        uimenu(op5,'Label','automatic',MenuSelectedField(),@cb_auto_pval_estimation)
        uimenu(options,'Label','get coordinates with Cursor',MenuSelectedField(),@cb_getcoord_with_cursor)
        uimenu(options,'Label','Cumlative Moment Release ',MenuSelectedField(),@cb_cum_moment_release)
        uimenu(options,'Label','Time Selection',MenuSelectedField(),@cb_time_selection);
        %uimenu(options,'Label',' Magnitude signature',MenuSelectedField(),@cb_mag_signature)
        uimenu(options,'Label','Save cumulative number curve',MenuSelectedField(),@cb_save_cumnumcurve)

        
    end
    function do_calSave
        msg.infodisp('  ','Save Data');
        [file1,path1] = uigetfile(fullfile(ZmapGlobal.Data.Directories.output, '*.dat'), 'Earthquake Datafile');
        out=[xt;cumu2]'; 
        save([path1 file1],'out','-ascii');
    end
    
    %% callback functions
    
    function cb_cut_mag_depth(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        cf=@()ZG.newt2;

        mycat=ZG.newt2; % points to same thing!
        app = range_selector(mycat);
        waitfor(app);
        ZG.maepi=mycat.subset(mycat.Magnitude >=ZG.CatalogOpts.BigEvents.MinMag);
    end
    
    function cb_overlayanothercurve(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
    end
    
    function cb_man_pval_estimation(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ttcat = ZG.newt2;
        clpval(1); % manual
    end
    
    function cb_auto_pval_estimation(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ttcat =ZG.newt2;
        clpval(3); %automatic
    end
    
    function cb_getcoord_with_cursor(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        gi = ginput(1);
        plot(gi(1),gi(2),'+');
    end
    
    function cb_cum_moment_release(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        morel;
    end
    
    function cb_time_selection(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        timeselect(4);
        ctimeplot;
    end
    
    function cb_mag_signature(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dispma0;
    end
    
    function cb_save_cumnumcurve(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        msg.infodisp('  ','Save Data');
        [file1,path1] = uigetfile(fullfile(ZmapGlobal.Data.Directories.output, '*.dat'), 'Earthquake Datafile');
        out=[xt;cumu2]'; 
        save([path1 file1], 'out', '-ascii');
    end
    
    function cb_info(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1,hlpStr2);
    end
    
    function cb_close(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newcat=a;
        f1=gcf;
        f2=gpf;
        close(f1);
        if f1~=f2
            figure(f2);
        end
    end
    
    function cb_print(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        printdlg;
    end
    
    function cb_back(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newcat = ZG.newcat;
        ZG.newt2 = ZG.newcat;
        stri = [' '];
        stri1 = [' '];
        ctimeplot;
    end
    
    function cb_keepas_newcat(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newcat = ZG.newt2 ;
        replaceMainCatalog(ZG.newt2);
        csubcata;
    end
    
end

function clpval(var1)
    % calculate the parameters of the modified Omori Law
    %
    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata
    
    % find the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters
    %
    % Input: Earthquake Catalog of an Cluster Sequence
    %
    %  best guesses about the meaning of var1:
    %         1: manual    / Mainshock
    %         2: --        / Main-Input
    %         3: automatic / Sequence
    %         4:
    %
    %         6: tmvar is empty and Mainshock chosen from dropdown
    %         7: tmvar is empty and Main-Input chosen from dropdown
    %         8: tmvar is not empty OR (tmvar is empty and Sequence chosen from dropdown)
    %
    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations
    %         A and B values of the Gutenberg Relation based on k
    %
    % Create an input window for magnitude thresholds and
    % plot cumulative number versus time to allow input of start and end
    % time
    %
    %  A.Allmann
    
    % TODO: burn this file and dance around the ashes.
    
    
    persistent autop
    
    par3=[];
    par5=[];
    
    tmvar=[];
    do_1345(var1);
    
    %input of parameters(Magnitude,Time)
    function do_1345(var1)
        global tmp1 tmp2 tmp3 tmp4 difp
        global xt cumu cumu2
        global freq_field1 freq_field2 freq_field3 freq_field4
        global h2 cplot_ax Info_p close_p  print_p
        global ppc  cplot2 hndl1
        global tmvar
        
        
        pplot = findobj('Type','Figure','-and','Tag','pplot');
        if ~isempty(pplot)
            figure(pplot);
            clf
        else
            if var1==3 || var1==4
                ppc=1;
            end
            pplot=figure(...
                'Name','P-Value Plot',...
                'NumberTitle','off',...
                'NextPlot','new',...
                'visible','off',...
                'Units','normalized',...
                'Tag', 'pplot',...
                'Position',[ 0.435  0.8 0.5 0.8]);
        end
        
        axis off
        
        ZG = ZmapGlobal.Data;
        ZG.newt2 = ZG.ttcat;              %function operates with single cluster
        
        autop = var1 == 4;
        
        %calculate start -end time of overall catalog
        [t0b, teb] = bounds(ZG.newt2.Date) ;
        tdiff=days(teb-t0b);       %time difference in days
        
        par3=tdiff/100;
        
        if par3 > 0.5
            par5 = par5/5;
        else
            par5 = par3;
        end
        
        % calculate cumulative number versus time and bin it
        %
        n = ZG.newt2.Count;
        if par3 >= 1
            [cumu, xt] = hist(ZG.newt2.Date, t0b:days(par3):teb);
        else
            [cumu, xt] = hist(ZG.newt2.Date-min(ZG.newt2.Date), 0:par5:tdiff);
        end
        
        if var1==3 || var1==4
            difp= [0 diff(cumu)];
        end
        cumu2 = cumsum(cumu);
        
        % plot time series
        %
        orient tall
        axis off
        
        rect = [0.22,  0.5, 0.55, 0.45];
        cplot_ax = axes('position', rect, 'NextPlot', 'add');
        plot(cplot_ax, xt, cumu2, 'ob');
        cplot_ax.Visible = 'off';
        
        cplot2 = plot(cplot_ax, xt,cumu2,'r');
        
        if var1==3  || var1==4
            plot(xt,difp/10,'g');
        end
        
        
        if exist('stri', 'var')
            v = axis;
            tea = text(v(1)+0.5,v(4)*0.9,stri) ;
            set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
        end
        
        grid
        if par3 >= 1
            xlabel(cplot_ax, 'Time in years')
        else
            xlabel(cplot_ax, sprintf('Time in days relative to %s', t0b))
        end
        
        ylabel(cplot_ax, 'Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        % Make the figure visible
        %
        set(cplot_ax, 'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on')
        
        rect=[0 0 1 1];
        h2=axes('Position',rect);
        set(h2,'visible','off');
        if var1==1
            str =  sprintf(['\n\n\nPlease select start and end time of the P-Value plot',...
                '\nClick first with the left Mouse Button at your start position\n',...
                'and then with the left Mouse Button at the end position']);
            te = text(0.2,0.37,str,'FontSize',14);
            set(pplot,'Visible','on');
            
            disp(str)
            
            
            seti = uicontrol('Units','normal',...
                'Position',[.4 .01 .2 .05],'String','Select Time1 ');
            
            
            XLim=get(cplot_ax,'XLim');
            
            
            M1b = [];
            M1b= ginput(1);
            tt3= M1b(1);
            tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
            text( M1b(1),M1b(2),['|: T1=',tt4] )
            set(seti,'String','Select Time2');
            
            pause(0.1)
        else
            nn_=find(difp==max(difp));
            nnn=nn_(1,1)-2;
        end
        if var1==3
            tmvar=1;           %temperal variable
            if par3>=1
                tmp3=t0b+nnn*days(par3);
            else
                tmp3=nnn*par5;
            end
            str = sprintf('\n\n\nPlease select the end time of the P-value plot.\nClick with the left Mouse Button at the end position');
            te = text(0.15,0.37,str,'FontSize',14);
            set(pplot,'Visible','on');
            disp(str)
            XLim=get(cplot_ax,'XLim');
        end
        if var1==1 || var1==3
            M2b = [];
            M2b = ginput(1);
            tt3= M2b(1);
            tt5=num2str((tt3-0.22)*(XLim(2)-XLim(1))*(1/.55)+XLim(1));
            text( M2b(1),M2b(2),['|: T2=',tt5] )
            
            pause(0.1)
            delete(seti)
            
            watchoff
            
            set(te,'visible','off');
            
            tmp2=min(ZG.ttcat(:,6));
            freq_field1= uicontrol('Style','edit',...
                'Position',[.70 .35 .1 .04],...
                'Units','normalized','String',num2str(tmp2),...
                'callback',@callbackfun_001);
            
            tmp1=max(ZG.ttcat(:,6));
            freq_field2=uicontrol('Style','edit',...
                'Position',[.70 .28 .1 .04],...
                'Units','normalized','String',num2str(tmp1),...
                'callback',@callbackfun_002);
            
            if var1==1
                tmp3=str2double(tt4);
                if tmp3 < 0
                    tmp3=0;
                end
            end
            freq_field3=uicontrol('Style','edit',...
                'Position',[.70 .21 .1 .04],...
                'Units','normalized','String',num2str(tmp3),...
                'callback',@callbackfun_003);
            
            tmp4=str2double(tt5);
            freq_field4=uicontrol('Style','edit',...
                'Position',[.70 .14 .1 .04],...
                'Units','normalized','String',num2str(tmp4),...
                'callback',@callbackfun_004);
            
            
            
            txt1 = text(...
                'Position',[0.15 0.37 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Minimum Magnitude used for P-Value:');
            
            txt2 = text(...
                'Position',[0.15 0.30 h2],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Maximum Magnitude used for P-Value:');
            
            
            txt3 = text(...
                'Position',[0.15 0.23 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Minimum Time used for P-Value:');
            
            txt4 = text(...
                'Position',[0.15 0.16 h2],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Maximum Time used for P-Value:');
            
            Info_p = uicontrol('Style','Pushbutton',...
                'String','Info ',...
                'Position',[.3 .05 .10 .06],...
                'Units','normalized', 'Callback', @(~,~)clinfo("Pval1"));
            
            
            
            
            
            
            close_p =uicontrol('Style','Pushbutton',...
                'Position', [.45 .05 .10 .06 ],...
                'Units','normalized','Callback',@(~,~)set(findobj('Tag','pplot'),'Visible','off'),...
                'String','Close');
            print_p = uicontrol('Style','Pushbutton',...
                'Position',[.15 .05 .1 .06],...
                'Units','normalized','Callback', @(~,~)printdlg,...
                'String','Print');
            
            if var1==3
                labelList=['Sequence'];
            else
                labelList=['Mainshock| Main-Input| Sequence' ];
            end
            
            labelPos= [.6 .05 .2 .06];
            hndl1 =uicontrol(...
                'style','popup',...
                'units','normalized',...
                'position',labelPos,...
                'string',labelList,...
                'callback',@callbackfun_007);
            
            msg.dbfprintf(['\n \n \nPlease give in parameters in green fields\n',...
                'This parameters will be used as the threshold\n for the P-Value.\n',...
                'After input push GO to continue. ']);
        end
        if autop
            figure(pplot);
            Info_p = uicontrol('Style','Pushbutton',...
                'String','Info ',...
                'Position',[.3 .05 .10 .06],...
                'Units','normalized', 'Callback', @(~,~)clinfo("Pval1"));
            
            close_p =uicontrol('Style','Pushbutton',...
                'Position', [.45 .05 .10 .06 ],...
                'Units','normalized', 'Callback', @(~,~)set(findobj('Tag','pplot'),'Visible','off'),...
                'String','Close');
            print_p = uicontrol('Style','Pushbutton',...
                'Position',[.15 .05 .1 .06],...
                'Units','normalized','Callback',  @(~,~)printdlg,...
                'String','Print');
            
            var1=8;
            do_678(var1);
            
        end
        
        function callbackfun_001(mysrc,myevt)
            
            tmp2=str2double(freq_field1.String);
            freq_field1.String=num2str(tmp2);
        end
        
        function callbackfun_002(mysrc,myevt)
            
            tmp1=str2double(freq_field2.String);
            freq_field2.String=num2str(tmp1);
        end
        
        
        function callbackfun_004(mysrc,myevt)
            tmp4=str2double(freq_field4.String);
            freq_field4.String=num2str(tmp4);
        end
        
        function callbackfun_003(mysrc,myevt)
            tmp3=str2double(freq_field3.String);
            freq_field3.String=num2str(tmp3);
        end
        
        function callbackfun_007(mysrc,myevt)
            if ~isempty(tmvar)
                
                var1=8;
                do_678(var1);
            else
                var1 = hndl1.Value + 5;
                do_678(var1);
            end
        end
        
    end
    %computation part after parameter input
    function do_678(var1)
        global tmp1 tmp2 tmp3 tmp4 difp
        global xt cumu cumu2
        global freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button
        global h2 cplot_ax Info_p
        global p c dk tt pc loop nn pp nit t err1x err2x
        global cstep pstep tmpcat ts tend eps1 eps2
        global sdc sdk sdp qp aa bb loopcheck
        global hndl1
        global tmeqtime tmvar
        
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
        err1x=0;
        err2x=0;
        ts=0.0000001;
        if ~autop            %input was manual
            
            %Build timecatalog
            
            mains=find(ZG.ttcat(:,6)==max(ZG.ttcat(:,6)));
            mains=ZG.ttcat(mains(1),:);         %biggest shock in sequence
            if var1==7    %input of maintime of sequence(normally onset of high seismicity)
                figure(pplot);
                seti = uicontrol('Units','normal',...
                    'Position',[.4 .01 .2 .05],'String','Select Maintime');
                
                XLim=get(cplot_ax,'XLim');
                M1b = [];
                M1b= ginput(1);
                tt3= M1b(1);
                tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
                text( M1b(1),M1b(2),['|: T1=',tt4] )
                tt4=str2double(tt4);
                delete(seti);
                if tt4>tmp3
                    tt4=tmp3;
                    disp('maintime was set to starttime of estimate')
                end
            end
            if par3<1
                if var1==7
                    mains=find(ZG.ttcat(:,3)>(days(tt4)+ZG.ttcat(1,3)));
                    mains=ZG.ttcat(mains(1),:);
                end
                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=days(tmp3)+ZG.ttcat(1,3) &    ZG.ttcat(:,3)<=days(tmp4)+ZG.ttcat(1,3)),:);
                tmp6=days(tmp3)+ZG.ttcat(1,3);
            else
                if var1==7
                    mains=find(ZG.ttcat(:,3)>tt4);
                    mains=ZG.ttcat(mains(1),:);
                end
                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=tmp3 & ZG.ttcat(:,3)<=tmp4),:);
                tmp6=tmp3;
            end
            tmpcat=tmpcat(find(tmpcat(:,6)>=tmp2 & tmpcat(:,6)<=tmp1),:);
            if var1 ==6 || var1==7
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
            
            %automatic estimate works with whole sequence
        else
            tmeqtime=clustime(ZG.ttcat);
            tmeqtime=tmeqtime-tmeqtime(1);
            tmeqtime=tmeqtime(2:length(tmeqtime));
            
        end
        tend=tmeqtime(length(tmeqtime)); %end time
        
        
        %Loop begins here
        nn=length(tmeqtime);
        loop=0;
        tt=tmeqtime(nn);
        t=tmeqtime;
        
        MIN_CSTEP = 0.000001;
        MIN_PSTEP = 0.00001;
        % following moved into MyPvalClass
        mpvc = MyPvalClass;
        [loopcheck, c, p, dk, sdc, sdp, sdk]=mpvc.ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');%call of function who calculates parameters
        
        if ~autop
            figure(pplot);
            delete([freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button]);
            cla;
        end
        if loopcheck<500
            %round values on two digits
            p=round(p, -2);
            sdp=round(sdp, -2);
            c=round(c, -3);
            sdc=round(sdc, -3);
            dk=round(dk, -2);
            sdk= round(sdk, -2);
            aa=round(aa, -2);
            bb=round(bb, -2);
            
            tt1=num2str(p);
            txt1 = text(...
                'Position',[0.15 0.37 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String',['P-Value: ',tt1]);
            
            tt1=num2str(sdp);
            txt1 = text(...
                'Position',[0.5 0.37 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Standard Deviation: ',tt1]);
            
            
            tt1= num2str(c);
            txt1 = text(...
                'Position',[0.15 0.32 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Constant c: ',tt1]);
            tt1=num2str(sdc);
            txt1 = text(...
                'Position',[0.5 0.32 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Standard Deviation ',tt1]);
            
            
            tt1= num2str(dk);
            txt1 = text(...
                'Position',[0.15 0.27 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Constant k: ',tt1]);
            tt1=num2str(sdk);
            txt1 = text(...
                'Position',[0.5 0.27 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Standard Deviation: ',tt1]);
            cof=mpvc.pk/mpvc.qp;
            tt2=num2str(cof);
            tt3=num2str(pc);
            tt4=num2str(qp);
            cog = cof* mpvc.pc^obj.qp;
            tt5=num2str(cog);
            
            tt1=['Integrated Omori Law: N(t) = ',tt2,'(t+',tt3,')^',tt4,' -   ',tt5];
            text1= text(...
                'Position',[0.1 0.21 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',tt1);
            
            tt1=num2str(aa);
            text1= text(...
                'Position',[0.15 0.15 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String',['A-value: ',tt1]);
            
            
            tt1=num2str(bb);
            text1= text(...
                'Position',[0.55 0.15 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String',['B-value: ',tt1]);
            
            set(Info_p, 'callback',@(~,~)clinfo("Pval2"));
            
            if autop
                tt1=num2str(tmeqtime(1));
                tt2=num2str(tend);
                tt3=num2str(min(ZG.ttcat(:,6)));
                tt4=num2str(max(ZG.ttcat(:,6)));
            else
                tt1=num2str(tmp3);
                tt2=num2str(tmp4);
                tt3=num2str(tmp2);
                tt4=num2str(tmp1);
            end
            tt5=[tt1,'<=t<=',tt2];
            tt6=[tt3,'<=mag<=',tt4];
            text1=text(0.5, .55,tt5);
            text2=text(0.5 ,.6,tt6);
            
            
        else    %if loopcheck
            
            
            str = ['\n \n \nThe P-Value evaluation leads to no stable result! \nTo avoid a segmentation fault the algorithm was shut down.\nFor more information hit the Info button.'];
            te = text(0.2,0.37,str,'FontSize',12);
            set(Info_p, 'callback',@(~,~)clinfo("UnstablePval"));
        end
        if autop
            finish_up()
            return
        end
        
        % autop is false... do it manually
        if par3>=1
            tdiff = round(tmpcat(length(tmpcat(:,1)),3)-tmpcat(1,3));
        else
            tdiff = (tmpcat(length(tmpcat(:,1)),3)-tmpcat(1,3))*365;
        end
        % set arrays to zero
        %
        if par3<1
            par5 = par3/5;
        end
        
        % calculate cumulative number versus time and bin it
        %
        %  n = length(tmpcat(:,1));
        if par3>=1
            [cumu, xt] = hist(tmpcat(:,3),(tmpcat(1,3):days(par3):tmpcat(length(tmpcat(:,1)),3)));
        else
            [cumu, xt] = hist((tmpcat(:,3)-tmpcat(1,3))*365,(0:par5:tdiff));
        end
        if exist('ppc','var')
            difp= [0 diff(cumu)];
        end
        cumu2 = cumsum(cumu);
        
        % plot time series
        %
        delete(cplot_ax)
        orient tall
        rect = [0.22,  0.5, 0.55, 0.45];
        cplot_ax = axes('position',rect);
        cplot_ax.NextPlot = 'add';
        tiplo = plot(cplot_ax, xt,cumu2,'ob','Tag','tiplo');
        cplot_ax.Visible = 'off';
        plot(cplot_ax,xt,cumu2,'r','Tag','tiplo2');
        if exist('ppc')
            plot(cplot_ax, xt,difp,'g');
        end
        
        if exist('stri', 'var')
            v = axis;
            tea = text(v(1)+0.5,v(4)*0.9,stri) ;
            set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
        end %% if stri
        
        
        grid
        if par3>=1
            xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        else
            xlabel(['Time in days relative to ',num2str(tmpcat(1,3))],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        end
        ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        % Make the figure visible
        %
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on')
        
        finish_up()
        
        function finish_up()
            tmvar=[];
            if ~isempty(hndl1)
                delete(hndl1);
                hndl1=[];
            end
        end
    end
end

