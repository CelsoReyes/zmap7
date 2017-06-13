function mainmap_overview()
    % This is  the .m file substitute for "mainmap_overview().m". It plots the earthquake data
    % on a map and supplies the user with an
    %  interface to do further analyses.
    %
    %  Depending on the selection it resets newt2, newcat and a
    %
    % Tag: 'main_map_ax' contains the main map
    
    
    global a file1 t0b teb par1 ms6 ty1 ty2 ty3 fontsz name typele% newt2 newcat
    ty1=evalin('base','ty1');
    ty2=evalin('base','ty2');
    ty3=evalin('base','ty3');
    ms6=evalin('base','ms6');
    typele = evalin('base','typele');
    
    if isempty(a)
        think
        welcome('Message','No data in catalog, cannot plot Seismicity Map ....');
        pause(2)
        done;
        welcome('Messages', 'Choose a catalog' );
        return
    end
    
    if isempty(typele)
        typele = 'dep';
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
    
    [existFlag,map]=figure_exists('Seismicity Map',1);
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
    figure(map)
    %reset(gca)
    %cla
    delete(findobj(map, 'type','axes'));
    watchon();
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
    main_map_ax = axes('position',rect,'Tag','main_map_ax');
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
            deplo1=plot(main_map_ax,a(depth_mask,lon_idx), a(depth_mask,lat_idx),'ob','Tag','mapax_part1');
            set(deplo1,'MarkerSize',ms6);
            
            depth_mask = a_mags>=dep2 & a_mags< dep3;
            deplo2=plot(main_map_ax, a(depth_mask,lon_idx), a(depth_mask,lat_idx),'ob','Tag','mapax_part2');
            set(deplo2,'MarkerSize',ms6*2);
            
            depth_mask = a_mags>=dep3;
            deplo3 =plot(main_map_ax, a(depth_mask,lon_idx), a(depth_mask,lat_idx),'ob','Tag','mapax_part3');
            set(deplo3,'MarkerSize',ms6*3)
            
            ls1 = sprintf('M > %3.1f ',dep1);
            ls2 = sprintf('M > %3.1f ',dep2);
            ls3 = sprintf('M > %3.1f ',dep3);
            le = legend(main_map_ax,ls1,ls2,ls3);
            set(le,'position',[ 0.65 0.02 0.32 0.12],'FontSize',12,'color','w')
            
        case 'mad'
            mindep = min(a(:,dep_idx));
            maxdep = max(a(:,dep_idx));
            c = jet;
            
            colormapName = colormapdialog();
            
            switch colormapName
                case 'jet'
                    c = jet;
                    c = c(64:-1:1,:);
                otherwise
                    c = colormap(colormapName);
            end % switch
            
            % sort by depth
            [s,is] = sort(a(:,dep_idx));
            a = a(is(:,lon_idx),:) ;
            %%
            % get all colors by depth at once
            fac = 64 / max(a(:,dep_idx));
            colrs = ceil(a(:, dep_idx) .* fac) + 1;
            colrs = min(colrs, 63);
            colrs = max(colrs, 1);
            % set all sizes by mag
            sm = mag2dotsize(a(:,mag_idx));
            
            pl = scatter(main_map_ax, a(:,lon_idx), a(:,lat_idx), sm, colrs,'o','filled');
            pl.MarkerEdgeColor = 'flat';
            set(main_map_ax,'pos',[0.13 0.08 0.65 0.85]) %why?
            drawnow
            watchon;
            
            % resort by time
            [s,is] = sort(a(:,3));
            a = a(is(:,lon_idx),:) ;
            
            % make a depth legend
            
            vx =  (mindep:1:maxdep);
            v = [vx ; vx]; v = v';
            rect = [0.83 0.2 0.01 0.2];
            h1 = axes('position',rect)
            h=pcolor((1:2),vx,v)
            shading flat
            set(gca,'XTickLabels',[]);
            set(gca,'FontSize',8,'FontWeight','normal',...
                'LineWidth',1.0,'YAxisLocation','right',...
                'Box','on','SortMethod','childorder','TickDir','out','ydir','reverse')
            xlabel('  Depth [km]');
            colormap(c)
            % make a mag legend:
            
            anzmag = 0;
            allpl = [];
            allls = [];
             
            axes(h1);
            hold on
            eventsizes = floor(min(a(:,mag_idx))) : ceil(max(a(:,mag_idx)));
            eqmarkersizes = mag2dotsize(eventsizes);
            
            for i = eqmarkersizes
                pl = plot(h1, a(1,lon_idx),a(1,lat_idx),'.k');
                i = max(i,1);
                set(pl,'Markersize',i);
                anzmag = anzmag+1;
            end
            allls = {strcat('M ',num2str(eventsizes(end:-1:1)'))};
            le = legend(h1.Children, allls{:});
            set(le,'position',[ 0.83 0.7 0.08 0.2],'FontSize',10,'color','w')
            hold off;
            axes(h1)
            watchoff;
            set(gcf,'color','w');
        case 'fau'
            error('not fully implemented');
            % Script: symbol_faultingtype.m
            % Plot eqs according to faulting style using rake as discriminator
            % -180 <= Rake <= 180
            % This is an approximation!
            % last update: J. Woessner, jowoe@gps.caltech.edu
            report_this_filefun(mfilename('fullpath'));
            
            % Load colormap
            load rakec.mat
            c = rakec;
            
            % Loop over events
            for i = 1:length(a)
                pl =plot(main_map_ax,a(i,lon_idx), a(i,lat_idx), 'ow');
                hold on
                fac = 64/max(a(:,12));
                col = floor(a(i,12)+180/360*63);
                col = ceil(abs(a(i,12)*fac))+1;
                if col > 63
                    col = 63;
                end
                if col < 1
                    col = 1 ;
                end
                set(pl,'Markersize',6,'markerfacecolor',[c(col,:)],'markeredgecolor','k');
            end
            h1 = gca;
            drawnow
            watchon;
            
            % make a faulting style legend
            vx =  (-180:1:180);
            v = [vx ; vx]; v = v';
            rect = [0.86 0.22 0.02 0.4];
            axes('position',rect)
            pcolor((1:2),vx,v)
            shading flat
            set(gca,'XTickLabels',[],'Ytick',[-180 -90 0 90 180])
            set(gca,'FontSize',8,'FontWeight','normal',...
                'LineWidth',1.0,'YAxisLocation','right',...
                'Box','on','SortMethod','childorder','TickDir','out')
            xlabel('   Rake ');
            colormap(rakec)
            axes(h1)
            set(h1,'pos',[0.12 0.2 0.65 0.6])
            watchoff;
            %typele = 'dep';
            
            
            axes('pos',[0 0 1 1 ]);
            axis off
            
            text(0.92,0.22,'right lat.','FontSize',8);
            text(0.92,0.34,'normal','FontSize',8);
            text(0.92,0.42,'left lat.','FontSize',8);
            text(0.92,0.5,'thrust','FontSize',8);
            text(0.92,0.62,'right lat.','FontSize',8);
            axes(h1)
            
            
            %plot earthquakes according to depth
        case 'dep'
            a_depths = a(:,dep_idx);
            
            % divide depths into 3 categories
            dep1 = 0.3*max(a_depths);
            dep2 = 0.6*max(a_depths);
            dep3 = max(a_depths);
            
            % shallowest
            dep_mask = a_depths <= dep1;
            deplo1 =plot(main_map_ax, a(dep_mask,lon_idx),a(dep_mask,lat_idx),'.b','Tag','mapax_part1');
            set(deplo1,'MarkerSize',ms6,'Marker',ty1);
            
            % mid level
            dep_mask = dep1<a_depths & a_depths<=dep2;
            deplo2 =plot(main_map_ax, a(dep_mask,lon_idx),a(dep_mask,lat_idx),'.g','Tag','mapax_part2');
            set(deplo2,'MarkerSize',ms6,'Marker',ty2);
            
            % deep
            dep_mask =  dep2<a_depths & a_depths<=dep3;
            deplo3 =plot(main_map_ax, a(dep_mask,lon_idx),a(dep_mask,lat_idx),'.r','Tag','mapax_part3');
            set(deplo3,'MarkerSize',ms6,'Marker',ty3)
            
            ls1 = sprintf('Z ≤ %3.1f km',dep1);
            ls2 = sprintf('Z ≤ %3.1f km',dep2);
            ls3 = sprintf('Z ≤ %3.1f km',dep3);
            
            le = legend(main_map_ax,ls1,ls2,ls3);
            set(le,'position',[ 0.65 0.02 0.32 0.12],'FontSize',12,'color','w')
            %plot earthquakes according time
        case 'tim'
            a_times = a(:,decyr_idx);
            timedivisions = linspace(min(a_times),max(a_times),4);
            
            time_mask = timedivisions(2) <= a_times & a_times >= timedivisions(1);
            deplo1 =plot(main_map_ax, a(time_mask,lon_idx), a(time_mask,lat_idx),'.b','Tag','mapax_part1');
            set(deplo1,'MarkerSize',ms6,'Marker',ty1)
            
            time_mask = timedivisions(2) < a_times & a_times <= timedivisions(3);
            deplo2 =plot(main_map_ax, a(time_mask,lon_idx), a(time_mask,lat_idx),'.g','Tag','mapax_part2');
            set(deplo2,'MarkerSize',ms6,'Marker',ty2);
            
            time_mask = timedivisions(3)< a_times & a_times <= timedivisions(4);
            deplo3 =plot(main_map_ax, a(time_mask,lon_idx),a(time_mask,lat_idx),'.r','Tag','mapax_part3');
            set(deplo3,'MarkerSize',ms6,'Marker',ty3)
            
            ls1 = sprintf('%3.1f ≤ t ≤ %3.1f ',timedivisions(1),timedivisions(2));
            ls2 = sprintf('%3.1f < t ≤ %3.1f ',timedivisions(2),timedivisions(3));
            ls3 = sprintf('%3.1f < t ≤ %3.1f ',timedivisions(3),timedivisions(4));
            
            le = legend(main_map_ax,ls1,ls2,ls3);
            set(le,'position',[ 0.65 0.02 0.32 0.12],'FontSize',12,'color','w')
        otherwise
            errror
            %le = legend([deplo1 deplo2 deplo3],ls1,ls2,ls3);
            % set(le,'position',[ 0.65 0.02 0.32 0.12],'FontSize',12,'color','w')
    end
    
    
    
    set(main_map_ax,'FontSize',fontsz.s,'FontWeight','normal',...
        'Ticklength',[0.01 0.01],'LineWidth',1.0,...
        'Box','on','TickDir','out')
    
    xlabel(main_map_ax,'Longitude [deg]','FontSize',fontsz.m)
    ylabel(main_map_ax,'Latitude [deg]','FontSize',fontsz.m)
    strib = [  ' Map of '  name '; '  num2str(t0b,5) ' to ' num2str(teb,5) ];
    title(main_map_ax,strib,'FontWeight','normal',...
        'FontSize',fontsz.m,'Color','k')
    
    %make depth legend
    %
    axes(main_map_ax);
    h1 = main_map_ax;
    
    %
    %  Plots epicenters  and faults
    overlay_
    axis([ s2 s1 s4 s3])
    
    % Make the figure visible
    
    figure_w_normalized_uicontrolunits(map);
    
    axes('pos',[ 0 0 1 1 ]); axis off
    str = [ 'ZMAP ' date ];
    text(0.02,0.02,str,'FontWeight','normal','FontSize',12);
    
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
        
        sizes_to_create = [1 3 6 9 12 14 18 24];
        for n = sizes_to_create
            uimenu(SizeMenu,'Label',num2str(n),'Callback', @(s,e) change_markersize(n));
        end
        
        symbols_to_create = {...
            {'dot',[],'...'},...
            {'o',[],'ooo'},...
            {'x',[],'xxx'},...
            {'*',[],'***'},...
            {'red+ blue o green x',[1 0 0;0 0 1; 0 1 0],'+ox'},...
            {'red^  blue h black o',[1 0 0; 0 0 1; 0 0 0],'^ho'}};
        
        for z = 1:numel(symbols_to_create)
            this_symb = symbols_to_create{z};
            uimenu(TypeMenu,'Label',this_symb{1},...
                'Callback', @(s,e) change_symbol(this_symb{:}));
        end
        
        uimenu(TypeMenu,'Label','none','Callback','set(deplo1,''visible'',''off'');set(deplo2,''visible'',''off'');set(deplo3,''visible'',''off''); ');
        ovmenu = uimenu(symbolmenu,'Label',' Volcanoes, Plate Boundaries etc.  ');
        
        uimenu(ovmenu,'Label','Load/show volcanoes ',...
            'Callback','load volcano.mat; mainmap_overview()');
        uimenu(ovmenu,'Label',' Do not show volcanoes ',...
            'Callback','vo = [];mainmap_overview()');
        uimenu(ovmenu,'Label','Load/show plate boundaries ',...
            'Callback','load plates.mat ; fa_back = faults; faults = [faults ; plates]; mainmap_overview()');
        uimenu(ovmenu,'Label',' Do not show plates/faults boundaries ',...
            'Callback','faults = [];mainmap_overview()');
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
            'Callback','typele = ''dep'';mainmap_overview()');
        uimenu(lemenu,'Label',' Legend by magnitude ',...
            'Callback','typele = ''mag'';setlegm');
        uimenu(lemenu,'Label',' Mag by size and depth by color',...
            'Callback','typele = ''mad'';mainmap_overview()');
        uimenu(lemenu,'Label',' Symbol color by faulting type (slow) ',...
            'Callback','typele = ''fau'';mainmap_overview()');
        
        fosmenu = uimenu(symbolmenu,'Label',' Change font size ...  ');
        
        uimenu(fosmenu,'Label',' FontSize +2',...
            'Callback','fontsz=fontsz+2; mainmap_overview()');
        uimenu(fosmenu,'Label',' FontSize +1',...
            'Callback','fontsz=fontsz+1; mainmap_overview()');
        uimenu(fosmenu,'Label',' FontSize -1',...
            'Callback','fontsz=fontsz-1; mainmap_overview()');
        uimenu(fosmenu,'Label',' FontSize -2',...
            'Callback','fontsz=fontsz-2; mainmap_overview()');
        uimenu(symbolmenu,'Label',' Change background colors ',...
            'Callback','setcol');
        
        uimenu(symbolmenu,'Label',' Mark large event with M > ??',...
            'Callback',@(s,e) plot_large_quakes);
        
        uimenu(ColorMenu,'Label','black','Callback','co=''k'';eval(cal6B)');
        uimenu(ColorMenu,'Label','white','Callback','co=''w'';eval(cal6B)');
        uimenu(ColorMenu,'Label','red','Callback','co=''r'';eval(cal6B)');
        uimenu(ColorMenu,'Label','blue','Callback','co=''b'';eval(cal6B)');
        uimenu(ColorMenu,'Label','yellow','Callback','co=''y'';eval(cal6B)');
        
        
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
            'Callback','delete(findobj(gcf, ''type'',''axes''));mainmap_overview()');
        
        uimenu(submenu,'Label','Open new catalog ',...
            'Callback','think;hold off;startzma');
        
        uimenu(submenu,'Label','Keep this catalog in memory (use reset below to recall)',...
            'Callback','org2 = a; ');
        
        uimenu(submenu,'Label','Reset catalog to the one saved in memory previously',...
            'Callback','think;clear plos1 mark1 ; a = org2; newcat = org2; newt2= org2;mainmap_overview()');
        
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
        
        uimenu(submenu,'Label','Show main message window',...
            'Callback', @(s,e)zmap_message_center());
        
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
        uimenu(submenu,'label','Create permutated catalog (also new b-value)...', 'Callback',' org2 = a; [a] = syn_invoke_random_dialog(a); newt2 = a;timeplot; mainmap_overview(); bdiff(a); revertcat');
        uimenu(submenu,'label','Create synthetic catalog...', 'Callback',' org2 = a; [a] = syn_invoke_dialog(a); newt2 = a; timeplot; mainmap_overview(); bdiff(a); revertcat');
        
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
                wholePath=[path1 file1];
                save('WholePath', 'a', 'faults','main','mainfault','coastline','infstri','well');
            end
            done
        catch ME
            warning(ME)
        end
    end
    
end

function change_markersize(val)
    global ms6
    ms6 = val;
    ax = findobj(0,'Tag','main_map_ax');
    set(findobj(ax,'Type','Line'),'MarkerSize',val);
end

function change_symbol(~, clrs, symbs)
    global ty1 ty2 ty3 ms6
    ty1 = symbs(1);
    ty2 = symbs(2);
    ty3 = symbs(3);
    ax = findobj(0,'Tag','main_map_ax');
    line_tags = {'mapax_part1','mapax_part2','mapax_part3'};
    for n=1:3
        ax_ln = findobj(ax,'Tag',line_tags{n});
        if ~isempty(clrs)
            set(ax_ln,'MarkerSize',ms6,'Marker',symbs(n),'Color',clrs(n,:),'Visible','on');
        else
            set(ax_ln,'MarkerSize',ms6,'Marker',symbs(n), 'Visible', 'on');
        end
    end
end

function plot_large_quakes()
    global minmag maex maix maey maiy maepi a 
    def = {'6'};
    ni2 = inputdlg('Mark events with M > ? ','Choose magnitude threshold',1,def);
    l = ni2{:};
    minmag = str2double(l);

    clear maex maix maey maiy
    l = a(:,6) > minmag ;
    maepi = a(l,:);
    mainmap_overview()
end
function choice = colormapdialog()
    d = dialog('Position',[300 300 250 150], 'Name', 'Choose Colormap');
    txt = uicontrol('Parent',d, 'Style','Popup','Position',[20 80 210 40],...
        'String',{'parula';'jet';'hsv';'hot';'cool';'spring';'summer';'autumn';'winter'},...
        'Callback', @popup_callback);
    btn = uicontrol('Parent',d,...
        'Position',[89 20 70 25],...
        'String','Close',...
        'Callback','delete(gcf)');
    choice = 'parula';
    uiwait(d);
    
    function popup_callback(popup, ~)
        idx = popup.Value;
        popup_items = popup.String;
        choice = char(popup_items(idx,:));
    end
end
    

function sz = mag2dotsize(maglist)
    facm = 8 ./ max(maglist);
    sz = maglist .* facm;
    sz = ceil(max(1,sz) .^ 2);
end
    
    