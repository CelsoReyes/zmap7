function overmaptb() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    top=findobj('Type','Figure','-and','Name','Topographic Map (Mapping Toolbox)');
    if isempty(top) || isnan(bc)
        bc = 'new' ; 
    end
    
    % check if mapping toolbox and topo map exists
    if ~has_mapping_toolbox()
        return
    end
    
    tmap(isnan(tmap)) = -1; %Replace the NaNs in the ocean with -1 to color them blue.
    
    top = figure_w_normalized_uicontrolunits( ...
        'Name','Topographic Map (Mapping Toolbox)',...
        'NumberTitle','off', ...
        'Visible','on', ...
        'NextPlot','add', ...
        'Position',[ ZG.fipo(1)+20 ZG.fipo(2)-20 1.5*winx 1.5*winy],...
        'Color',[1 1 1]);
    
    shading flat
    mapax1 = axesm('MapProjection','eqdcylin');
    [latlim,lonlim] = limitm(tmap,tmapleg);
    meshm(tmap,tmapleg,size(tmap),tmap);
    demcmap(tmap)
    
    if min(tmap(:)) > 0
        demcmap(tmap,100,[0 0.8 1],[]);
        daspectm('m',15);
    else
        demcmap(tmap)
        daspectm('m',15);
    end
    
    camlight(-80,0); lighting phong; material([.8 1 0])
    h5 = colorbar;
    set(h5,'Position', [0.9 0.3 0.015 .3])
    set(h5,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1,...
        'Box','on','TickDir','out')
    
    tilat=(abs(abs(latlim(1))-abs(latlim(2)))/4);
    tilon=(abs(abs(lonlim(1))-abs(lonlim(2)))/4);
    %tilat = 3;
    %tilon = 3
    
    setm(gca,'maplatlimit',latlim,'maplonlimit',lonlim,...
        'meridianlabel','on','parallellabel','on',...
        'plinelocation',tilat,'mlinelocation',tilon,...
        'glinestyle','-.',...
        'grid','off',...
        'plabellocation',tilat,'mlabellocation',tilon,...
        'LabelFormat','compass',...
        'flinewidth',3)
    
    showaxes('hide')
    
    ha1 = uicontrol('Style', 'pushbutton', 'String', ' Projection Control dialog box',...
        'Position', [0.02 0.03 0.23 .04],'Units','Normalized','Callback', 'scaleruler off;axesmui;bc='' '';overmaptb(bc)');
    
    labelList=[' EQ (dot) | EQ (o) | EQ (dot) on top (slow) | EQ (o) on top (slow)|No EQ '];
    labelPos=[ .3 0.03 0.16 0.04];
    ha2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','Normalized',...
        'Value',1,...
        'String',labelList,...
        'callback',@callbackfun_001);
    
    labelList=[' Faults | Faults on top (slow) | No Faults'];
    labelPos=[ .5 0.03 0.16 0.04];
    ha3=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','Normalized',...
        'Value',1,...
        'String',labelList,...
        'callback',@callbackfun_002);
    
    labelList=[' Main  | No Main '];
    labelPos=[ .3 0.08 0.16 0.04];
    ha4=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','Normalized',...
        'Value',1,...
        'String',labelList,...
        'callback',@callbackfun_003);
    
    labelList=[' Stations | No Stations '];
    labelPos=[ .5 0.08 0.16 0.04];
    ha5=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','Normalized',...
        'Value',1,...
        'String',labelList,...
        'callback',@callbackfun_004);
    
    
    labelList=[' colormap (decmap) | colormap(gray)'];
    labelPos=[ .7 0.03 0.16 0.04];
    ha6=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','Normalized',...
        'Value',1,...
        'String',labelList,...
        'callback',@callbackfun_005);
    
    
    ha7 = uicontrol('Style', 'pushbutton', 'String', ' darken',...
        'Position', [0.02 0.1 0.10 .03],'Units','Normalized','Callback', 'brighten (-0.1)');
    
    ha8= uicontrol('Style', 'pushbutton', 'String', ' brighten',...
        'Position', [0.02 0.15 0.10 .03],'Units','Normalized','Callback', 'brighten (0.1)');
    
    ha9= uicontrol('Style', 'pushbutton', 'String', ' Black/White',...
        'Position', [0.7 0.08 0.10 .03],'Units','Normalized','callback',@callbackfun_006);
    
    
    
    
    
    scaleruler off
    scaleruler on
    [xlo,ylo] = mfwdtran(s4-tilat/3,s2);
    setm(handlem('scaleruler'),'XLoc',xlo,'YLoc',ylo,'RulerStyle','patches','FontSize',7)
    
    %% callbacks
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        %case 'eq'
        inp =get(ha2,'Value');
        
        if eqontop==0  &&  (inp==3 || inp==4)
            clear('depq')
            [lat,lon] = meshgrat(tmap,tmapleg);
            depq=interp2(lon,lat,tmap,ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude);
            % depq=depq'
            eqontop=1
        end
        
        %   if inp == 1 ; ploe = scatterm(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,8,'r','filled'); end
        if inp == 1
            ploe=plotm(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,'wo');
            set(ploe,'LineWidth',0.1,'MarkerSize',2,...
                'MarkerFaceColor','none','MarkerEdgeColor','w')
            zdatam(handlem('allline'),max(tmap(:)))
            
        elseif inp == 2
            ploe=plotm(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',3,...
                'MarkerFaceColor','w','MarkerEdgeColor','k')
            zdatam(handlem('allline'),max(tmap(:)))
            
        elseif inp == 3
            ploe=plot3m(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,depq+25,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',2,...
                'MarkerFaceColor','w','MarkerEdgeColor','r')
            
        elseif inp == 4
            ploe=plot3m(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,depq+25,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',3,...
                'MarkerFaceColor','w','MarkerEdgeColor','k')
        end
        
        if inp == 5 ; delete(ploe);  end
        
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        % case 'fau'
        inp =get(ha3,'Value');
        if fontop==0  &&  inp==2
            [lat,lon] = meshgrat(tmap,tmapleg);
            depf = interp2(lon,lat,tmap,faults(:,1),faults(:,2));
            fontop=1
        end
        
        if inp == 1
            plof = plotm(faults(:,2),faults(:,1),'m','Linewidth',2)
            zdatam(handlem('allline'),max(tmap(:)));end
        if inp == 2 ; plof = plot3m(faults(:,2),faults(:,1),depf+25,'m','Linewidth',2);end
        if inp == 3; delete(plof) ; end
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        % case 'mai'
        inp =get(ha4,'Value');
        if montop==0
            clear('depm')
            [lat,lon] = meshgrat(tmap,tmapleg);
            depm = interp2(lon,lat,tmap,ZG.maepi.Longitude,ZG.maepi.Latitude);
            %depm=depm'
            montop=1
        end
        
        if inp == 1
            plom = plot3m(ZG.maepi.Latitude,ZG.maepi.Longitude,depm+25,'hm');
            set(plom,'LineWidth',1.5,'MarkerSize',12,...
                'MarkerFaceColor','y','MarkerEdgeColor','k')
        end
        if inp == 2; delete(plom); end
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        %    case 'sta'
        inp =get(ha5,'Value');
        if inp == 1
            h1 = h1topo
            plotstations
        end
        if inp == 2
            do_nothing();
        end
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        % case 'cm'
        inp =get(ha6,'Value');
        if inp == 1
            if min(tmap(:)) > 0
                demcmap(tmap,100,[0 0.8 1],[]);
                daspectm('m',15);
            else
                demcmap(tmap)
                daspectm('m',15);
            end
        elseif inp == 2
            demcmap(tmap,64,[ 1 1 1 ],[.3 .3 .3; .8 .8 .8])
            daspectm('m',15);
        end
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        bc = 'bw';
        overmaptb;
    end
    
end
