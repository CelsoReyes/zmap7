classdef cgr_timeplot < ZmapFigureFunction
    % description of this function
    %
    % in the function that generates the figure where this function can be called:
    %
    %     % create some menu items... 
    %     h=sample_ZmapFunction.AddMenuItem(hMenu,@()catfn) %create subordinate to menu item with handle hMenu
    %     % create the rest of the menu items...
    %
    %  once the menu item is clicked, then sample_ZmapFunction.interative_setup(true,true) is called
    %  meaning that the user will be provided with a dialog to set up the parameters,
    %  and the results will be automatically calculated & plotted once they hit the "GO" button
    %
    
    properties
        % my properties
        mycat=ZmapCatalog();
    end
    
    properties(Constant)
        FigTag = 'cum';
        PlotTag='myplot';
    end
    
    properties
        % declare all the variables that need to be shared in this program/function, but that the end user
        % won't care about.
    end
    
    methods
        function obj=cgr_timeplot(varargin) %CONSTRUCTOR
            % usage:
            %   cgr_timeplot(catalog)
            
            errror('not implemented')
            
            obj.FigureDetails={...
                'Name','Cumulative Number',...
                'NumberTitle','off', ...
                'NextPlot','replace', ...
                'backingstore','on',...
                'Visible','off', ...
                'Position',position_in_current_monitor(ZG.map_len(1)-100, ZG.map_len(2)-20)};
            
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            if nargin==0
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                mycat=varargin{1};
                %run this function without human interaction
                
            end
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            
            zdlg=ZmapDialog(...
                obj,...  pass it a handle that it can change when the OK button is pressed.
                @obj.doIt...  if OK is pressed, then this function will be executed.
                );
            
            zdlg.Create('my dialog title')
            % The dialog runs. if:
            %  OK is pressed -> assigns 
        end
        
        function CheckPreconditions(obj)
            % check to make sure any inportant conditions are met. 
            % for example, 
            % - catalogs have what are expected.
            % - required variables exist or have valid values
            assert(true==true,'laws of logic are broken.');
        end
        
        function Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            %
            % results of the calculation should be stored in fields belonging to obj.Result
            obj.Result.Data=[];
        end
        
        
