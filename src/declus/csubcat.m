function csubcat()
    % csubcat plots the eqs of the original catalogrelated with the loaded cluster.
    % Most routines work similar like in the name map window
    %
    
    error('This is broken. Needs to be majorly updated');
    global newccat decc  dep1 dep2 dep3 ty1 ty2 ty3
    global  name minde maxde maxma2 minma2
    
    
    report_this_filefun(mfilename('fullpath'));
    
    myFigName='Seismicity Map (Cluster)';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    
    zmap_message_center.set_info('Message','Plotting Seismicity Map(Cluster) ....');
    ZG=ZmapGlobal.Data;
    storedcat=original;
    %set catalog to the original catalog used at declustering
    if isempty(newccat)
        replaceMainCatalog(original);
        newccat=original;
    else
        replaceMainCatalog(newccat);
    end
    
    % For time and magnitude cut window
    minma2=min(ZG.a.Magnitude);
    maxma2=max(ZG.a.Magnitude);
    minde=min(ZG.a.Depth);
    maxde=max(ZG.a.Depth);
    
    % Find out if figure already exists
    %
    mapp=myFigFinder();
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(mapp)
        mapp = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Tag','mapp',...
            'Position',[ (fipo(3:4) - [600 500]) ZmapGlobal.Data.map_len]);
        
        stri1 = [file1];
    end
    
    %end;    if figure exist
    
    % show the figure
    %
    figure(mapp);
    reset(gca)
    cla
    dele = 'delete(si),delete(le)';er = 'disp('' '')'; eval(dele,er);
    watchon;
    set(gca,'visible','off','SortMethod','childorder')
    hold off
    
    % find min and Maximum axes points
    s1 = max(ZG.a.Longitude);
    s2 = min(ZG.a.Longitude);
    s3 = max(ZG.a.Latitude);
    s4 = min(ZG.a.Latitude);
    orient landscape
    set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    %
    % find start and end time of catalogue "a"
    %
    
    
    t0b = min(ZG.a.Date);
    n = ZG.a.Count;
    teb = max(ZG.a.Date) ;
    tdiff =round(teb - t0b)/days(ZG.bin_dur);
    
    
    n = ZG.a.Count;
    
    % plot earthquakes (differnt colors for varous depth layers) as
    % defined in "startzmap"
    %
    hold on
    
    %plot earthquakes according to depth
    switch (xxxxxxxx) %TOFIX no idea what this is supposed to be swithicng on. does it work at all? has it worked (ever)?
        case 'depth'
            deplo1 =plot(a(ZG.a.Depth<=dep1,1),a(ZG.a.Depth<=dep1,2),'.b');
            set(deplo1,'MarkerSize',ZG.ms6,'Marker',ty1)
            deplo2 =plot(a(ZG.a.Depth<=dep2&ZG.a.Depth>dep1,1),a(ZG.a.Depth<=dep2&ZG.a.Depth>dep1,2),'.g');
            set(deplo2,'MarkerSize',ZG.ms6,'Marker',ty2);
            deplo3 =plot(a(ZG.a.Depth<=dep3&ZG.a.Depth>dep2,1),a(ZG.a.Depth<=dep3&ZG.a.Depth>dep2,2),'.r');
            set(deplo3,'MarkerSize',ZG.ms6,'Marker',ty3)
            ls1 = sprintf('Depth < %3.1f km',dep1);
            ls2 = sprintf('Depth < %3.1f km',dep2);
            ls3 = sprintf('Depth < %3.1f km',dep3);
            
            %plot earthquakes according time
        case  'tim'
            deplo1 =plot(a(ZG.a.Date<=tim2&ZG.a.Date>=tim1,1),a(ZG.a.Date<=tim2&ZG.a.Date>=tim1,2),'.b');
            set(deplo1,'MarkerSize',ZG.ms6,'Marker',ty1)
            deplo2 =plot(a(ZG.a.Date<=tim3&ZG.a.Date>tim2,1),a(ZG.a.Date<=tim3&ZG.a.Date>tim2,2),'.g');
            set(deplo2,'MarkerSize',ZG.ms6,'Marker',ty2);
            deplo3 =plot(a(ZG.a.Date<=tim4&ZG.a.Date>tim3,1),a(ZG.a.Date<=tim4&ZG.a.Date>tim3,2),'.r');
            set(deplo3,'MarkerSize',ZG.ms6,'Marker',ty3)
            
            ls1 = sprintf('%3.1f < t < %3.1f ',tim1,tim2);
            ls2 = sprintf('%3.1f < t < %3.1f ',tim2,tim3);
            ls3 = sprintf('%3.1f < t < %3.1f ',tim3,tim4);
            
            
    end
    le =legend('+b',ls1,'og',ls2,'xr',ls3);
    set(le,'position',[ 0.65 0.02 0.32 0.12])
    axis([ s2 s1 s4 s3])
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    strib = [  ' Map of   '  name '; '  num2str(t0b) ' to ' num2str(teb) ];
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    
    %make depth legend
    %
    
    h1 = gca;
    set(gca,'Color',color_bg);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    set(le,'Color','w');
    %axis('image')
    %  h1 is the graphic handle to the main figure in window 1
    %
    
    %
    %  Plots epicenters  and faults
    update(mainmap())
    
    % Make the figure visible
    %
    figure(mapp);
    axes(h1);
    watchoff(mapp)
    set(mapp,'Visible','on');
    done
    
    %% ui functions
    function create_my_menu()
        add_menu_divider()
        
        % Make the menu to change symbol size and type
        %
        add_symbol_menu([]); %TO FIX Figure out which target to affect
        TypeMenu = uimenu(symbolmenu,'Label',' Legend by Time ',...
            'callback',@callbackfun_001);
        TypeMenu = uimenu(symbolmenu,'Label',' Legend by Depth ',...
            'callback',@callbackfun_002);
        
        cal6 = ...
            [ 'set(deplo1,''MarkerSize'',ZG.ms6,''LineStyle'',ty1,''visible'',''on'');',...
            'set(deplo2,''MarkerSize'',ZG.ms6,''LineStyle'',ty2,''visible'',''on'');',...
            'set(deplo3,''MarkerSize'',ZG.ms6,''LineStyle'',ty3,''visible'',''on'');' ];
        
        cufi = gcf;
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Cluster Window Values',...
            'callback',@callbackfun_003);
        uimenu(options,'Label','Expanded Cluster Values ',...
            'callback',@callbackfun_004);
        uimenu(options,'Label','Select new parameters',...
            'callback',@callbackfun_005);
        uimenu(options,'Label','Select EQ in Polygon (Menu) ',...
            'callback',@callbackfun_006);
        
        uimenu(options,'Label','Select EQ in Polygon ',...
            'callback',@callbackfun_007);
        
        %    uimenu(options,'Label','Select EQ in Circle (Menu) ',...
        %          'callback',@callbackfun_008);
        
        op2 = uimenu('Label','Catalog');
        uimenu(op2,'Label','Refresh Window ',...
            'callback',@callbackfun_009);
        
        uimenu(op2,'Label','Reset Catalog ',...
            'callback',@callbackfun_010);
        uimenu(op2,'label','Declustered catalog',...
            'callback',@callbackfun_011);
        catSave =...
            [ 'zmap_message_center.set_info(''Save Data'',''  '');think;',...
            '[file1,path1] = uigetfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Earthquake Datafile'');',...
            'if length(file1) > 1 , sapa2 = [''save '' path1 file1 '' a faults main mainfault coastline infstri ''],',...
            'eval(sapa2) ,end, done'];
        
        
        
        
        op3 = uimenu('Label','Tools');
        uimenu(op3,'Label','Plot Cumulative Number ',...
            'callback',@callbackfun_012);
        
        uimenu(op3,'Label','Create Cross-section ',...
            'callback',@callbackfun_013);
        uimenu(op3,'Label','3 D view ',...
            'callback',@callbackfun_014);
        uimenu(op3,'Label','Time Depth Plot ',...
            'Callback',@(~,~)TimeDepthPlotter.plot(ZG.newt2));
        uimenu(op3,'Label','Time magnitude Plot ',...
            'Callback',@(~,~)TimeMagnitudePlotter.plot(ZG.newt2));
        uimenu(op3,'Label','Decluster the catalog',...
            'callback',@callbackfun_015);
        uimenu(op3,'Label','get coordinates with Cursor',...
            'callback',@callbackfun_016);
        
        %calculate several histogramms
        stt1='Magnitude ';stt2='Depth';stt3='Duration';st4='Foreshock Duration';
        st5='Foreshock Percent';
        
        op5 = uimenu(op3,'Label','Histograms');
        
        uimenu(op5,'Label','Magnitude',...
            'Callback',{@callbackfun_histogram,'Magnitude'});
        uimenu(op5,'Label','Depth',...
            'Callback',{@callbackfun_histogram,'Depth'});
        uimenu(op5,'Label','Time',...
            'Callback',{@callbackfun_histogram,'Date'});
    end
    
    %% callback functions
    function callbackfun_histogram(mysrc,myevt,hist_type)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        hisgra(ZG.a, hist_type);
    end
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.mainmap_plotby='tim';
        setleg;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.mainmap_plotby='depth';
        csubcat;
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newccat=selclus('cur_cluster',ZG.newccat);
        csubcat;
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newccat=selclus('expanded_cluster',ZG.newccat);
        csubcat;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newccat=cpara('interactive',ZG.newccat);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG.newt2 = a;
        stri = 'Polygon';
        decc=0;
        clkeysel;
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        stri = 'Polygon';
        cufi = gcf;
        decc=0;
        clpickp('MOUSE');
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        set(gcf,'Pointer','watch');
        stri = [' '];
        stri1 = [' '];
        decc=0;
        incircle;
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(findobj(mapp,'Type','axes'));
        csubcat;
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        think;
        clear plos1 mark1 ;
        replaceMainCatalog(original);
        newccat = original;
        ZG.newt2= original;
        csubcat;
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        newccat=buildcat(2);
        csubcat;
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        stri = 'Polygon';
        ZG.newt2 = a;
        ZG.newcat = a;
        ctimeplot;
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lammap;
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot3d;
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inpudenew;
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ginput(1);
    end
end
