function [c2, gcDist_km, zans] = plot_cross_section_from_mainmap
    %PLOT_CROSS_SECTION_FROM_MAINMAP create a cross-section from the map.
    %  [CatalogInCrossSection, distanceAlongStrike, optionsUsed] = PLOT_CROSS_SECTION_FROM_MAINMAP
    %
    % you can choose section width, start & end labels, and color.
    %
    % plots cross-section (great-circle curve) on map, along with boundary for selected events.
    % brings up new figure containing cross-section, with selected events plotted with depth, 
    % and histograms of events along sgtrike and with depth
    
    ZG=ZmapGlobal.Data;
    catalog=ZG.primeCatalog; % points to same thing
    
    % dialog box to choose cross-section
    zdlg=ZmapDialog();
    zdlg.AddEdit('slicewidth_km','Width of slice [km]',20,'distance from slice for which to select events. 1/2 distance in either direction');
    zdlg.AddEdit('startlabel','start label','A','start label for map');
    zdlg.AddEdit('endlabel','end label','A''','start label for map');
    zdlg.AddCheckbox('choosecolor','choose cross-section color [red]', false,{},...
                    'When checked, a color selection dialog will allow you to choose a different cross-section color');
    zdlg.AddPopup('chooser','Choose Points',{'choose start and end with mouse'},1,'no choice');
    zans=zdlg.Create('Name', 'slicer');
    C = [1 0 0]; % color for cross-section
    if zans.choosecolor
        C=uisetcolor(C,['Color for ' zans.startlabel '-' zans.endlabel]);
    end
    
    [lon, lat, xs_endpts] = get_endpoints(gca,C);
    
    % get waypoints along the great-circle curve
    [curvelats,curvelons]=gcwaypts(lat(1),lon(1),lat(2),lon(2),100);
    
    % plot great-circle path
    xs_line=plot(curvelons,curvelats,'--','LineWidth',1.5,'Color',C);
    
    % plot width polygon
    [plat,plon] = xsection_poly([lat(1),lon(1)], [lat(2) lon(2)], zans.slicewidth_km/2,false,catalog.RefEllipsoid);
    xspoly=plot(plon,plat,'-.','Color',C);
    
    %label it: put labels offset and outside the great-circle line.
    hOffset=@(x,polarity) x+(1/75).*diff(xlim) * sign(lon(2)-lon(1)) * polarity;
    vOffset=@(x,polarity) x+(1/75).*diff(ylim) * sign(lat(2)-lat(1)) * polarity;
    slabel = text(hOffset(lon(1),-1),vOffset(lat(1),-1),zans.startlabel,'Color',C.*0.8, 'FontWeight','bold');
    elabel = text(hOffset(lon(2),1),vOffset(lat(2),1),zans.endlabel,'Color',C.*0.8, 'FontWeight','bold');

    % mask so that we can plot original quakes in original positions
    mask=polygon_filter(plon,plat,catalog.X,catalog.Y,'inside');
    
    c2=ZmapXsectionCatalog(catalog, [lat(1),lon(1)],[lat(2),lon(2)], zans.slicewidth_km);
  
    % PLOT X-SECTION IN NEW FIGURE
    f=create_cross_section_figure(zans, catalog, c2, mask);
    f.DeleteFcn = @(~,~)delete([xs_endpts,xs_line,slabel,elabel, xspoly]); % autodelete xsection when figure is closed
    ZG.newcat=c2;
end

function [lon, lat,h] = get_endpoints(ax,C)
    % returns lat, lon where each is [start,end] along with handle used to pick endpoints
    
    disp('click on start and end points for cross section');
    
    % pick first point
    [lon, lat] = ginput(1);
    set(gca,'NextPlot','add'); 
    h=plot(ax,lon,lat,'x','LineWidth',2,'MarkerSize',5,'Color',C);
    
    % pick second point
    [lon(2), lat(2)] = ginput(1);
    h.XData=lon; 
    h.YData=lat;
end

function f=create_cross_section_figure(zans,catalog, c2, mask)
        f=figure('Name',['cross-section ' zans.startlabel '-' zans.endlabel],...
            'Position',[40 60 1000 700]);
    disp('in create figure...');
    % plot events
    ax=subplot(3,3,9);
    plot3_events(ax, c2, catalog, mask);
    plot_events_along_strike(subplot(3,3,[1 5]),c2,zans)
    
    plot_events_along_strike_hist(subplot(3,3,[7 8]),zans, c2.dist_along_strike_km);
    plot_depth_profile(subplot(3,3,[3 6]), c2.Depth);
    create_my_menu(c2)
end

function plot_events_along_strike(ax,c2,zans)
    scatter(ax, c2.dist_along_strike_km, c2.Depth,mag2dotsize(c2.Magnitude),years(c2.Date-min(c2.Date)));
    ax.YDir='reverse';
    ax.XLim=[0 c2.curvelength_km];
    ax.XTickLabel{1}=zans.startlabel;
    if ax.XTick(end) ~= c2.curvelength_km
        ax.XTick(end+1)=c2.curvelength_km;
        ax.XTickLabel{end+1}=zans.endlabel;
    else
        ax.XTickLabel{end}=zans.endlabel;
    end
        
        
    grid(ax,'on');
    xlabel('Distance along strike [km]');
    ylabel('Depth');
    title(sprintf('Profile: %s to %s',zans.startlabel,zans.endlabel));
