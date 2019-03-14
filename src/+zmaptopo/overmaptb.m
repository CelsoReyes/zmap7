function overmaptb() 
    % expects:
    %   tmap
    %   bc
    %   s4_south
        
    ZG = ZmapGlobal.Data; % used by get_zmap_globals
    
    top = findobj('Type','Figure','-and','Name','Topographic Map (Mapping Toolbox)');
    if isempty(top) || isnan(bc)
        bc = 'new' ; 
    end
    
    % check if mapping toolbox and topo map exists
    if ~has_mapping_toolbox()
        error('Mapping toolbox is required');
    end
    
    tmap(isnan(tmap)) = -1; %Replace the NaNs in the ocean with -1 to color them blue.
    
    top = figure_w_normalized_uicontrolunits( ...
        'Name'          , 'Topographic Map (Mapping Toolbox)',...
        'NumberTitle'   , 'off', ...
        'Visible'       , 'on', ...
        'NextPlot'      , 'add', ...
        'Position'      , [ ZG.fipo(1)+20 ZG.fipo(2)-20 1.5*winx 1.5*winy],...
        'Color'         , [1 1 1]);
    
    shading flat
    mapax1 = axesm('MapProjection', 'eqdcylin');
    [latlim,lonlim] = limitm(tmap, tmapleg);
    meshm(tmap, tmapleg, size(tmap), tmap);
    demcmap(tmap)
    
    if min(tmap(:)) > 0
        demcmap(tmap, 100,[0 0.8 1], []);
    else
        demcmap(tmap)
    end
    daspectm('m', 15);
    
    camlight(-80, 0); 
    lighting phong; 
    material([.8 1 0]);
    
    h_colorbar = colorbar;
    set(h_colorbar,'Position', [0.9 0.3 0.015 .3])
    set(h_colorbar,'visible'    , 'on', ...
        'FontSize'      , ZmapGlobal.Data.fontsz.s, ...
        'FontWeight'    , 'normal', ...
        'LineWidth'     , 1, ...
        'Box'           , 'on', ...
        'TickDir'       , 'out')
    
    get_tics = @(mylims) abs( abs(mylims(1)) - abs(mylims(2)) ) / 4;
    tilat = get_tics(latlim);
    tilon = get_tics(lonlim);
    
    setm(gca,'maplatlimit'  , latlim,...
        'maplonlimit'       , lonlim,...
        'meridianlabel'     , 'on',...
        'parallellabel'     , 'on',...
        'plinelocation'     , tilat,...
        'mlinelocation'     , tilon,...
        'glinestyle'        ,'-.',...
        'grid'              , 'off', ...
        'plabellocation'    , tilat,...
        'mlabellocation'    , tilon,...
        'LabelFormat'       , 'compass',...
        'flinewidth'        , 3)
    
    showaxes('hide')
    
    add_controls()
    
    scaleruler off
    scaleruler on
    [xlo, ylo] = mfwdtran(s4_south - tilat / 3, s2_west);
    setm(handlem('scaleruler'),'XLoc',xlo,'YLoc',ylo,'RulerStyle','patches','FontSize',7)
    
    function add_controls()
        uicontrol('Style', 'pushbutton', 'String', ' Projection Control dialog box',...
            'Position', [0.02 0.03 0.23 .04],'Units','Normalized',...
            'Callback',@projection_control_cb); % ha1
        
        labelPos=[ .3 0.03 0.16 0.04];
        uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String', cb_eqplotter(),...
            'callback',@cb_eqplotter);
        
        labelPos=[ .5 0.03 0.16 0.04];
        uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',cb_faultplotter(),...
            'callback',@cb_faultplotter);
        
        labelPos=[ .3 0.08 0.16 0.04];
        uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',cb_mainshocks(),...
            'callback',@cb_mainshocks);
        
        labelPos=[ .5 0.08 0.16 0.04];
        uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',cb_stations(),...
            'callback',@cb_stations);
        
        
        labelPos=[ .7 0.03 0.16 0.04];
        uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',labelList,...
            'callback', @cb_colormap);
        
        
        uicontrol('Style', 'pushbutton', 'String', ' darken',...
            'Position', [0.02 0.1 0.10 .03],'Units','Normalized','Callback', @(~,~)brighten (-0.1));
        
        uicontrol('Style', 'pushbutton', 'String', ' brighten',...
            'Position', [0.02 0.15 0.10 .03],'Units','Normalized','Callback', @(~,~)brighten (0.1));
        
        uicontrol('Style', 'pushbutton', 'String', ' Black/White',...
            'Position', [0.7 0.08 0.10 .03],'Units','Normalized', 'Callback', @cb_bw);
        
    end
    
    %% callbacks
    function labelList = cb_eqplotter(mysrc, ~)
        labelList = {'EQ (dot)', 'EQ (o)', 'EQ (dot) on top (slow)', 'EQ (o) on top (slow)', 'No EQ'};
        if nargin==0
            return
        end

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        %case 'eq'
        inp = mysrc.Value;
        globalcatalog = ZG.primeCatalog;
        
        if eqontop == 0  &&  (inp==3 || inp==4)
            clear('depq')
            [lat,lon] = meshgrat(tmap,tmapleg);
            depq = interp2(lon, lat, tmap, globalcatalog.Longitude, globalcatalog.Latitude);
            % depq=depq'
            eqontop = 1;
        end
        
        if inp == 5
            delete(ploe);
            return
        end
        
        % options that are inp dependent... 
        markerEdgeColorOptions  = 'wkrk';
        lineColorOptions        = 'wrrr';
        markerFaceColorOptions  = {'none','w','w','w'};
        markerSizeOptions       = [2, 3, 2, 3];
        
        if (inp ==1 || inp == 2) % 2-D plots
            ploe = plotm(globalcatalog.Latitude, globalcatalog.Longitude,'o');
            zdatam(handlem('allline'),max(tmap(:)));
        elseif (inp == 3 || inp == 4) % 3-D plots
            ploe = plot3m(globalcatalog.Latitude, globalcatalog.Longitude, depq+25,'o');
        else
            error('invalid inp');
        end
        ploe.LineWidth = 0.1;
        ploe.MarkerSize = markerSizeOptions(inp);
        ploe.MarkerEdgeColor = markerEdgeColorOptions(inp);
        ploe.MarkerFaceColor = markerFaceColorOptions{inp};   
        ploe.Color = lineColorOptions(inp);
    end
    
    function labelList = cb_faultplotter(mysrc, ~)
        labelList = {'Faults', 'Faults on top (slow)', 'No Faults'};
        if nargin==0
            return
        end
        
        inp = mysrc.Value;
        % case 'fau'
        if fontop == 0  &&  inp == 2
            [lat,lon] = meshgrat(tmap, tmapleg);
            depf = interp2(lon, lat, tmap, faults(:,1), faults(:,2));
            fontop = 1;
        end
        
        if inp == 1
            plof = plotm(faults(:,2), faults(:,1), 'm', 'Linewidth', 2)
            zdatam(handlem('allline'),max(tmap(:)));
        elseif inp == 2
            plof = plot3m(faults(:,2), faults(:,1), depf+25, 'm', 'Linewidth', 2);
        elseif inp == 3
            delete(plof) ; 
        end
    end
    
    function labelList = cb_mainshocks(mysrc, ~)
        labelList = {'Main', 'No Main'};
        if nargin==0
            return
        end
        % case 'mai'
        inp = mysrc.Value;
        if montop == 0
            clear('depm')
            [lat,lon] = meshgrat(tmap,tmapleg);
            depm = interp2(lon,lat,tmap,ZG.maepi.Longitude,ZG.maepi.Latitude);
            %depm=depm'
            montop = 1;
        end
        
        if inp == 1
            plom = plot3m(ZG.maepi.Latitude,ZG.maepi.Longitude,depm+25,'hm');
            set(plom,'LineWidth',1.5,'MarkerSize',12,...
                'MarkerFaceColor','y','MarkerEdgeColor','k')
        elseif inp == 2
            delete(plom); 
        end
    end
    
    function labelList = cb_stations(mysrc, ~)
        labelList = {'Stations', 'No Stations'};
        if nargin==0
            return
        end
        %    case 'sta'
        inp = mysrc.Value;
        
        if inp == 1
            h1 = h1topo
            plotstations
        end
        if inp == 2
            do_nothing();
        end
    end
    
    function labelList = cb_colormap(mysrc, ~)
        labelList={'colormap (decmap)', 'colormap(gray)'};
        if nargin==0
            return
        end
        
        % case 'cm'
        inp = mysrc.Value;
        if inp == 1
            if min(tmap(:)) > 0
                demcmap(tmap, 100, [0 0.8 1], []);
            else
                demcmap(tmap)
            end
        elseif inp == 2
            demcmap(tmap, 64, [ 1 1 1 ], [.3 .3 .3; .8 .8 .8])
        end
        daspectm('m', 15);
    end
    
    function cb_bw(mysrc,myevt)
        bc = 'bw';
        overmaptb;
    end
    
    function projection_control_cb(~,~)
        scaleruler off;
        axesmui;
        bc = ' ';
        overmaptb(bc);
    end
    
end