function CreateMenu(obj)
        add_menu_divider();
        ztoolsmenu = uimenu('Label','ZTools');
        analyzemenu=uimenu('Label','Analyze');
        plotmenu=uimenu('Label','Plot');
        catmenu=uimenu('Label','Catalog');
        
        
        winlen_days = days(ZG.compare_window_dur / ZG.bin_dur);
        
        uimenu(catmenu,'Label','Rename Catalog (this subset)',MenuSelectedField(),@cb_rename_cat);
        uimenu(catmenu,'Label','Set as main catalog',MenuSelectedField(),@cb_keep); % Replaces the primary catalog, and replots this subset in the map window
        uimenu(catmenu,'Separator','on','Label','Reset',MenuSelectedField(),@cb_resetcat); % Resets the catalog to the original selection
        
        uimenu(ztoolsmenu,'Label','Cuts in time, magnitude and depth',MenuSelectedField(),@cut_tmd_callback)
        uimenu(ztoolsmenu,'Label','Cut in Time (cursor) ',MenuSelectedField(),@cursor_timecut_callback);
        uimenu(ztoolsmenu,'Label','Compare two rates (fit)',MenuSelectedField(),@cb_comparerates_fit);
        uimenu(ztoolsmenu,'Label','Compare two rates ( No fit)',MenuSelectedField(),@cb_comparerates_nofit);
        
        uimenu(plotmenu,'Label','Date Ticks in different format',MenuSelectedField(),@(~,~)newtimetick,...
            'Enable','off');
        uimenu(plotmenu,'Label','Overlay another curve (hold)',MenuSelectedField(),@cb_hold)
        
        uimenu (analyzemenu,'Label','Decluster the catalog',MenuSelectedField(),@(~,~)inpudenew(mycat))
        %uimenu(ztoolsmenu,'Label','Day/Night split ',MenuSelectedField(),@cb_006)
        
        op3D  =   uimenu(plotmenu,'Label','Time series ');
        uimenu(op3D,'Label','Time-depth plot ',MenuSelectedField(),@(~,~)TimeDepthPlotter.plot(mycat));
        uimenu(op3D,'Label','Time-magnitude plot ',MenuSelectedField(),@(~,~)TimeMagnitudePlotter.plot(mycat));
        
        op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
        uimenu(op4B, 'Label', 'beta values: LTA(t) function',MenuSelectedField(),{@cb_z_beta_ratechanges,'bet'});
        uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',MenuSelectedField(), {@cb_betaTriangle,'newcat'})
        uimenu(op4B,'Label','z-values: AS(t)function',MenuSelectedField(),{@cb_z_beta_ratechanges,'ast'})
        uimenu(op4B,'Label','z-values: Rubberband function',MenuSelectedField(),{@cb_z_beta_ratechanges,'rub'})
        uimenu(op4B,'Label','z-values: LTA(t) function ',MenuSelectedField(),{@cb_z_beta_ratechanges,'lta'});
        
        
        op4 = uimenu(plotmenu,'Label','Mc and b-value estimation');
        uimenu(op4,'Label','automatic',MenuSelectedField(),@cb_010)
        uimenu(op4,'label','Mc with time ',MenuSelectedField(),{@plotwithtime,'mc'});
        uimenu(op4,'Label','b with depth',MenuSelectedField(),@(~,~)bwithde2('newt2'))
        uimenu(op4,'label','b with magnitude',MenuSelectedField(),@(~,~)bwithmag);
        uimenu(op4,'label','b with time',MenuSelectedField(),{@plotwithtime,'b'});
        
        op5 = uimenu(analyzemenu,'Label','p-value estimation');
        
        %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
        %displayed (the catalog mycat).
        uimenu(op5,'Label','Completeness in days after mainshock',MenuSelectedField(),@(~,~)mcwtidays)
        uimenu(op5,'Label','Define mainshock',MenuSelectedField(),@cb_016,...
            'Enable','off');
        uimenu(op5,'Label','Estimate p',MenuSelectedField(),@cb_pestimate);
        
        %In the following instruction the program pvalcat2.m is called. This program computes a map of p in function of the chosen values for the minimum magnitude and
        %initial time.
        uimenu(op5,'Label','p as a function of time and magnitude',MenuSelectedField(),@(~,~)pvalcat2())
        uimenu(op5,'Label','Cut catalog at mainshock time',...
            MenuSelectedField(),@cb_cut_mainshock)
        
        op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
        uimenu(op6,'Label','Compute the fractal dimension D',MenuSelectedField(),{@cb_computefractal,2});
        uimenu(op6,'Label','Compute D for random catalog',MenuSelectedField(),{@cb_computefractal,5});
        uimenu(op6,'Label','Compute D with time',MenuSelectedField(),{@cb_computefractal,6});
        uimenu(op6,'Label',' Help/Info on  fractal dimension',MenuSelectedField(),@(~,~)showweb('fractal'))
        
        uimenu(ztoolsmenu,'Label','Cumlative Moment Release ',MenuSelectedField(),@(~,~)morel())
        
        op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
        uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ',MenuSelectedField(),@(~,~)doinverse_michael())
        uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ',MenuSelectedField(),@(~,~)doinversgep_pc())
        uimenu(op7,'Label','Stress tensor with time',MenuSelectedField(),@(~,~)stresswtime())
        uimenu(op7,'Label','Stress tensor with depth',MenuSelectedField(),@(~,~)stresswdepth())
        uimenu(op7,'Label',' Help/Info on  stress tensor inversions',MenuSelectedField(),@(~,~)showweb('stress'))
        op5C = uimenu(plotmenu,'Label','Histograms');
        
        uimenu(op5C,'Label','Magnitude',MenuSelectedField(),{@cb_histogram,'Magnitude'});
        uimenu(op5C,'Label','Depth',MenuSelectedField(),{@cb_histogram,'Depth'});
        uimenu(op5C,'Label','Time',MenuSelectedField(),{@cb_histogram,'Date'});
        uimenu(op5C,'Label','Hr of the day',MenuSelectedField(),{@cb_histogram,'Hour'});
        
        
        uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
            'Separator','on',...
            MenuSelectedField(),{@calSave1, xt, cumu2});
        
        uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
            MenuSelectedField(),{@calSave7, xt, cumu2, as})
        addAboutMenuItem();
    end
        
        function ClearFigure(obj)
        end
            
        function plot(obj,varargin)
            % plots the results somewhere
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            
            % clear(reset) my axes if I already exist
            figure(f)
            delete(findobj(f,'Type','axes'));
            obj.ax=axes;
            
            % do the plotting
            obj.hPlot=plot(obj.ax,obj.Result.x,obj.Result.y, obj.lstyle, varargin{:});
 
            % do the labeling
            xlabel(obj.ax,['zmapFunction plot: ', obj.plotlabel]);
        end
        
        function ModifyGlobals(obj)
            % change the ZmapGlobal variable, if appropriate
           % obj.ZG.SOMETHING = obj.Results.SOMETHING
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,catalogfn)
            % create a menu item that will be used to call this function/class
            
            h=uimenu(parent,'Label','testmenuitem',...
                MenuSelectedField(), @(~,~)cgr_timeplot(catalogfn())...
            );
        end
        
    end % static methods
    