end

function plot3_events(ax,c2, catalog, mask, featurelist)
    % create a 3-d plot of this cross section, with overlaid map
    
    % plot relevant events (at depth)
    scatter3(ax,c2.X,c2.Y,c2.Z,mag2dotsize(c2.Magnitude),c2.dist_along_strike_km,'+')
    
    set(gca,'NextPlot','add')
    % plot all events as gray on surface
    plot(ax,catalog.X,catalog.Y,'.','Color',[.75 .75 .75],'MarkerSize',1);
    scatter3(catalog.X(mask),catalog.Y(mask),c2.Z,3,c2.displacement_km)
    ax.ZDir='reverse'; % Depths are + down
    
    
    % add features
    if ~exist('featurelist','var')
        featurelist={'coastline','borders','faults','lakes'};
    end
    ZG=ZmapGlobal.Data;
    for n=1:numel(featurelist)
        copyobj(ZG.features(featurelist{n}),ax);
    end
    set(gca,'NextPlot','replace')
end

function h=plot_events_along_strike_hist(ax, zans, gcDist)
    h=histogram(ax,gcDist);
    h.Parent.XTickLabel{1}=zans.startlabel;
    h.Parent.XTickLabel{end}=zans.endlabel;
    ylabel('# events');
    xlabel('Distance along strike (km)');
end

function plot_depth_profile(ax,depths)
    subplot(3,3,[3 6])
    histogram(depths,'Orientation','horizontal');
    set(gca, 'YDir','reverse')
    xlabel('# events');
    ylabel('Distance Depth Profile (km)');
end



function create_my_menu(c2)
        add_menu_divider();
        opts = uimenu('Label','Select');
        %uimenu(opts,'Label','Select EQ inside Polygon ',MenuSelectedField(),@cb_select_eq_inside_poly);
        %uimenu(opts,'Label','Refresh ',MenuSelectedField(),@cb_refresh2);
        
        opts = uimenu('Label','Ztools');
        
        
        uimenu(opts,'Label', 'differential b '       , MenuSelectedField(), @cb_diff_b);
        uimenu(opts,'Label','Fractal Dimension'      , MenuSelectedField(), @(~,~)Dcross());
        uimenu(opts,'Label','Mean Depth'             , MenuSelectedField(), @(~,~)cb_meandepth(c2));
        uimenu(opts,'Label','z-value grid'           , MenuSelectedField(), @(~,~)magrcros());
        uimenu(opts,'Label','b and Mc grid '         , MenuSelectedField(), @(~,~)bcross('in'));
        uimenu(opts,'Label','Prob. forecast test'    , MenuSelectedField(), @cb_probforecast_test);
        uimenu(opts,'Label','beCubed'                , MenuSelectedField(), @cb_becubed);
        uimenu(opts,'Label','b diff (bootstrap)'     , MenuSelectedField(), @cb_b_diff_boot);
        uimenu(opts,'Label','Stress Variance'        , MenuSelectedField(), @(~,~)cross_stress());
        uimenu(opts,'Label','Time Plot '             , MenuSelectedField(), @(~,~)timcplo(c2));
        uimenu(opts,'Label',' X + topo '             , MenuSelectedField(), @(~,~)xsectopo());
        uimenu(opts,'Label','Vert. Exaggeration'     , MenuSelectedField(), @(~,~)vert_exaggeration());
        uimenu(opts,'Label','Rate change grid'       , MenuSelectedField(), @(~,~)rc_cross_a2());
        uimenu(opts,'Label','Omori parameter grid'   , MenuSelectedField(), @(~,~)calc_Omoricross()); % formerly pcross
        
    end
    
    %% callback functions
    
    function cb_select_eq_inside_poly(mysrc,myevt)
        h1 = gca;
        stri = 'Polygon';
        selectp;
    end
    
    
    function cb_diff_b(~,~)
        h1=gca;
        bcrossVt2();
    end
    
    function cb_meandepth(mycat)
        meandepx(mycat, mycat.dist_along_strike_km);
    end
   
    function rContainer = update_container()
        ZG=ZmapGlobal.Data;
        rContainer.fXSWidth = ZG.xsec_defaults.WidthKm;
        rContainer.Lon1 = lon1;
        rContainer.Lat1 = lat1;
        rContainer.Lon2 = lon2;
        rContainer.Lat2 = lat2;
    end
        
    function cb_probforecast_test(~,~)
        pt_start(newa, xsec_fig(), 0, update_container(), name);
    end
    
    function cb_becubed(~,~)
        bc_start(newa, xsec_fig(), 0, update_container());
    end
    
    function cb_b_diff_boot(mysrc,myevt)
        st_start(newa, xsec_fig(), 0, update_container());
    end
    
    function cb_refresh(~,~)
        ZG=ZmapGlobal.Data;
        [xsecx xsecy,  inde] =mysect(tmp1,tmp2,ZG.primeCatalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
    end
    
    function cb_refresh2(~,~)
        delete(uic2);
        delete(findobj(mapl,'Type','axes'));
        nlammap2;
    end
