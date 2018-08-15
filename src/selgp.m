function [fullGrid,gridInPolygon, polyMask]=selgp(gridDetails) 
    % [fullGrid, gridInPolygon, polyMask]=selgp(gridDetails)
    % 
    % fullGrid: grid that covers polygon NxM
    % gridInPolygon: reduced grid, including only points inside polygon
    % polyMask:  gridInPolygon=fullGrid(polyMask,:);
    %
    % was [tmpri, newgri, ll]=selgrp
    %
    % gridDetails:
    % 
    
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    ax=findobj(gcf,'Tag','mainmap_ax');
    h=findobj(gcf,'Tag','mainmap_ax');
    if gridDetails.GridEntireArea
        wl=axis;
        x=[wl(1);wl(2);wl(2);wl(1);wl(1)];
        y=[wl(3);wl(3);wl(4);wl(4);wl(3)];
    else
        [x,y, ~] = select_polygon(ax);
    end
    ax.NextPlot='add';
    % figure(map);
    
    plos2 = plot(x,y,'b-');        % plot outline
    sum3 = 0.;
    pause(0.3)
    
    %create a rectangular grid
    xvect=[min(x):gridDetails.dx:max(x)];
    yvect=[min(y):gridDetails.dy:max(y)];
    gx = xvect;
    gy= yvect;
    tmpgri=zeros((length(xvect)*length(yvect)),2);
    n=0;
    for i=1:length(xvect)
        for j=1:length(yvect)
            n=n+1;
            tmpgri(n,:)=[xvect(i) yvect(j)];
        end
    end
    %extract all gridpoints in chosen polygon
    XI=tmpgri(:,1);
    YI=tmpgri(:,2);
    
    ll = polygon_filter(x,y, XI, YI, 'inside');
    %grid points in polygon
    newgri=tmpgri(ll,:);
    
    % plot the grid points
    pl = plot(ax,newgri(:,1),newgri(:,2),'+k');
    set(pl,'MarkerSize',8,'LineWidth',1)
    drawnow
    
    gridInPolygon=newgri;
    fullGrid=tmpgri;
    polyMask=ll;
end
