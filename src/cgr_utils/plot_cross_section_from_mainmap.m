function [c2, gcDist, zans] = plot_cross_section_from_mainmap
    %PLOT_CROSS_SECTION_FROM_MAINMAP create a cross-section from the map.
    %  [CatalogInCrossSection, distanceAlongStrike, optionsUsed] = PLOT_CROSS_SECTION_FROM_MAINMAP
    %
    % you can choose section width, start & end labels, and color.
    %
    % plots cross-section (great-circle curve) on map, along with boundary for selected events.
    % brings up new figure containing cross-section, with selected events plotted with depth, 
    % and histograms of events along sgtrike and with depth
    
    ZG=ZmapGlobal.Data;
    catalog=ZG.primeCatalog;
    
    % dialog box to choose cross-section
    zdlg=ZmapDialog([]);
    zdlg.AddBasicEdit('slicewidth_km','Width of slice [km]',20,'distance from slice for which to select events. 1/2 distance in either direction');
    zdlg.AddBasicEdit('startlabel','start label','A','start label for map');
    zdlg.AddBasicEdit('endlabel','end label','A''','start label for map');
    zdlg.AddBasicCheckbox('choosecolor','choose cross-section color [red]', false,{},...
                    'When checked, a color selection dialog will allow you to choose a different cross-section color');
    zdlg.AddBasicPopup('chooser','Choose Points',{'choose start and end with mouse'},1,'no choice');
    zans=zdlg.Create('slicer');
    C = [1 0 0]; % color for cross-section
    if zans.choosecolor
        C=uisetcolor(C,['Color for ' zans.startlabel '-' zans.endlabel]);
    end
    
    [lon, lat, xs_endpts] = get_endpoints(gca,C);
    
    % get waypoints along the great-circle curve
    [curvelats,curvelons]=gcwaypts(lat(1),lon(1),lat(2),lon(2),100);
    
    % plot great-circle path
    xs_line=plot(curvelons,curvelats,'--','linewidth',1.5,'Color',C);
    
    % plot width polygon
    [plat,plon] = xsection_poly([lat(1),lon(1)], [lat(2) lon(2)], zans.slicewidth_km/2);
    xspoly=plot(plon,plat,'-.','Color',C);
    
    %label it: put labels offset and outside the great-circle line.
    hOffset=@(x,polarity) x+(1/75).*diff(xlim) * sign(lon(2)-lon(1)) * polarity;
    vOffset=@(x,polarity) x+(1/75).*diff(ylim) * sign(lat(2)-lat(1)) * polarity;
    slabel = text(hOffset(lon(1),-1),vOffset(lat(1),-1),zans.startlabel,'Color',C.*0.8, 'fontweight','bold');
    elabel = text(hOffset(lon(2),1),vOffset(lat(2),1),zans.endlabel,'Color',C.*0.8, 'fontweight','bold');

    [c2,mindist,mask,gcDist]=project_on_gcpath([lat(1),lon(1)],[lat(2),lon(2)],catalog,zans.slicewidth_km/2,0.1);
    
    % PLOT X-SECTION IN NEW FIGURE
    f=create_cross_section_figure(zans,catalog, c2,mindist,mask,gcDist);
    f.DeleteFcn = @(~,~)delete([xs_endpts,xs_line,slabel,elabel, xspoly]); % autodelete xsection when figure is closed
end

function [lon, lat,h] = get_endpoints(ax,C)
    % returns lat, lon where each is [start,end] along with handle used to pick endpoints
    
    disp('click on start and end points for cross section');
    
    % pick first point
    [lon, lat] = ginput(1);
    hold on; 
    h=plot(ax,lon,lat,'x','linewidth',2,'MarkerSize',5,'Color',C);
    
    % pick second point
    [lon(2), lat(2)] = ginput(1);
    h.XData=lon; 
    h.YData=lat;
end

function f=create_cross_section_figure(zans,catalog, c2,mindist,mask,gcDist)
        f=figure('Name',['cross-section ' zans.startlabel '-' zans.endlabel]);
    disp('in create figure...');
    % plot events
    ax=subplot(3,3,[1 5]);
    plot3_events(ax, c2, catalog, mindist,mask);
    plot_events_along_strike(subplot(3,3,[7 8]),zans,gcDist);
    plot_depth_profile(subplot(3,3,[3 6]), c2.Depth);
end

function plot3_events(ax,c2, catalog,mindist, mask,featurelist)
    % create a 3-d plot of this cross section, with overlaid map
    
    % plot relevant events (at depth)
    scatter3(ax,c2.Longitude,c2.Latitude,c2.Depth,(c2.Magnitude+3).^2,mindist,'+')
    
    hold on
    % plot all events as gray on surface
    plot(ax,catalog.Longitude,catalog.Latitude,'.','Color',[.75 .75 .75],'MarkerSize',1);
    scatter3(catalog.Longitude(mask),catalog.Latitude(mask),c2.Depth,3,mindist)
    ax.ZDir='reverse'; % Depths are + down
    
    
    % add features
    if ~exist('featurelist','var')
        featurelist={'coastline','borders','faults','lakes'};
    end
    ZG=ZmapGlobal.Data;
    for n=1:numel(featurelist)
        copyobj(ZG.features(featurelist{n}),ax);
    end
    hold off
end

function h=plot_events_along_strike(ax, zans, gcDist)
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
