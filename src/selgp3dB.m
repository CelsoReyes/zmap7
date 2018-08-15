function [t5, xvect, yvect, zvect] = selgp3dB(dx, dy, dz, z1, z2) 
    
    % TODO replace with ZmapGrid and depth 
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    ok_cancel=questdlg('Please selelct a polygon on the map', ...
        '3D grid selection', ...
        'OK','Cancel');
    if isempty(ok_cancel) || ok_cancel == "Cancel"
        % calculate based on map outline?
        return
    end
    mapfig=findobj(0,'Tag','seismicity_map');
    if isempty(mapfig)
        ZmapMessageCenter.set_error('Unable to find main map figure','Unable to find main map figure');
        return
    end
    figure(mapfig);
    
    set(gca,'NextPlot','add')
    ax=findobj(gcf,'Tag','mainmap_ax');
    [x,y, mouse_points_overlay] = select_polygon(ax);
    
    
    plos2 = plot(x,y,'b-');        % plot outline
    sum3 = 0.;
    pause(0.3)
    
    %create a rectangular grid
    xvect= min(x):dx:max(x);
    yvect= min(y):dy:max(y);
    zvect= z2:dz:z1;
    nGridElements= length(xvect) * length(yvect);
    tmpgri=zeros(nGridElements,2);
    tmpgri2=zeros(nGridElements,2);
    
    n=0;
    for i=1:length(xvect)
        for j=1:length(yvect)
            n=n+1;
            tmpgri(n,:)=[xvect(i) yvect(j)];
            tmpgri2(n,:) = [i j ];
        end
    end
    
    %extract all gridpoints in chosen polygon
    XI=tmpgri(:,1);
    YI=tmpgri(:,2);
    
    ll = polygon_filter(x,y, XI, YI, 'inside');
    %grid points in polygon
    newgri=tmpgri(ll,:);
    
    n2 = repmat(tmpgri,length(zvect),1);
    k = repmat(zvect,length(tmpgri),1);
    k = reshape(k,length(k)*length(zvect),1);
    k2 = repmat(ll,length(zvect),1);
    t3 = [n2 k k2];
    
    n3 = repmat(tmpgri2,length(zvect),1);
    k = repmat((1:1:length(zvect)),length(tmpgri),1);
    k = reshape(k,length(k)*length(zvect),1);
    t4 = [t3 n3 k];
    
    l = t4(:,4) == 1;
    t5 = t4(l,:);
    
    % plot the grid points
    figure(map);
    pl = plot(newgri(:,1),newgri(:,2),'+k');
    set(pl,'MarkerSize',8,'LineWidth',1)
    drawnow
    
end
