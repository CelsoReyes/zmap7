function dramap_z(STYLE, bg_color, value_map)
    % drap a colormap of variance, S1 orientation onto topography
    %
    % requires:
    %   tmap : topography map
    %   tmapleg : 
    %   gx, gy
    %   s1_north...s4_south
    
    assert(ismember(STYLE, {'dramap2_z','dramap_z','stress2'}));
    
    report_this_filefun();
    
    % STYLE simply allows this function to merge functionality of
    % two versions... 
    %STYLE = "dramap2_z";
    %STYLE = "stress2";
    STYLE = "dramap_z";
    USE_SCALE_RULER = false; % SCALE_RULER code was commmented out in dramap_z and dramap_stress2.
                             % and didn't exist in dramap_z
    
    
    if ~has_mapping_toolbox()
        return
    end
    
    if ~exist('tmap', 'var') 
        tmap = 0;
    end
    [xx, yy] = size(tmap);
    if xx*yy < 30
        errordlg('Please create a topomap first, using the options from the seismicity map window');
        return
    end
    if STYLE == "dramap2_z"
        projections = {... % friendly name      , official
            'Albers Equal-Area Conic'           , 'equaconic';...
            'Mercator Projection'               , 'mercator';...
            'Plate Carree Projection'           , 'pcarree'; ...
            'Lambert Conformal Conic Projection', 'lambert';...
            'Robinson Projection'               , 'robinson'};
        selz = menu('Choose a projection', projections{:,1});
        selected_proj = projections{selz, 2}; % was 'mapz(...)'
        mic_offset = 0.1;
    else
        selected_proj = 'eqaconic';
        mic_offset = 0;
    end
        
    
    dlgtitle ='Topo map input parameters';
    dstr(1).prompt = 'Longitude label spacing (degrees)';   dstr(1).value = 1;
    dstr(2).prompt = 'Latitude label spacing (degrees)';    dstr(2).value = 1;
    dstr(3).prompt = 'Topo data-aspect (steepness)';        dstr(3).value = 5;
    dstr(4).prompt = ' Minimum datavalue (cmin)';           dstr(4).value = min(value_map(:));
    dstr(5).prompt = ' Maximum datavalue cmap';             dstr(5).value = max(value_map(:));
    dstr(6).prompt = ' Sea Level (set values below this to 0. ex 0.01)';     dstr(6).value = -inf;
        
    [~, ~, dlo, dla, dda, mic, mac, sealevel] = smart_inputdlg(dlgtitle, dstr);
    
    % use this for setting water levels to one color
    %tmap(isnan(tmap)) = 1;
    
    tmap(tmap < sealevel) = 0;
    
    value_map(value_map < mic) = mic + mic_offset;
    value_map(value_map > mac) = mac;
    
    [lat, lon] = meshgrat(tmap, tmapleg);
    [X , Y]  = meshgrid(gx, gy);
    
    ren = interp2(X, Y, value_map, lon, lat);
    
    ren(isnan(ren)) = min(ren(:)) - 20;
    
    if STYLE == "dramap2_z"
        ren(tmap <= 1 & ren < mic) = nan;
    end
    
    %start figure
    fig = figure_w_normalized_uicontrolunits('pos', [50 100 800 600]);
    ax = gca;
    set(ax, 'NextPlot', 'add'); 
    axis off
    axesm('MapProjection', selected_proj, 'MapParallels', [],...
        'MapLatLimit', [s4_south s3_north], 'MapLonLimit', [s2_west s1_east])
    
    meshm(ren, tmapleg, size(tmap), tmap);
    
    daspectm('m', dda);
    tightmap
    view([0 90])
    camlight; 
    lighting phong
    set(ax, 'projection', 'perspective');
    
    if STYLE == "stress2"
        % plot the bars
        plq = quiverm(newgri(:,2), newgri(:,1), -cos(ste(:,SA*2)*pi/180), sin(ste(:,SA*2)*pi/180),0.9);
        set(plq,'LineWidth', 0.4, 'Color', 'k', 'Markersize',0.1);
        set(gca,'NextPlot', 'add');
        
        delete(plq(2));
    end
    
    if STYLE == "dramap2_z" || STYLE == "stress2"
        if ~isempty(coastline)
            pl = plotm(coastline(:,2), coastline(:,1), 'k');
            set(pl, 'LineWidth', 0.5)
        end
        
        if ~isempty(ZG.maepi)
            pl = plotm(ZG.maepi.Y, ZG.maepi.X, 'hw');
            set(pl,'LineWidth', 1, 'MarkerSize', 14,...
                'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k')
        end
        if STYLE == "stress2"
            zdatam(handlem('allline'), max(tmap(:))) % keep line on surface
        end
        
        j = jet(64); % different from dramap2_z
        j = [ [ 0.8 0.8 0.8 ] ; j  ];
    else
        j = colormap;
        j = [ [ 0.9 0.9 0.9 ] ; j];
    end
    
    caxis([ mic * 0.99, mac * 1.01 ]);
    colormap(j); 
    brighten(0.1);
    axis off;
        
    setm(ax,'mlabellocation', dlo)
    setm(ax,'meridianlabel', 'on')
    setm(ax,'plabellocation', dla)
    setm(ax,'parallellabel', 'on')
    
    if ~exist('bg_color', 'var') || bg_color == 'w' % white background
        fg = 'k';
        bg = 'w';
    else  % black background
        fg = 'w';
        bg = 'k';
    end
    
    set(fig, 'color', bg)
    setm(ax, 'ffacecolor', bg)
    setm(ax, 'fedgecolor', fg, 'flinewidth', 3);
    
    % change the labels if needed
    setm(ax,'Fontcolor', fg, 'Fontweight', 'bold', 'FontSize', 12, 'Labelunits', 'dm')
    
    h5 = colorbar;
    set(h5,'position',[0.8 0.35 0.01 0.3], 'TickDir', 'out', 'Ycolor', fg, 'Xcolor', fg,...
        'Fontweight', 'bold', 'FontSize', 12);
    set(fig, 'Inverthardcopy', 'off');
    
    if USE_SCALE_RULER 
        scaleruler
        if STYLE == "dramap2_z"
            XLoc = -0.0133;
            YLoc = 0.639;
            MajorTick = 0:10:50;
            majorTickLength = 4;
        elseif STYLE == "stress2"
            XLoc = 12;
            YLoc = 40;
            MajorTick = 0:50:200;
            majorTickLength = 12;
        end
        
        setm(handlem('scaleruler1'), 'XLoc', XLoc, 'YLoc', YLoc, 'units', 'km')
        setm(handlem('scaleruler2'),'MajorTick', MajorTick,...
                'MinorTick', 0:10:25, 'TickDir', 'down',...
                'MajorTickLength', majorTickLength,...
                'MinorTickLength', 4)
            
        setm(handlem('scaleruler1'), 'RulerStyle', 'ruler')
        if STYLE == "dramap2_z"
            setm(handlem('scaleruler2'), 'RulerStyle', 'patches')
        end
        refresh
    end
end
