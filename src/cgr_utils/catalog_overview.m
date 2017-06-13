function mycat = catalog_overview(mycat)
    % catalog_overview presents a window where catalog summary statistics show and can be edited
    
    %  This scriptfile ask for several input parameters that can be setup
    %  at the beginning of each session. The default values are the
    %  extrema in the catalog
    
    report_this_filefun(mfilename('fullpath'));
    global fontsz term
    global file1 tim1 tim2 minma2 maxma2 minde maxde maepi dep1 dep2 dep3
    global ty1 ty2 ty3
    
    %INDICES INTO ZMAP ARRAY
    lon_idx = 1;
    lat_idx = 2;
    decyr_idx = 3;
    month_idx = 4;
    day_idx = 5;
    mag_idx = 6;
    dep_idx = 7;
    hr_idx = 8;
    min_idx = 9;
    sec_idx = 10;
    
    %  default values
    t0b = min(mycat(:,decyr_idx));
    teb = max(mycat(:,decyr_idx));
    tdiff = (teb - t0b)*365;
    
    if exist('par1') == 0
        %  if tdiff>10                 %select bin length respective to time in catalog
        %     par1 = ceil(tdiff/100);
        %  elseif tdiff<=10 & tdiff>1
        %     par1 = 0.1;
        %  elseif tdiff<=1
        %     par1 = 0.01;
        %  end
        par1 = 30;
    end
    
    big_evt_minmag = max(mycat(:,mag_idx)) -0.2;
    dep1 = 0.3*max(mycat(:,dep_idx));
    dep2 = 0.6*max(mycat(:,dep_idx));
    dep3 = max(mycat(:,dep_idx));
    minti = min(mycat(:,decyr_idx));
    maxti  = max(mycat(:,decyr_idx));
    minma = min(mycat(:,mag_idx));
    maxma = max(mycat(:,mag_idx));
    mindep = min(mycat(:,dep_idx));
    maxdep = max(mycat(:,dep_idx));
    
    fignum = create_dialog();
    
    watchoff
    str = [ 'Please Select a subset of earthquakes'
        ' and press Go                        '];
    welcome('Message',str);
    
    function fignum = create_dialog()
        % create_dialog - creates the dialog box
        
        %
        % make the interface
        %
        fignum = figure_w_normalized_uicontrolunits(...
            'Units','pixel','pos',[300 100 300 400 ],...
            'Name','General Parameters!',...
            'visible','off',...
            'NumberTitle','off',...
            'MenuBar','none',...
            'NextPlot','new');
        axis off
        
        % EQ's in catalog
        
        txt3 = text(...
            'Color',[0.8 0 0 ],...
            'Position',[0.02 1.00 0 ],...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String',' EQs in catalog: ');
        
        n_eqs_field=uicontrol('Style','edit','Position',[.70 .90 .22 .05],...
            'Units','normalized','String',num2str(length(mycat)),...
            'Value',length(mycat),...
            'Tag','mapview_nquakes_field',...
            'Callback',@upate_numeric);
        
        % plot big events with M gt
        big_evt_field=uicontrol('Style','edit','Position',[.70 .80 .22 .05],...
            'Units','normalized','String',num2str(big_evt_minmag),...
            'Value',big_evt_minmag,...
            'Tag','mapview_big_evt_field',...
            'Callback',@update_numeric);
        
        text(...
            'Position',[0.02 0.87 0 ],...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Plot Big Events with M > ');
        
        
        %  bin length in days
        binlen_days_field=uicontrol('Style','edit','Position',[.70 .70 .22 .05],...
            'Units','normalized','String',num2str(par1),...
            'Value', par1,...
            'Tag','mapview_binlen_field',...
            'Callback','par1=str2double(get(binlen_days_field,''String'')); set(binlen_days_field,''String'',num2str(par1));');
        
        text(...
            'Position',[0.02 0.75 0 ],...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Bin Length in days :');
        
        %  beginning year
        start_field=uicontrol('Style','edit','Position',[.65 .60 .27 .05],...
            'Units','normalized','String',num2str(minti),...
            'Value', minti,...
            'Callback',@update_dates,...
            'Tag','mapview_start_field',...
            'tooltipstring', 'as decimal year or yyyy-mm-dd hh:mm:ss');
        
        text(...
            'Position',[0.02 0.63 0 ],...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Beginning date: ');
        
        % ending year
        end_field=uicontrol('Style','edit','Position',[.65 .50 .27 .05],...
            'Units','normalized','String',num2str(maxti),...
            'Value', maxti,...
            'Callback',@update_dates,...
            'Tag','mapview_end_field',...
            'tooltipstring', 'as decimal year or yyyy-mm-dd hh:mm:ss');
        
        text(...
            'Position',[0.02 0.51 0 ],...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Ending date: ');
        
        %  min mag
        minmag_field=uicontrol('Style','edit','Position',[.70 .40 .22 .05],...
            'Units','normalized','String',num2str(minma),...
            'Value', minma,...
            'Tag','mapview_minmag_field',...
            'Callback',@update_numeric);
        
        text(...
            'Position',[0.02 0.38 0 ],...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Minimum Magnitude: ');
        
        % max mag
        maxmag_field=uicontrol('Style','edit','Position',[.70 .30 .22 .05],...
            'Units','normalized','String',num2str(maxma),...
            'Value', maxma,...
            'Tag','mapview_maxmag_field',...
            'Callback',@update_numeric);
        
        text(...
            'Position',[0.02 0.25 0 ],...
            'Rotation',0 ,...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Maximum Magnitude: ');
        
        % min depth
        mindepth_field=uicontrol('Style','edit','Position',[.30 .15 .15 .05],...
            'Units','normalized','String',num2str(mindep),...
            'Value', mindep,...
            'Tag','mapview_mindepth_field',...
            'Callback',@update_numeric);
        
        % max depth
        maxdepth_field=uicontrol('Style','edit','Position',[.50 .15 .15 .05],...
            'Units','normalized','String',num2str(maxdep),...
            'Value', maxdep,...
            'Tag','mapview_maxdepth_field',...
            'Callback',@update_numeric);
        
        text(...
            'Position',[0.02 0.15 0 ],...
            'Rotation',0 ,...
            'FontSize',fontsz.m ,...
            'FontWeight','bold' ,...
            'String','       Min Depth     Max Depth  ');
        
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.65 .02 .20 .10 ],...
            'Units','normalized','Callback',@cancel,'String','cancel');
        
        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.35 .02 .20 .10 ],...
            'Units','normalized',...
            'Callback',@go,...
            'String','Go');
        
        info_button=uicontrol('Style','Pushbutton',...
            'Position',[.05 .02 .20 .10 ],...
            'Units','normalized',...
            'Callback','zmaphelp(titstr,hlpStr)',...
            'String','Info');
        
        titstr = 'General Parameters';
        hlpStr = ...
            ['This window allows you to select earthquakes '
            'from a catalog. You can select a subset in   '
            'time, magnitude and depth.                   '
            '                                             '
            'The top frame displays the number of         '
            'earthquakes in the catalog - no selection is '
            'possible.                                    '
            '                                             '
            'Two more parameters can be adjusted: The Bin '
            'length in days that is used to sample the    '
            'seismicity and the minimum magnitude of      '
            'quakes displayed with a larger symbol in the '
            'map.                                         '];
        
        
        if term ==1
            whitebg(gcf,[1 1 1 ]);
        end
        set(gcf,'visible','on')
    end
    
    function tf = catalog_overview_exists()
        % determine whether catalog_overview window exists and is valid
    end
    
    function update_numeric(src, ~)
        src.Value = str2double(src.String);
        set(mindepth_field,'String',num2str(mindep));
    end
    
    function update_dates(src, ~)
        % interpret as decimal year or full date
        
    end
    
    function go(src, ~)
        %TODO remove all the side-effects.  store relevent data somewhere specific
        %filter the catalog, then return
        global a
        myparent=get(src,'Parent');
        
        h = findall(myparent,'Tag','mapview_maxdepth_field');
        maxdep = h.Value;
        h = findall(myparent,'Tag','mapview_minmag_field');
        minma = h.Value;
        h = findall(myparent,'Tag','mapview_maxmag_field');
        maxma = h.Value;
        h = findall(myparent,'Tag','mapview_mindepth_field');
        mindep = h.Value;
        h = findall(myparent,'Tag','mapview_start_field');
        minti = h.Value;
        h = findall(myparent,'Tag','mapview_end_field');
        maxti = h.Value;
        mycat = a; %TODO see if this is really supposed to be so
        close;
        think;

        % following code originally from sele_sub.m
        %    Create  reduced (in time and magnitude) catalogues "a" and "newcat"
        %
        mask = mycat(:,mag_idx) >= minma  & mycat(:,mag_idx) <= maxma  &...
            mycat(:,decyr_idx) >= minti & mycat(:,decyr_idx) <= maxti &...
            mycat(:,dep_idx) >= mindep & mycat(:,dep_idx) <= maxdep;
        
        mycat = mycat(mask,:);
        % not changed unless a new set of general parameters is entered
        newcat = [];     % newcat is created to store the last subset data
        newt2 = [];      %  newt2 is a subset to be changed during analysis
        
        % recompute depth and Magnitude display variables
        %minmag = max(mycat(:,6)) -0.2;      % to startzma
        dep1 = 0.3* (max(mycat(:,dep_idx))-min(mycat(:,dep_idx))) + min(mycat(:,dep_idx));
        dep2 = 0.6* (max(mycat(:,dep_idx))-min(mycat(:,dep_idx))) + min(mycat(:,dep_idx));
        dep3 = max(mycat(:,dep_idx));
        
        stri1 = file1;
        tim1 = minti;
        tim2 = maxti;
        minma2 = minma;
        maxma2 = maxma;
        minde = min(mycat(:,dep_idx));
        maxde = max(mycat(:,dep_idx));
        rad = 50.;
        ic = 0;
        ya0 = 0.;
        xa0 = 0.;
        iwl3 = 1.;
        step = 3;
        
        t1p = t0b;
        t4p = teb;
        t2p = t4p - (t4p-t1p)/2;
        t3p = t2p;
        tresh = nan;
        %create catalog of "big events" if not merged with the original one:
        %
        mask = mycat(:,mag_idx) > big_evt_minmag ;
        maepi = mycat(mask,:);
        
        %sort in time
        mycat = sortrows(mycat, decyr_idx);
        
        if length(mycat(:,3)) > 10000
            ty1='.';
            ty2='.';
            ty3='.';
        end
        a = mycat;
        %assignin('base','a',mycat);
        h=zmap_message_center();
        h.update_catalog()%;
        %TODO make subcata a function
       % evalin('base',subcata);
         mainmap_overview('dep');
        % changes in bin length go to global par1
    end
    
    function cancel(src, ~)
        % return without making changes to catalog
        h=zmap_message_center();
        h.update_catalog();
        close;
    end
    
end
