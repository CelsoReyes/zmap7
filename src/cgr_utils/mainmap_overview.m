function mainmap_overview(typele)
    % This is  the .m file substitute for "subcata.m". It plots the earthquake data
    % on a map and supplies the user with an
    %  interface to do further analyses.
    %
    %  Depending on the selection it resets newt2, newcat and a
    
    global a file1 t0b teb par1 ms6 ty1 ty2 ty3 fontsz name% newt2 newcat
    ty1=evalin('base','ty1');
    ty2=evalin('base','ty2');
    ty3=evalin('base','ty3');
    ms6=evalin('base','ms6');
    
    if isempty(a)
        think
        welcome('Message','No data in catalog, cannot plot Seismicity Map ....');
        pause(2)
        done;
        welcome('Messages', 'Choose a catalog' );
        return
    end
        
    think
    report_this_filefun(mfilename('fullpath'));
    welcome('Message','Plotting Seismicity Map ....');
    
    % This is the info window text
    %
    ttlStr='The Map Window                                ';
    hlpStr1map= ...
        ['                                                '
        ' This window displays the seismicity in the sel-'
        ' ected catalog. Some of the menu-bar submenu are'
        ' described below:                               '
        '                                                '
        ' zoom: Selecting Axis -> zoom on allows you to  '
        '       zoom into a region. Click and drag with  '
        '       the left mouse button. type <help zoom>  '
        '       for details.                             '
        'Rubberband zoom:                                '
        ' You can  zoom the current 2D figure            '
        ' by clicking with the LEFT mouse button, then   '
        ' dragging the box until you get the desired area'
        ' If you don t like that zoom, or want to retrace'
        ' your steps, click with the RIGHT mouse         '
        ' button and your previous axis will be restoed  '
        ' Exit zoom:  press <RETURN> in the figure.      '
        '                                                '
        ' Aspect: select one of the aspect ratio submenu '
        ' Text: You can select text items by clicking.The'
        '       selected text can be rotated, moved, you '
        '       can change the font size etc.            '
        '       Double click on text allows editing it.  '
        '                                                '
        ' You can select earthquakes in a polygon either '
        ' by entering the coordinates or defining the    '
        ' corners with the mouse                         '];
    hlpStr2map= ...
        ['                                                '
        ' Select earthquakes in a circular volume:       '
        '      Ni, the number of selected earthquakes can'
        '      be edited in the upper right corner of the'
        '      window.                                   '
        ' Refresh Window: Redraws the figure, erases     '
        '       selected events.                         '
        ' Catalog: This submenu enables you to           '
        '       reset the selected catalog to the ori-   '
        '       ginal selection (AFTER General selection)'
        ' Select new Parameters: Opens the General       '
        '       Parameter window for a new selection.    '];
    
    
    hlpStr3map= ...
        ['                                                '
        ' Several tools are activated from here:         '
        ' - Plot the cumulative number                   '
        ' - Start a GenAS analyses                       '
        ' - Make a grid for a                            '
        ' - Mean depth analyses                          '
        ' - Decluster a catalog                          '
        '                                                '
        ' Please refer to the users guide for details    '
        ' about these functions                          '
        '                                                '];
    
    
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
    
    % Find out of figure already exists
    
    [existFlag,figNumber]=figure_exists('Seismicity Map',1);
    newMapWindowFlag=~existFlag;
    
    % Set up the Seismicity Map window Enviroment
    %
    if newMapWindowFlag
        fipo = get(groot, 'ScreenSize');
        winx = 750;
        winy = 650;
        map=figure_w_normalized_uicontrolunits( ...
            'Name','Seismicity Map',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','on', ...
            'Tag','seismicity_map',...
            'Position',[10 10 750 650]); %[ fipo(3)-1000 fipo(4)-700 winx winy]);
        
        stri1 = file1;
        
        %  call supplementary program to make menus at the top of the plot
        % matdraw
        
        create_main_plot();
        create_overlay_menu();
        create_select_menu();
        create_catalog_menu();
        create_ztools_menu();
        %{
        catSave =...
            [ 'welcome(''Save Data'',''  '');think;',...
            '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Earthquake Datafile'');',...
            'if length(file1) > 1 , wholePath=[path1 file1],sapa2 = [''save('' ''wholePath'' '', ''''a'''', ''''faults'''', ''''main'''', ''''mainfault'''', ''''coastline'''', ''''infstri'''', ''''well'''')''],',...
            'eval(sapa2) ,end, done'];
        %}
        %sapa2 = [''save '' path1 file1 '' a faults main mainfault coastline infstri well'']
        seisstr=['global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5 freq_field6 map h1 a ldx Mmin tlap stime dx dy,seisgrid(1);'];
        
        
        
        
        %calculate several histogramms
        stt1='Magnitude ';
        stt2='Depth ';
        stt3='Duration ';
        st4='Foreshock Duration ';
        st5='Foreshock Percent ';
        
    end
    %end;    if figure exist
    
    % show the figure
    %
    figure_w_normalized_uicontrolunits(map)
    %reset(gca)
    %cla
    delete(gca),delete(gca),delete(gca);delete(gca);
    delete(gca),delete(gca),delete(gca);delete(gca);
    dele = 'delete(si),delete(le)';er = 'disp('' '')'; eval(dele,er);
    watchon;
    set(gca,'visible','off','SortMethod','childorder')
    hold off
    
    % find min and Maximum axes points
    s1 = max(a(:,lon_idx));
    s2 = min(a(:,lon_idx));
    s3 = max(a(:,lat_idx));
    s4 = min(a(:,lat_idx));
    
    if s1 == s2
        s2 = s2 +- 0.1 ;
        s1 = s1 - 0.1;
    end
    if s3 == s4
        s3 = s3 + 0.1;
        s4 = s4 - 0.1; 
    end
    orient landscape
    set(gcf,'PaperPosition',[ 1.0 1.0 8 6])
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    %
    % find start and end time of catalogue "a"
    %
    t0b = a(1,3);
    n = length(a(:,lon_idx));
    teb = a(n,3) ;
    % tdiff =round(teb - t0b)*365/par1;
    
    n = length(a);
    
    % plot earthquakes (different symbols for various parameters) as
    % defined in "startzmap"
    %
    hold on
    
    %plot earthquakes according to magnitude
    switch typele
        case 'mag'
            a_mags = a(:,mag_idx);
            % divide magnitudes into 3 categories
            dep1 = 0.3*max(a_mags);
            dep2 = 0.6*max(a_mags);
            dep3 = max(a_mags);
            
            depth_mask = a_mags>=dep1 & a_mags<dep2;
            deplo1=plot(a(depth_mask,1), a(depth_mask,2),'ob');
            set(deplo1,'MarkerSize',ms6);
            
            depth_mask = a_mags>=dep2 & a_mags< dep3;
            deplo2=plot(a(depth_mask,1), a(depth_mask,2),'ob');
            set(deplo2,'MarkerSize',ms6*2);
            
            depth_mask = a_mags>=dep3;
            deplo3 =plot(a(depth_mask,1), a(depth_mask,2),'ob');
            set(deplo3,'MarkerSize',ms6*3)
            
            ls1 = sprintf('M > %3.1f ',dep1);
            ls2 = sprintf('M > %3.1f ',dep2);
            ls3 = sprintf('M > %3.1f ',dep3);
        case 'mad'
            symbol_magsize
        case 'fau'
            symbol_faulttype
            
            
            %plot earthquakes according to depth
        case 'dep'
            a_depths = a(:,dep_idx);
            
            % divide depths into 3 categories
            dep1 = 0.3*max(a_depths);
            dep2 = 0.6*max(a_depths);
            dep3 = max(a_depths);
            
            deplo1 =plot(a(a_depths<=dep1,1),a(a_depths<=dep1,2),'.b');
            set(deplo1,'MarkerSize',ms6,'Marker',ty1);
            
            deplo2 =plot(a(a_depths<=dep2&a_depths>dep1,1),a(a_depths<=dep2&a_depths>dep1,2),'.g');
            set(deplo2,'MarkerSize',ms6,'Marker',ty2);
            
            deplo3 =plot(a(a_depths<=dep3&a_depths>dep2,1),a(a_depths<=dep3&a_depths>dep2,2),'.r');
            set(deplo3,'MarkerSize',ms6,'Marker',ty3)
            
            ls1 = sprintf('z<%3.1f km',dep1);
            ls2 = sprintf('z<%3.1f km',dep2);
            ls3 = sprintf('z<%3.1f km',dep3);
            
            %plot earthquakes according time
        case 'tim'
            a_times = a(:,decyr_idx);
            timedivisions = linspace(min(a_times),max(a_times),4);
            
            time_mask = timedivisions(2) <= a_times & a_times >= timedivisions(1);
            deplo1 =plot(a(time_mask,1), a(time_mask,2),'.b');
            set(deplo1,'MarkerSize',ms6,'Marker',ty1)
            
            time_mask = timedivisions(2) < a_times & a_times <= timedivisions(3);
            deplo2 =plot(a(time_mask,1), a(time_mask,2),'.g');
            set(deplo2,'MarkerSize',ms6,'Marker',ty2);
            
            time_mask = timedivisions(3)< a_times & a_times <= timedivisions(4);
            deplo3 =plot(a(time_mask,1),a(time_mask),'.r');
            set(deplo3,'MarkerSize',ms6,'Marker',ty3)
            
            ls1 = sprintf('%3.1f ≤ t ≤ %3.1f ',timedivisions(1),timedivisions(2));
            ls2 = sprintf('%3.1f < t ≤ %3.1f ',timedivisions(2),timedivisions(3));
            ls3 = sprintf('%3.1f < t ≤ %3.1f ',timedivisions(3),timedivisions(4));
            
        otherwise
            le = legend([deplo1 deplo2 deplo3],ls1,ls2,ls3);
            set(le,'position',[ 0.65 0.02 0.32 0.12],'FontSize',12,'color','w')
    end
    
    
    
    set(gca,'FontSize',fontsz.s,'FontWeight','normal',...
        'Ticklength',[0.01 0.01],'LineWidth',1.0,...
        'Box','on','TickDir','out')
    
    xlabel('Longitude [deg]','FontSize',fontsz.m)
    ylabel('Latitude [deg]','FontSize',fontsz.m)
    strib = [  ' Map of '  name '; '  num2str(t0b,5) ' to ' num2str(teb,5) ];
    title2(strib,'FontWeight','normal',...
        'FontSize',fontsz.m,'Color','k')
    
    %make depth legend
    %
    
    h1 = gca;
    
    %
    %  Plots epicenters  and faults
    overlay_
    axis([ s2 s1 s4 s3])
    
    % Make the figure visible
    
    figure_w_normalized_uicontrolunits(map);
    if term == 1; whitebg; whitebg;end
    
    axes('pos',[ 0 0 1 1 ]); axis off
    str = [ 'ZMAP ' date ];
    text(0.02,0.02,str,'FontWeight','normal','FontSize',12);
    
    axes(le);
    axes(h1);
    watchoff(map)
    set(map,'Visible','on');
    done
    welcome('Message','   ');
    function create_main_plot()
    end
    
    %% create menus
    function create_overlay_menu()
        % Make the menu to change symbol size and type
        %
        symbolmenu = uimenu('Label',' --   Overlay ');
        
        %TODO use add_symbol_menu(...) instead of creating all these menus
        SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
        TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
        ColorMenu = uimenu(symbolmenu,'Label',' Symbol Color ');
        
        uimenu(SizeMenu,'Label','1','Callback','ms6 =1;eval(cal6)');
        uimenu(SizeMenu,'Label','3','Callback','ms6 =3;eval(cal6)');
        uimenu(SizeMenu,'Label','6','Callback','ms6 =6;eval(cal6)');
        uimenu(SizeMenu,'Label','9','Callback','ms6 =9;eval(cal6)');
        uimenu(SizeMenu,'Label','12','Callback','ms6 =12;eval(cal6)');
        uimenu(SizeMenu,'Label','14','Callback','ms6 =14;eval(cal6)');
        uimenu(SizeMenu,'Label','18','Callback','ms6 =18;eval(cal6)');
        uimenu(SizeMenu,'Label','24','Callback','ms6 =24;eval(cal6)');
        
        uimenu(TypeMenu,'Label','dot',...
            'Callback','ty1=''o'';ty2=''.'';ty3=''.'';eval(cal6)');
        uimenu(TypeMenu,'Label','o','Callback',...
            'ty1=''o'';ty2=''o'';ty3=''o'';eval(cal6)');
        uimenu(TypeMenu,'Label','x','Callback',...
            'ty1=''x'';ty2=''x'';ty3=''x'';eval(cal6)');
        uimenu(TypeMenu,'Label','*',...
            'Callback','ty1=''*'';ty2=''*'';ty3=''*'';eval(cal6)');
        uimenu(TypeMenu,'Label','red+ blue o green x',...
            'Callback','ty1=''+'';ty2=''o'';ty3=''x'';eval(cal6)');
        uimenu(TypeMenu,'Label','red^  blue h black o',...
            'Callback','ty1=''+'';ty2=''o'';ty3=''x'';eval(cal6)');
        uimenu(TypeMenu,'Label','none','Callback','set(deplo1,''visible'',''off'');set(deplo2,''visible'',''off'');set(deplo3,''visible'',''off''); ');
        ovmenu = uimenu(symbolmenu,'Label',' Volcanoes, Plate Boundaries etc.  ');
        
        TypeMenu = uimenu(ovmenu,'Label','Load/show volcanoes ',...
            'Callback','load volcano.mat; subcata');
        TypeMenu = uimenu(ovmenu,'Label',' Do not show volcanoes ',...
            'Callback','vo = [];subcata');
        TypeMenu = uimenu(ovmenu,'Label','Load/show plate boundaries ',...
            'Callback','load plates.mat ; fa_back = faults; faults = [faults ; plates]; subcata');
        TypeMenu = uimenu(ovmenu,'Label',' Do not show plates/faults boundaries ',...
            'Callback','faults = [];subcata');
        uimenu(ovmenu,'Label',' Load a coastline  from GSHHS database',...
            'Callback','selt = ''in'';  plotmymap;');
        uimenu(ovmenu,'Label','Add coastline/faults from existing *.mat file',...
            'Callback','think;addcoast');
        uimenu(ovmenu,'Label','Plot stations + station names',...
            'Callback','think;plotstations');
        
        lemenu = uimenu(symbolmenu,'Label',' Legend by ...  ');
        
        uimenu(lemenu,'Label',' Legend by time ',...
            'Callback','typele = ''tim'';setleg');
        uimenu(lemenu,'Label',' Legend by depth ',...
            'Callback','typele = ''dep'';subcata');
        uimenu(lemenu,'Label',' Legend by magnitude ',...
            'Callback','typele = ''mag'';setlegm');
        uimenu(lemenu,'Label',' Mag by size and depth by color (slow) ',...
            'Callback','typele = ''mad'';subcata');
        uimenu(lemenu,'Label',' Symbol color by faulting type (slow) ',...
            'Callback','typele = ''fau'';subcata');
        
        fosmenu = uimenu(symbolmenu,'Label',' Change font size ...  ');
        
        uimenu(fosmenu,'Label',' FontSize +2',...
            'Callback','fontsz=fontsz+2; subcata');
        uimenu(fosmenu,'Label',' FontSize +1',...
            'Callback','fontsz=fontsz+1; subcata');
        TypeMenu = uimenu(fosmenu,'Label',' FontSize -1',...
            'Callback','fontsz=fontsz-1; subcata');
        TypeMenu = uimenu(fosmenu,'Label',' FontSize -2',...
            'Callback','fontsz=fontsz-2; subcata');
        TypeMenu = uimenu(symbolmenu,'Label',' Change background colors ',...
            'Callback','setcol');
        
        TypeMenu = uimenu(symbolmenu,'Label',' Mark large event with M > ??',...
            'Callback','pl_large');
        
        uimenu(ColorMenu,'Label','black','Callback','co=''k'';eval(cal6B)');
        uimenu(ColorMenu,'Label','white','Callback','co=''w'';eval(cal6B)');
        uimenu(ColorMenu,'Label','red','Callback','co=''r'';eval(cal6B)');
        uimenu(ColorMenu,'Label','blue','Callback','co=''b'';eval(cal6B)');
        uimenu(ColorMenu,'Label','yellow','Callback','co=''y'';eval(cal6B)');
        
        
        cal6 = ...
            [ 'set(deplo1,''MarkerSize'',ms6,''Marker'',ty1,''visible'',''on'',''Color'',''b'');',...
            'set(deplo2,''MarkerSize'',ms6,''Marker'',ty2,''visible'',''on'',''Color'',''g'');',...
            'set(deplo3,''MarkerSize'',ms6,''Marker'',ty3,''visible'',''on'',''Color'',''r'');' ];
        
        cal6B = ...
            [ 'set(deplo1,''MarkerSize'',ms6,''Marker'',ty1,''Color'',co,''visible'',''on'');',...
            'set(deplo2,''MarkerSize'',ms6,''Marker'',ty2,''Color'',co,''visible'',''on'');',...
            'set(deplo3,''MarkerSize'',ms6,''Marker'',ty3,''Color'',co,''visible'',''on'');' ];
    end
    function create_select_menu()
        submenu = uimenu('Label',' Select ');
        uimenu(submenu,'Label','Select EQ in Polygon (Menu) ',...
            'Callback','noh1 = gca;newt2 = a; stri = ''Polygon''; keysel');
        
        uimenu(submenu,'Label','Select EQ inside Polygon ',...
            'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf; selectp');
        
        uimenu(submenu,'Label','Select EQ outside Polygon ',...
            'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf; selectpo');
        
        uimenu(submenu,'Label','Select EQ in Circle (fixed ni)',...
            'Callback',' h1 = gca;set(gcf,''Pointer'',''watch''); stri = [''  '']; stri1 = ['' ''];circle');
        
        uimenu(submenu,'Label','Select EQ in Circle (Menu) ',...
            'Callback','h1 = gca;set(gcf,''Pointer'',''watch''); stri = ['' '']; stri1 = ['' '']; incircle');
    end
    function create_catalog_menu()
        submenu = uimenu('Label','Catalog');
        uimenu(submenu,'Label','Refresh map window ',...
            'Callback','delete(gca);delete(gca);delete(gca);delete(gca);subcata');
        
        uimenu(submenu,'Label','Open new catalog ',...
            'Callback','think;hold off;startzma');
        
        uimenu(submenu,'Label','Keep this catalog in memory (use reset below to recall)',...
            'Callback','org2 = a; ');
        
        uimenu(submenu,'Label','Reset catalog to the one saved in memory previously',...
            'Callback','think;clear plos1 mark1 ; a = org2; newcat = org2; newt2= org2;subcata');
        
        uimenu(submenu,'Label','Select new parameters (reload last catalog) ',...
            'Callback','think; load(lopa);if max(a(:,decyr_idx)) < 100; a(:,decyr_idx) = a(:,decyr_idx)+1900; end, if length(a(1,:))== 7,a(:,decyr_idx) = decyear(a(:,3:5));elseif length(a(1,:))>=9,a(:,decyr_idx) = decyear(a(:,[3:5 8 9]));end;inpu');
        
        uimenu(submenu,'Label','Combine two catalogs ',...
            'Callback','think;comcat');
        
        uimenu(submenu,'Label','Compare two catalogs - find identical events',...
            'Callback','do = ''initial''; comp2cat');
        
        
        uimenu(submenu,'Label','Save current catalog (ASCII format) ',...
            'Callback','save_ca;');
        
        uimenu(submenu,'Label','Save current catalog (mat format) ',...
            'Callback','eval(catSave);');
    end
    function create_ztools_menu()
        submenu = uimenu('Label','ZTools');
        
        uimenu(submenu,'Label','Analyse time series ... ',...
            'Callback','stri = ''Polygon''; newt2 = a; newcat = a; timeplot');
        
        create_topo_map_menu(submenu);
        create_random_data_simulations_menu(submenu);
        
        uimenu(submenu,'Label','Create cross-section ',...
            'Callback','nlammap');
        
        uimenu(submenu,'Label','3-D view ',...
            'Callback','plot3d');
        
        create_histogram_menu(submenu);
        create_mapping_rate_changes_menu(submenu);
        create_map_ab_menu(submenu);
        create_map_p_menu(submenu);
        create_quarry_detection_menu(submenu);
        create_decluster_menu(submenu);
        
        uimenu(submenu,'Label','Map stress tensor',...
            'Callback','sel = ''in''; stressgrid');
        
        uimenu(submenu,'Label','Misfit calculation',...
            'Callback','inmisfit;');
        
    end
    function create_topo_map_menu(parent)
        submenu   =  uimenu(parent,'Label','Plot topographic map  ');
        
        uimenu(submenu,'Label','Open DEM GUI',...
            'Callback',' prepinp ');
        
        uimenu(submenu,'Label','3 arc sec resolution (USGS DEM) ',...
            'Callback','plt = ''lo3'' ; pltopo;');
        
        uimenu(submenu,'Label','30 arc sec resolution (GLOBE DEM) ',...
            'Callback','plt = ''lo1'' ; pltopo;');
        
        uimenu(submenu,'Label','30 arc sec resolution (GTOPO30) ',...
            'Callback','plt = ''lo30'' ; pltopo;');
        
        uimenu(submenu,'Label','2 deg resolution (ETOPO 2) ',...
            'Callback','plt = ''lo2'' ; pltopo;');
        uimenu(submenu,'Label','5 deg resolution (ETOPO 5, Terrain Base) ',...
            'Callback','plt = ''lo5''; pltopo;');
        uimenu(submenu,'Label',' Your topography (mydem, mx, my must be defined)',...
            'Callback','plt = ''yourdem''; pltopo;');
        uimenu(submenu,'Label',' Help on plotting topography',...
            'Callback','plt = ''genhelp''; pltopo;');
    end
    function create_random_data_simulations_menu(parent)
        submenu  =   uimenu(parent,'Label','Random data simulations');
        uimenu(submenu,'label','Create permutated catalog (also new b-value)...', 'Callback',' org2 = a; [a] = syn_invoke_random_dialog(a); newt2 = a;timeplot; subcata; bdiff(a); revertcat');
        uimenu(submenu,'label','Create synthetic catalog...', 'Callback',' org2 = a; [a] = syn_invoke_dialog(a); newt2 = a; timeplot; subcata; bdiff(a); revertcat');
        
        uimenu(submenu,'Label','Evaluate significance of b- and a-values  ',...
            'Callback','brand');
        uimenu(submenu,'Label','Calculate a random b map and compare to observed data  ',...
            'Callback','brand2');
        uimenu(submenu,'Label','Info on synthetic catalogs ',...
            'Callback','web([''file:'' hodi ''/zmapwww/syntcat.htm''])');
    end
    function create_mapping_rate_changes_menu(parent)
        submenu  =   uimenu(parent,'Label','Mapping rate changes');
        uimenu(submenu,'Label','Compare two periods (z, beta, probabilty)',...
            'Callback','sel= ''in'';,comp2periodz')
        
        uimenu(submenu,'Label','Calculate a z-value map',...
            'Callback','sel= ''in'';,inmakegr')
        uimenu(submenu,'Label','Calculate a z-value cross-section ',...
            'Callback','nlammap');
        uimenu(submenu,'Label','Calculate a 3D  z-value distribution',...
            'Callback','sel = ''in''; zgrid3d');
        uimenu(submenu,'Label','Load a z-value grid (map-view)',...
            'Callback','sel= ''lo'';loadgrid')
        uimenu(submenu,'Label','Load a z-value grid (cross-section-view)',...
            'Callback','sel= ''lo'';magrcros')
        uimenu(submenu,'Label','Load a z-value movie (map-view)',...
            'Callback','loadmovz')
    end
    
    function create_map_ab_menu(parent)
        submenu  =   uimenu(parent,'Label','Mapping a- and b-values');
        uimenu(submenu,'Label','Calculate a Mc, a- and b-value map ',...
            'Callback','sel= ''in'';,bvalgrid')
        uimenu(submenu,'Label','Calculate a differential b-value map (const R)',...
            'Callback','sel= ''in'';,bvalmapt')
        uimenu(submenu,'Label','Calculate a b-value cross-section ',...
            'Callback','nlammap');
        uimenu(submenu,'Label','Calculate a 3D  b-value distribution',...
            'Callback','sel = ''i1''; bgrid3dB');
        uimenu(submenu,'Label','Calculate a b-value depth ratio grid',...
            'Callback','sel= ''in'';,bdepth_ratio')
        uimenu(submenu,'Label','Load a b-value grid (map-view)',...
            'Callback','sel= ''lo'';bvalgrid')
        %RZ
        uimenu(submenu,'Label','Load a differential b-value grid',...
            'Callback','sel= ''lo'';bvalmapt')
        %RZ
        uimenu(submenu,'Label','Load a b-value grid (cross-section-view)',...
            'Callback','sel= ''lo'';bcross')
        uimenu(submenu,'Label','Load a 3D b-value grid ',...
            'Callback','sel= ''no'';ac2 = ''load''; myslicer')
        uimenu(submenu,'Label','Load a b-value depth ratio grid',...
            'Callback','sel= ''lo'';,bdepth_ratio')
    end
    
    function create_map_p_menu(parent)
        submenu  =   uimenu(parent,'Label','Mapping p-values');
        uimenu(submenu,'Label','Calculate p and b-value map ',...
            'Callback','sel= ''in'';,bpvalgrid');
        uimenu(submenu,'Label','Load existing p and b-value map ',...
            'Callback','sel= ''lo'';,bpvalgrid');
        uimenu(submenu,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE) ',...
            'Callback','sel= ''in'';,rcvalgrid_a2');
        uimenu(submenu,'Label','Load existing  Rate change, p-,c-,k-value map (MLE)',...
            'Callback','sel= ''lo'';rcvalgrid_a2');
    end
    
    function create_quarry_detection_menu(parent)
        submenu  = uimenu(parent,'Label','Detect quarry contamination');
        uimenu(submenu,'Label','Map day/nighttime ration of events ',...
            'Callback','sel = ''in'';findquar;');
        uimenu(submenu,'Label','Info on detecting quarries. ',...
            'Callback','web([''file:'' hodi ''/help/quarry.htm''])');
    end
    
    function create_histogram_menu(parent)
        submenu = uimenu(parent,'Label','Histograms');
        
        uimenu(submenu,'Label','Magnitude',...
            'Callback','global histo;hisgra(a(:,mag_idx),stt1);');
        uimenu(submenu,'Label','Depth',...
            'Callback','global histo;hisgra(a(:,dep_idx),stt2);');
        uimenu(submenu,'Label','Time',...
            'Callback','global histo;hisgra(a(:,decyr_idx),''Time '');');
        uimenu(submenu,'Label','Hr of the day',...
            'Callback','global histo;hisgra(a(:,hr_idx),''Hr '');');
        uimenu(submenu,'Label','Stress tensor quality',...
            'Callback','global histo;hisgra(a(:,13),''Quality '');');
    end
    function create_decluster_menu(parent)
        submenu = uimenu(parent,'Label','Decluster the catalog');
        uimenu(submenu,'Label','Decluster using Reasenberg',...
            'Callback','inpudenew;');
        uimenu(submenu,'Label','Decluster using Gardner & Knopoff',...
            'Callback','declus_inp;');
    end
    
    %% % % % callbacks
    function catSave()
        welcome('Save Data', ' ');
        try
            think;
            [file1, path1] = uiputfile(fullfile(hodi, 'eq_data', '*.mat'), 'Earthquake Datafile');
            if length(file1) > 1
                wholePath=[path1 file1]
                save('WholePath', 'a', 'faults','main','mainfault','coastline','infstri','well');
            end
            done
        catch ME
            warning(ME)
        end
    end
    
end