end %classdef

%% Callbacks

% All callbacks should set values within the same field. Leave
% the gathering of values to the SetValuesFromDialog button.

function timeplot(mycat, nosort)
    % timeplot plots selected events as cummulative # over time
    %
    % Time of events with a Magnitude greater than ZG.CatalogOpts.BigEvents.MinMag will
    % be shown on the curve.  Operates on mycat, resets  b  to mycat
    %     ZG.newcat is reset to:
    %                       - "primeCatalog" if either "Back" button or "Close" button is pressed.
    %                       - mycat if "Save as Newcat" button is pressed.
    %
    %  
    %
%     ttlStr='The Cumulative Number Window                  ';
%     hlpStr1= ...
%         ['                                                     '
%         ' This window displays the seismicity in the sel-     '
%         ' ected area as a cumulative number plot.             '
%         ' Options from the Tools menu:                        '
%         ' Cuts in magnitude and  depth: Opens input para-     '
%         '    meter window                                     '
%         ' Decluster the catalog: Will ask for declustering    '
%         '     input parameter and decluster the catalog.      '
%         ' AS(t): Evaluates significance of seismicity rate    '
%         '      changes using the AS(t) function. See the      '
%         '      Users Guide for details                        '
%         ' LTA(t), Rubberband: ditto                            '
%         ' Overlay another curve (hold): Allows you to plot    '
%         '       one or several more curves in the same plot.  '
%         '       select "Overlay..." and then selext a new     '
%         '       subset of data in the map window              '
%         ' Compare two rates: start a comparison and moddeling '
%         '       of two seismicity rates based on the assumption'
%         '       of a constant b-value. Will calculate         '
%         '       Magnitude Signature. Will ask you for four    '
%         '       times.                                        '
%         '                                                     '];
%     hlpStr2= ...
%         ['                                                      '
%         ' b-value estimation:    just that                     '
%         ' p-value plot: Lets you estimate the p-value of an    '
%         ' aftershock sequence.                                 '
%         ' Save cumulative number cure: Will save the curve in  '
%         '        an ASCII file                                 '
%         '                                                      '
%         ' The "Keep as newcat" button in the lower right corner'
%         ' will make the currently selected subset of eartquakes'
%         ' in space, magnitude and depth the current one. This  '
%         ' will also redraw the Map window!                     '
%         '                                                      '
%         ' The "Back" button will plot the original cumulative  '
%         ' number curve without statistics again.               '
%         '                                                      '];
    
    
    % Updates:
    % Added callback in op5 for afterschock sequence rate change detection (07.07.03: J. Woessner)
    
    report_this_filefun();
    myFigName='Cumulative Number';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    
    global statime
    [t0b, teb] = mycat.DateRange() ;
    ZG = ZmapGlobal.Data;
    if ~exist('xt','var')
        xt=[]; % time series that will be used
    end
    if ~exist('as','var')
        as=[]; % z values, maybe? used by the save callback.
    end
    
    if isempty(ZG.bin_dur) %binning
        ZG.bin_dur = days(1);
    end

    if ~exist('nosort','var')
        nosort = 'of'  ;
    end
    
    if strcmpi(nosort,'of')
        mycat.sort('Date');
    else  % f
        if t3>t2
            % logic does not make sense within ZmapCatalog.
            error('this doesn''t make sense');
        end
        
    end
    
    cumu2=[]; %predeclare this thing for the callback function
    
    

    
    % Find out if figure already exists
    
    cum = myFigFinder();
    % Set up the Cumulative Number window
    
    if isempty(cum)
        cum = figure_w_normalized_uicontrolunits( ...
            'Name','Cumulative Number',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Tag','cum',...
            'Position',position_in_current_monitor(ZG.map_len(1)+100, ZG.map_len(2)+20));
        
        
        
        create_my_menu();
            
        uicontrol('Units','normal','Position',[.0 .0 .1 .05],...
            'String','Reset',...
            'callback',@cb_resetcat,...
            'tooltip','Resets the catalog to the original selection')
        
        uicontrol('Units','normal','Position',[.70 .0 .3 .05],...
            'String','Set as main catalog',...
            'callback',@cb_keep,...
            'tooltip','Plots this subset in the map window')
        
        ZG.hold_state2=false;
        
    end
    figure(cum);
    ht=gca;
    if ZG.hold_state2
        tdiff=max(mycat.Date) - min(mycat.Date); % added by CR
        cumu = 0:1:(tdiff/days(ZG.bin_dur))+2;
        cumu2 = 0:1:(tdiff/days(ZG.bin_dur))-1;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;
        [cumu, xt] = histcounts(mycat.Date, t0b: ZG.bin_dur :teb);
        %xt = xt + (xt(2)-xt(1))/2; xt(end)=[]; % convert from edges to centers!
        cumu2 = cumsum(cumu);
        
        
        set(gca,'NextPlot','add')
        axes(ht)
        tiplot2 = plot(ht,mycat.Date,(1:mycat.Count),'r');
        set(tiplot2,'LineWidth',2.0)
        
        ds=dbstack;
        if numel(ds)>1
            tiplot2.DisplayName=['from ' ds(2).name];
        end
        
        ZG.hold_state2=false;
        return
    end
    
    fig=figure(cum);
    delete(findobj(cum,'Type','Axes'));
    % delete(sicum)
    ax=axes(fig);
    set(gca,'NextPlot','replace')
    watchon;
    
    set(ax,'visible','off',...
        'FontSize',ZmapGlobal.Data.fontsz.s,...
        'FontWeight','normal',...
        'LineWidth',1.5,...
        'Box','on',...
        'SortMethod','childorder')
    
    if isempty(ZG.newcat)
        ZG.newcat =ZG.primeCatalog;
    end
    
    % select big events ( > ZG.CatalogOpts.BigEvents.MinMag)
    %
    l = mycat.Magnitude >= ZG.CatalogOpts.BigEvents.MinMag;
    big = mycat.subset(l);
    %calculate start -end time of overall catalog
    statime=[];
    par2=ZG.bin_dur;
    [t0b, teb] = ZG.primeCatalog.DateRange() ;
    
    tdiff = (teb-t0b)/ZG.bin_dur;
    
    if ZG.bin_dur >= days(1)
        tdiff = round(tdiff);
    end
    
    % calculate cumulative number versus time and bin it
    if ZG.bin_dur >=days(1)
        [cumu, xt] = histcounts(mycat.Date, t0b:ZG.bin_dur:teb);
    else
        [cumu, xt] = histcounts(...
            (mycat.Date-min(mycat.Date)) + ZG.bin_dur,...
            (0: ZG.bin_dur :(tdiff + 2*ZG.bin_dur)));
    end
    cumu2=cumsum(cumu);
    % plot time series
    %
    set(fig,'PaperPosition',[0.5 0.5 5.5 8.5])
    rect = [0.25,  0.18, 0.60, 0.70];
    axes(fig,'position',rect)
    ax.NextPlot='add';
    set(ax,'visible','off')
    
    nu = (1:mycat.Count);
    %nu(mycat.Count) = mycat.Count;  %crash if the count is zero
    
    tiplot2 = plot(ax, mycat.Date, nu, 'b', 'LineWidth', 2.0);
    
    % plot end of data
    pl = plot(ax,teb,mycat.Count,'rs');
    set(pl,'LineWidth',1.0,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','r');
    
    pl = plot(ax,[max(mycat.Date),teb],[mycat.Count, mycat.Count],'k:');
    set(pl,'LineWidth',2.0);
    
    set(ax,'Ylim',[0 mycat.Count*1.05]);
    
    % plot big events on curve
    %
    if ZG.bin_dur>=days(1)
        if ~isempty(big)
            l = mycat.Magnitude >= ZG.CatalogOpts.BigEvents.MinMag;
            f = find(l);
            hold(ax,'on')
            bigplo = plot(ax,big.Date,f,'hm');
            set(bigplo,'LineWidth',1.0,'MarkerSize',10,...
                'MarkerFaceColor','y','MarkerEdgeColor','k')
            stri4 = [];
            [le1] = big.Count;
            for i = 1:le1
                s = sprintf('  M=%3.1f',big.Magnitude(i));
                stri4 = [stri4 ; s];
            end   % for i
            hold(ax,'off')
        end
    end %if big
    
    if ZG.bin_dur>=days(1)
        xlabel(ax,'Time in years ','FontSize',ZmapGlobal.Data.fontsz.s)
    else
        statime=mycat.Date(1) - ZG.bin_dur;
        xlabel(ax,['Time in days relative to ',char(statime)],...
            'FontWeight','bold','FontSize',ZG.fontsz.m)
    end
    ylabel(ax,'Cumulative Number ','FontSize',ZG.fontsz.s)
    
    title(ax,['"', mycat.Name, '": Cumulative Earthquakes over time ' newline],'Interpreter','none'); %FIXME I shouldn't need to use a newline here
    
    % Make the figure visible
    %
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
        'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
        'Box','on')
    figure(cum);
    axes(ax);
    set(cum,'Visible','on');
    watchoff(cum)
    
    
    
    %% ui functions
    
    
    %% callback functions
    
    
    function cut_tmd_callback(~,~)
        cf = @()ZG.newt2;
        [tmpcat,ZG.maepi,ZG.CatalogOpts.BigEvents.MinMag] = catalog_overview(ZmapCatalogView(cf), ZG.CatalogOpts.BigEvents.MinMag);
        ZG.newt2=tmpcat.Catalog();
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
    end
    
    function cursor_timecut_callback(~,~)
        % will change ZG.newt2
        [tt1,tt2]=timesel('cum');
        ZG.newt2=ZG.newt2.subset(ZG.newt2.Date>=tt1&ZG.newt2.Date<=tt2);
        ZG=ZmapGlobal; 
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
    end
    
    function cb_hold(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state2=true;
    end
    
    function cb_comparerates_nofit(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ic=0;
        dispma3;
    end
    
    function cb_z_beta_ratechanges(mysrc,myevt,sta)
        % beta values:
        %   'bet' : LTA(t) function
        %   'ast' : AS(t) function
        %   'rub' : Rubberband function
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(gcf,'Pointer','watch');
        ZG = ZmapGlobal.Data;
        newsta(sta, ZG.newt2);
    end
    
    function cb_betaTriangle(~, ~, catname)
        betatriangle(ZG.(catname),t0b:ZG.bin_dur:teb);
    end
    function cb_010(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state=false;
        bdiff2();
    end
    
    function plotwithtime(mysrc,myevt,sPar)
        %sPar tells what to plot.  'mc', 'b'
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot_McBwtime('ThisIsACatalog',sPar);
    end
    
    
    function cb_016(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        error('not implemented: define mainshock.  Original input_main.m function broken;')
    end
    
    function cb_pestimate(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state=false;
        pvalcat();
    end
    
    function cb_cut_mainshock(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        l = min(find( mycat.Magnitude == max(mycat.Magnitude) ));
        mycat = mycat(l+1:mycat.Count,:);
        z
        ZG=ZmapGlobal; 
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
    end
    
    function cb_computefractal(mysrc,myevt, org)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        if org==2
            E = mycat;
        end % FIXME this is probably unneccessary, but would need to be traced in startfd before deleted
        startfd(org);
    end
    
    function cb_histogram(mysrc,myevt,hist_type)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        hisgra(mycat, hist_type);
    end
    
    function cb_resetcat(mysrc,myevt)
        % Resets the catalog to the original selection
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nosort = 'of';
        % error ZG.newcat = ZG.mycat;
        mycat = ZG.newcat;
        close(cum);
        timeplot(mycat,nosort);
    end
    
    function cb_keep(mysrc,myevt)
        % Plots this subset in the map window
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newcat = mycat;
        replaceMainCatalog(mycat) ;
        %ZmapMessageCenter.update_catalog();
        zmap_update_displays();
    end
    
    function cb_rename_cat(~,~)
        s.prompt='Catalog Name:'; s.value=mycat.Name;
        [~,~, mycat.Name]=smart_inputdlg('Rename',s);
    end
end
