
[existFlag,figNumber]=figure_exists('Topographic Map (Mapping Toolbox)',1);
if existFlag == 0;  bc = 'new' ; end
% if existFlag == 1;  bc = ' ' ; end
% if isnan(bc);bc='new';end;

% check if mapping toolbox and topo map exists
if ~license('test','map_toolbox')
    errordlg('It seems like you do not have the mapping toolbox installed - plotting topography will not work without it, sorry');
    return
end
% bc='new'
% eqontop=0
% fontop=0
% montop=0
% sontop=0
tmap(isnan(tmap)) = -1; %Replace the NaNs in the ocean with -1 to color them blue.



switch (bc)

    case 'new'

        top = figure_w_normalized_uicontrolunits( ...
            'Name','Topographic Map (Mapping Toolbox)',...
            'NumberTitle','off', ...
            'Visible','on', ...
            'NextPlot','add', ...
            'Position',[ fipo(1)+20 fipo(2)-20 1.5*winx 1.5*winy],...
            'Color',[1 1 1]);

        shading flat
        mapax1 = axesm('MapProjection','eqdcylin')
        [latlim,lonlim] = limitm(tmap,tmapleg);
        meshm(tmap,tmapleg,size(tmap),tmap);demcmap(tmap)

        if min(min(tmap)) > 0
            demcmap(tmap,100,[0 0.3 1],[]);
            daspectm('m',15);
        else
            demcmap(tmap)
            daspectm('m',15);
        end

        camlight(-80,0); lighting phong; material([.8 1 0])
        h5 = colorbar;
        set(h5,'Position', [0.9 0.3 0.015 .3])
        set(h5,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
            'FontWeight','normal','LineWidth',1.,...
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
            'Position', [0.02 0.03 0.23 .04],'Units','Normalized','Callback', 'scaleruler off;axesmui;bc='' '';overmaptb_w');

        labelList=[' EQ (dot) | EQ (o) | EQ (dot) on top (slow) | EQ (o) on top (slow)|No EQ '];
        labelPos=[ .3 0.03 0.16 0.04];
        ha2=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',labelList,...
            'Callback','bc = ''eq''; overmaptb_w');

        labelList=[' Faults | Faults on top (slow) | No Faults'];
        labelPos=[ .5 0.03 0.16 0.04];
        ha3=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',labelList,...
            'Callback','bc = ''fau''; overmaptb_w');

        labelList=[' Main  | No Main '];
        labelPos=[ .3 0.08 0.16 0.04];
        ha4=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',labelList,...
            'Callback','bc = ''mai''; overmaptb_w');

        labelList=[' Stations | No Stations '];
        labelPos=[ .5 0.08 0.16 0.04];
        ha5=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',labelList,...
            'Callback','bc = ''sta''; overmaptb_w');


        labelList=[' colormap (decmap) | colormap(gray)'];
        labelPos=[ .7 0.03 0.16 0.04];
        ha6=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','Normalized',...
            'Value',1,...
            'String',labelList,...
            'Callback','bc = ''cm''; overmaptb_w');


        ha7 = uicontrol('Style', 'pushbutton', 'String', ' darken',...
            'Position', [0.02 0.1 0.10 .03],'Units','Normalized','Callback', 'brighten (-0.1)');

        ha8= uicontrol('Style', 'pushbutton', 'String', ' brighten',...
            'Position', [0.02 0.15 0.10 .03],'Units','Normalized','Callback', 'brighten (0.1)');



    case 'eq'

        inp =get(ha2,'Value');

        if eqontop==0  &&  (inp==3 | inp==4)
            clear('depq')
            [lat,lon] = meshgrat(tmap,tmapleg);
            hw = waitbar(0,'Please wait...');
            for i=1:size(a,1), % computation here %
                waitbar(i/length(a))
                depq(i) = interp2(lon,lat,tmap,a(i,1),a(i,2));
            end
            close(hw)
            depq=depq'
            eqontop=1
        end

        %   if inp == 1 ; ploe = scatterm(a.Latitude,a.Longitude,8,'r','filled'); end
        if inp == 1
            ploe=plotm(a.Latitude,a.Longitude,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',2,...
                'MarkerFaceColor','w','MarkerEdgeColor','r')
            zdatam(handlem('allline'),max(max(tmap)))

        elseif inp == 2
            ploe=plotm(a.Latitude,a.Longitude,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',3,...
                'MarkerFaceColor','w','MarkerEdgeColor','k')
            zdatam(handlem('allline'),max(max(tmap)))

        elseif inp == 3
            ploe=plot3m(a.Latitude,a.Longitude,depq+25,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',2,...
                'MarkerFaceColor','w','MarkerEdgeColor','r')

        elseif inp == 4
            ploe=plot3m(a.Latitude,a.Longitude,depq+25,'ro');
            set(ploe,'LineWidth',0.1,'MarkerSize',3,...
                'MarkerFaceColor','w','MarkerEdgeColor','k')
        end

        if inp == 5 ; delete(ploe);  end

    case 'fau'
        inp =get(ha3,'Value');
        if fontop==0  &&  inp==2
            clear('depf')
            [lat,lon] = meshgrat(tmap,tmapleg);
            hw = waitbar(0,'Please wait...');
            for i=1:size(faults,1), % computation here %
                waitbar(i/length(faults))
                depf(i) = interp2(lon,lat,tmap,faults(i,1),faults(i,2));
            end
            close(hw)
            depf=depf'
            fontop=1
        end

        if inp == 1 ; plof = plotm(faults(:,2),faults(:,1),'m','Linewidth',2)
            zdatam(handlem('allline'),max(max(tmap)));end
        if inp == 2 ; plof = plot3m(faults(:,2),faults(:,1),depf+25,'m','Linewidth',2);end
        if inp == 3; delete(plof) ; end

    case 'mai'
        inp =get(ha4,'Value');
        if montop==0
            clear('depm')
            [lat,lon] = meshgrat(tmap,tmapleg);
            hw = waitbar(0,'Please wait...');
            for i=1:size(maepi,1), % computation here %
                waitbar(i/length(maepi))
                depm(i) = interp2(lon,lat,tmap,maepi(i,1),maepi(i,2));
            end
            close(hw)
            depm=depm'
            montop=1
        end

        if inp == 1 
            plom = plot3m(maepi(:,2),maepi(:,1),depm+25,'hm');
            set(plom,'LineWidth',1.5,'MarkerSize',12,...
                'MarkerFaceColor','y','MarkerEdgeColor','k')
        end
        if inp == 2; delete(plom); end


    case 'sta'
        inp =get(ha5,'Value');
        if inp == 1 ; h1 = h1topo; plotstations ; end
        if inp == 2 ;  ; end

    case 'cm'
        inp =get(ha6,'Value');
        if inp == 1 
            if min(min(tmap)) > 0
                demcmap(tmap,100,[0 0.3 1],[]);
                daspectm('m',15);
            else
                demcmap(tmap)
                daspectm('m',15);
            end
        elseif inp == 2 
            demcmap(tmap,64,[0 0 0],[.3 .3 .3; .8 .8 .8])
            daspectm('m',15);
        end

end

scaleruler off
scaleruler on
[xlo,ylo] = mfwdtran(s4_south-tilat/3,s2_west);
setm(handlem('scaleruler'),'XLoc',xlo,'YLoc',ylo,'RulerStyle','patches','FontSize',10)
