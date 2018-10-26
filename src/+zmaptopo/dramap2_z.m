function dramap2_z() 
    % drap a colormap of variance, S1 orinetation onto topography
    % 2.11.2001 17:00
    % turned into function by Celso G Reyes 2017
    import zmaptopo.*
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    smenu=menu
    clear('menu')
    j = colormap;
    % check if mapping toolbox and topo map exists
    if ~license('test','map_toolbox')
        errordlg('It seems like you do not have the mapping toolbox installed - plotting topography will not work without it, sorry');
        return
    end
    
    if ~exist('tmap', 'var'); tmap = 0; end
    [xx, yy] = size(tmap);
    
    if xx*yy < 30
        ButtonName=questdlg('create a topomap ?', ...
            ' Question', ...
            'Yes','No','no');
        switch ButtonName
            case 'Yes'
                pltopo %probably pltopo not pltobo
            case 'No'
                errordlg('Please create a topomap first, using the options from the seismicty map window');
                return
        end % switch
    end
    
    
    
    selz = menu('Choose a projection',...
        'Albers Equal-Area Conic',...
        'Mercator Projection',...
        'Plate Carr�e Projection',...
        'Lambert Conformal Conic Projection',...
        'Robinson Projection')
    
    mapz=['eqaconic';... % Cylindrical
        'mercator';... % Cylindrical
        'pcarree ';... % Cylindrical
        'lambert ';... % Conic
        'robinson']    % Pseudocylindrical
    mapz
    mapz(selz,:)
    
    
    def = {'1','1','5',num2str(min(valueMap(:)),4),num2str(max(valueMap(:)),4) };
    
    tit ='Topo map input parameters';
    prompt={ 'Longitude label spacing in degrees ',...
        'Latitude label spacing in degrees ',...
        'Topo data-aspect (steepness) ',...
        ' Minimum datavalue (cmin)',...
        ' maximum datavalue cmap',...
        
        };
    
    ni2 = inputdlg(prompt,tit,1,def);
    
    l = ni2{1}; dlo= str2double(l);
    l = ni2{2}; dla= str2double(l);
    l = ni2{3}; dda= str2double(l);
    l = ni2{4}; mic= str2double(l);
    l = ni2{5}; mac= str2double(l);
    
    % use this for setting water levels to one color
    l = isnan(tmap);
    tmap(l) = 1;
    
    if min(tmap(:)) < 10
        ButtonName=questdlg('Set water to zero?', ...
            ' Question', ...
            'Yes','No','no');
        
        
        switch ButtonName
            case 'Yes'
                l= tmap< 0.1;
                tmap(l) = 0;
        end % switch
    end
    
    
    
    l = valueMap < mic;
    valueMap(l) = mic+0.1 ;
    l = valueMap > mac;
    valueMap(l) = mac;
    
    l = isnan(tmap);
    tmap(l) = 0;
    
    
    [lat,lon] = meshgrat(tmap,tmapleg);
    [X , Y]  = meshgrid(gx,gy);
    
    ren = interp2(X,Y,valueMap,lon,lat);
    
    
    mi = min(ren(:));
    l =  isnan(ren);
    ren(l) = mi-20;
    
    ll = tmap <= 1 & ren < mic;
    ren(ll) = nan;
    
    
    %start figure
    figure_w_normalized_uicontrolunits('pos',[50 100 800 600])
    mapz
    mapz(selz,:)
    set(gca,'NextPlot','add'); axis off
    axesm('MapProjection',mapz(selz,:),...
        'MapLatLimit',[s4 s3],'MapLonLimit',[s2 s1])
    
    
    
    meshm(ren,tmapleg,size(tmap),tmap);
    
    daspectm('m',dda);
    tightmap
    view([0 90])
    camlight; lighting phong
    set(gca,'projection','perspective');
    
    if ~isempty(coastline)
        pl = plotm(coastline(:,2),coastline(:,1),'k');
        set(pl,'LineWidth',0.5)
    end
    
    if ~isempty(ZG.maepi)
        pl = plotm(ZG.maepi.Latitude,ZG.maepi.Longitude,'hw');
        set(pl,'LineWidth',1,'MarkerSize',14,...
            'MarkerFaceColor','w','MarkerEdgeColor','k')
    end
    
    
    j = jet(64);
    j = [ [ 0.8 0.8 0.8  ] ; j  ];
    caxis([ mic*0.99 mac*1.01 ]);
    colormap(j); brighten(0.1);
    axis off;
    
    if ~exist('colback', 'var'); colback = 'w'; end
    
    setm(gca,'mlabellocation',dlo)
    setm(gca,'meridianlabel','on')
    setm(gca,'plabellocation',dla)
    setm(gca,'parallellabel','on')
    
    
    
    if colback == 'w'  % black background
        set(gcf,'color','k')
        setm(gca,'ffacecolor','k')
        setm(gca,'fedgecolor','w','flinewidth',3);
        
        % change the labels if needed
        setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')
        
        h5 = colorbar;
        set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
            'Fontweight','bold','FontSize',12);
        set(gcf,'Inverthardcopy','off');
        
    else % white background
        set(gcf,'color','w')
        %    setm(gca,'ffacecolor','w')
        setm(gca,'fedgecolor','k','flinewidth',3);
        
        % change the labels if needed
        setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',12,'Labelunits','dm')
        
        h5 = colorbar;
        set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
            'Fontweight','bold','FontSize',12);
        set(gcf,'Inverthardcopy','off');
        
    end
    return
    %%%%%%%%%%%%%%%%%%
    scaleruler
    setm(handlem('scaleruler1'),'XLoc',-0.0133,'YLoc',0.639)
    setm(handlem('scaler1er1'),'units','km')
    setm(handlem('scaleruler2'),'MajorTick',0:10:50,...
        'MinorTick',0:10:25,'TickDir','down',...
        'MajorTickLength',(4),...
        'MinorTickLength',(4))
    setm(handlem('scaleruler1'),'RulerStyle','ruler')
    setm(handlem('scaleruler2'),'RulerStyle','patches')
    
    refresh
end
