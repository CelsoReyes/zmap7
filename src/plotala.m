function plotala()
    % ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
    % does the calculation and makes displays the map
    % stefan wiemer 11/94
    %
    % make dialog interface and call maxzlta
    %
    % This is the info window text
    %
    
    report_this_filefun();
    
    global main mainfault faults coastline
    global iala
    watchon
    
    ttlStr='The Alarm Cube Window                                ';
    hlpStr1= ...
        ['  To be implemented                             '
        ' corners with the mouse                         '];
    % Find out if figure already exists
    watchon
    if isempty(iala) ; 
        iala = ZG.compare_window_dur; 
    end
    if ~exist('abo2') || isempty(abo2); 
        errordlg('No alarms with z >= Zmin detected!');
        return; 
    end
    
    abo = abo2;
    
    
    cube=findobj('Type','Figure','-and','Name','Alarm Display');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(cube)
        cube = figure_w_normalized_uicontrolunits( ...
            'Name','Alarm Display',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Position',[  200 200 400 600]);
        
        
        ter2 = 7.5;
        ZG.tresh_km = max(loc(:,3));
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .65 .12 .06],'String','Refresh ',...
            'callback',@callbackfun_001)
        
        
        
        tre2 = max(abo(:,4)) - 0.5;
        new = uicontrol('style','edit','value',years(ZG.compare_window_dur),...
            'string',num2str(tre2,3), 'background','y',...
            'callback',@callbackfun_002,...
            'units','norm','pos',[.80 .01 .08 .06],'min',2.65,'max',10);
        
        newlabel = uicontrol('style','text','units','norm','pos',[.40 .00 .40 .08]);
        set(newlabel,'string','Alarm Threshold:','background',color_fbg);
        
        mamo1 = uicontrol('Units','normal',...
            'Position',[.90 .01 .08 .06],'String','Go',...
            'callback',@callbackfun_003);
        
        mamo = uicontrol('Units','normal',...
            'Position',[.02 .01 .27 .10],'String','Make Movie',...
            'callback',@callbackfun_004)
        
        nilabel2 = uicontrol('style','text','units','norm','pos',[.50 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',ZG.tresh_km,'string',num2str(ZG.tresh_km,3),...
            'background','y');
        set(set_ni2,'callback',@callbackfun_005);
        set(set_ni2,'units','norm','pos',[.80 .92 .13 .06],'min',0.01,'max',10000);
        
        
        uicontrol('Units','normal',...
            'Position',[.93 .93 .07 .05],'String','Go ',...
            'callback',@callbackfun_006)
        create_my_menu();
        
        
    end   % if exist newCube
    
    report_this_filefun();
    
    figure(cube);
    delete(gca)
    abo = abo2;
    if isempty(abo);ZmapMessageCenter.set_info(' ','No data above threshold'); return; end
    rect= [0.2 0.2 0.6 0.6];
    axes('pos',rect)
    set(gca,'visible','off')
    abo = abo2;
    abo(:,5) = abo(:,5)* days(ZG.bin_dur) + ZG.primeCatalog.Date(1);
    l = abo(:,4) > tre2;
    abo = abo(l,:);
    if length(abo)  < 1  ; errordlg('No alarms with z >= Zmin detected!');return; end
    l = abo(:,3) < ZG.tresh_km;
    abo = abo(l,:);
    if length(abo)  < 1  ; errordlg('No alarms with z >= Zmin detected!');return; end
    set(gca,'NextPlot','add')
    
    if ~isempty(abo)
        figure(map);
        zmap_update_displays();
        plot(abo(:,1),abo(:,2),'o',...
            'MarkerFaceColor','r','MarkerEdgeColor','y');
        
        figure(cube);
        plo  = plot3(abo(:,1),abo(:,2),abo(:,5),'ro');
        set(plo,'MarkerSize',6,'LineWidth',1.0)
        for i = 1:length(abo(:,1))
            li = [abo(i,1) abo(i,2) abo(i,5) ; abo(i,1) abo(i,2) abo(i,5)+iala];
            plot3(li(:,1),li(:,2),li(:,3),'b');
        end
    end
    view(3);
    
    grid
    set(gca,'NextPlot','add')
    
    if ~isempty(coastline)
        l = coastline(:,1) < s1  & coastline(:,1) > s2 & coastline(:,2) < s3 & coastline(:,2) > s4| coastline(:,1) == inf | coastline(: ,1) == -inf;
        pl1 =plot3(coastline(l,1),coastline(l,2),ones(length(coastline(l,:)),1)*t0b,'k');
        pl1 =plot3(coastline(l,1),coastline(l,2),ones(length(coastline(l,:)),1)*teb,'k');
    end
    if ~isempty(faults)
        l = faults(:,1) < s1  & faults(:,1) > s2 & faults(:,2) < s3 & faults(:,2) > s4| faults(:,1) == inf;
        pl1 =plot3(faults(l,1),faults(l,2),ones(length(faults(l,:)),1)*t0b,'k');
        pl4 =plot3(faults(l,1),faults(l,2),ones(length(faults(l,:)),1)*teb,'k');
    end
    if ~isempty(mainfault)
        pl2 = plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault),1)*t0b,'m');
        pl2b =plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault),1)*teb,'m');
        set(pl2,'LineWidth',3.0)
        set(pl2b,'LineWidth',3.0)
    end
    if ~isempty(main)
        pl3 =plot3(main(:,1),main(:,2),ones(length(main)-1,1)*teb,'xk');
        pl3b =plot3(main(:,1),main(:,2),ones(length(main)-1,1)*t0b,'xk');
        set(pl3,'LineWidth',3.0)
        set(pl3b,'LineWidth',3.0)
    end
    % end
    
    if ~isempty(ZG.maepi)
        pl8 =plot3(ZG.maepi.Longitude,ZG.maepi.Latitude,ZG.maepi.Date,'*k');
        set(pl8,'LineWidth',2.0,'MarkerSize',10)
    end
    
    axis([ s2-0.1 s1+0.1 s4-0.1 s3+0.1 t0b teb+1  ])
    strib4 = [  ' Alarm Cube of '  name '; wl =  '  char(ZG.compare_window_dur) '; Zcut = ' num2str(tre2,3)  ];
    title(strib4,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',2.0,'visible','on')
    %set(gca,'Color',[0.7 0.7 0.7])
    
    viewer
    watchoff
    vie = gcf;
    figure(cube);
    watchoff
    
    figure(cube);
    
    rotate3d
    
    function agroup()
        % This script finds overlapping alarms in space-time
        % and groups them together
        %
        % Stefan Wiemer    4/95
        
        global abo
        
        report_this_filefun();
        
        % Reset the alarms to the all alarms above the current threshold
        l = abo2(:,4) >= tre2;
        abo = abo2(l,:);
        abo(:,5) = abo(:,5)* days(ZG.bin_dur) + ZG.primeCatalog.Date(1);
        
        
        j = 0;
        tmp = abo;
        figure(map);
        
        while length(abo) > 1
            j = j+1;
            [k,m] = findnei(1);
            po = k;
            for i = 1:length(k)
                [k2,m2]  = findnei(k(i));
                po = [po ; k2];
            end
            po = sort(po);
            po2 = [0;  po(1:length(po)-1)] ;
            l = find(po-po2 > 0) ;
            po3 = po(l) ;
            do = ['an' num2str(j) ' = abo(po3,:);'];
            disp([num2str(j) '  Anomalie groups  found'])
            eval(do)
            pl = plot(abo(po3,1),abo(po3,2),'co');
            set(pl,'MarkerSize',5,'Linewidth',4.0,...
                'Color',[rand rand rand])
            abo(po3,:) =[];
        end   % while j
        
    end
    
    function agz()
        % This script evaluates the percentage of space time coevered by
        %alarms
        % FIXME apparently this could take a long time and run out of memory
        re = [];
        
        % Stefan Wiemer    4/95
        
        report_this_filefun();
        
        global abo
        abo = abo2;
        
        titStr ='Warning!                                        ';
        
        messtext= ...
            ['                                                '
            ' This rountine sometimes takes a long time!     '
            '  and may run out of memory. You can interupt   '
            ' the calculation with a ^C. The results         '
            ' calculated so far are stored in the variable re'];
        
        ZmapMessageCenter.set_message(titStr,messtext);
        figure(mess);
        
        def = {'5','0.1'};
        tit ='Alarm Group Calculation';
        prompt={'Minimum Zalarm to be used ?', 'Step width used ?'};
        
        ni2 = inputdlg(prompt,tit,1,def);
        l = ni2{1};
        zm = str2double(l);
        l = ni2{2};
        is = str2double(l);
        
        
        for tre2 = max(abo(:,4))-0.1 : -is : zm
            tre2;
            abo = abo2;
            abo(:,5) = abo(:,5)* days(ZG.bin_dur) + ZG.primeCatalog.Date(1);
            l = abo(:,4) >= tre2;
            abo = abo(l,:);
            l = abo(:,3) < ZG.tresh_km;
            abo = abo(l,:);
            disp([' Current Alarm threshold:  ' num2str(tre2) ])
            disp(['Number of alarms:  ' num2str(length(abo(:,1))) ])
            set(gca,'NextPlot','add')
            
            j = 0;
            tmp = abo;
            
            while length(abo) > 1
                j = j+1;
                [k,m] = findnei(1);
                po = k;
                for i = 1:length(k)
                    [k2,m2]  = findnei(k(i));
                    po = [po ; k2];
                end
                po = sort(po);
                po2 = [0;  po(1:length(po)-1)] ;
                l = find(po-po2 > 0) ;
                po3 = po(l) ;
                do = ['an' num2str(j) ' = abo(po3,:);'];
                disp([num2str(j) '  Anomalie groups  found'])
                eval(do)
                abo(po3,:) =[];
            end   % while j
            
            
            re = [re ; tre2 j ];
        end   % for tre2
        
        
        figure
        
        
        axis off
        
        uicontrol('Units','normal',...
            'Position',[.0 .65 .08 .06],'String','Save ',...
            'Callback',{@calSave9, re(:,1), re(:,2)})
        
        rect = [0.20,  0.10, 0.70, 0.60];
        axes('position',rect)
        set(gca,'NextPlot','add')
        pl = plot(re(:,1),re(:,2),'r');
        set(pl,'LineWidth',1.5)
        pl = plot(re(:,1),re(:,2),'ob');
        set(pl,'LineWidth',1.5,'MarkerSize',10)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on')
        grid
        
        ylabel('Number of Alarm Groups')
        xlabel('Zalarm ')
        watchoff
    end
    
    function cian()
        % find anomalie groups
        report_this_filefun();
        
        for i = 1:j
            do = ['tmp = an' num2str(i) ';' ];
            eval(do)
            m = [];
            for t = 1:length(tmp(:,1) )
                xa0 = tmp(t,1);ya0 = tmp(t,2);
                l = ZG.primeCatalog.epicentralDistanceTo(ya0,xa0);
                [s,is] = sort(l);
                m = [m ; is(1:ni,1)];
            end  % for t
            m = sort(m);
            m2 = [0 ; m(1:length(m)-1)];
            l = find(m-m2 > 0);
            do = ['anB' num2str(i) ' = ZG.primeCatalog.subset(m(l));' ]; %FIXME don't do this this way.
            eval(do)
        end
    end
    
    function cian2()
        % will display cumulative # curve for one anomaly group
        report_this_filefun();
        
        def = {'1'};
        ni2 = inputdlg('Please Input  Anomalie Number ?','Input',1,def);
        l = ni2{1};
        n = str2double(l);
        
        do = ['ZG.newt2 = anB' num2str(n) ';' ];
        eval(do)
        do = ['ZG.newcat = anB' num2str(n) ';' ];
        eval(do)
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
        zmap_update_displays();
        axes(h1)
        plot(ZG.newt2.Longitude, ZG.newt2.Latitude,'*k')
    end
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        op3 = uimenu('Label','Tools');
        uimenu(op3,'Label','Find Anomalie Groups  ',...
            MenuSelectedField(),@callbackfun_007);
        uimenu(op3,'Label','Display one Anomalie Group ',...
            MenuSelectedField(),@callbackfun_008);
        uimenu(op3,'Label','Determine Valarm/Vtotal(Zalarm) ',...
            MenuSelectedField(),@callbackfun_009);
        uimenu(op3,'Label','Determine # Alarmgroups (Zalarm) ',...
            MenuSelectedField(),@callbackfun_010);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        plotala();
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tre2=str2num(new.String);
        'String';
        num2str(tre2,3);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        abo = abo2;
        plotala();
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(mamo);
        delete(mamo1);
        delete(newlabel);
        mamovie ;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.tresh_km=str2double(set_ni2.String);
        set_ni2.String=num2str(ZG.tresh_km,3);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        
        pause(1);
        plotala();
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        agroup;
        cian;
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cian2;
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        sucra;
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        agz;
    end
end
