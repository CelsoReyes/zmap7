function cicros(opt)
    %   This subroutine "circle"  selects the Ni closest earthquakes
    %   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
    %   Operates on "primeCatalog".
    %
    % axis: h1
    % plots to: plos1 as xk
    % inCatalog: a
    % outCatalog: newt2, newcat, newa, newa2
    % mouse controlled
    % closest events OR radius
    % calls: bdiff
    %
    %  Input Ni:
    %
    persistent ic
    
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    
    if opt==0 && ~isempty(ic)
        opt=ic;
    end
    
    axes(h1)
    
    titStr ='Selecting EQ in Circles                         ';
    messtext= ...
        ['                                                '
        '  Please use the LEFT mouse button              '
        ' to select the center point.                    '
        ' The "ni" events nearest to this point          '
        ' will be selected and displayed in the map.     '];
    
    ZmapMessageCenter.set_message(titStr,messtext);
    
    % Input center of circle with mouse
    %
    [xa0,ya0]  = ginput(1);
    
    stri1 = [ 'Circle: lon = ' num2str(xa0) '; lat= ' num2str(ya0)];
    stri = stri1;
    pause(0.1)
    %  calculate distance for each earthquake from center point
    %  and sort by distance
    %
    l = sqrt(((xsecx' - xa0)).^2 + ((xsecy + ya0)).^2) ;
    [s,is] = sort(l);
    ZG.newt2 = newa(is(:,1),:) ;
    
    switch(ic)
        case 1 % select  N clostest events
            
            l =  sort(l);
            messtext = ['Radius of selected Circle:' num2str(l(ni))  ' km' ];
            disp(messtext)
            ZmapMessageCenter.set_message('Message',messtext)
            %
            % take first ni and sort by time
            %
            ZG.newt2 = ZG.newt2(1:ni,:);
            ZG.newt2.sort('Date');
            %
            % plot Ni clostest events on map as 'x':
            
            hold on
            [na,ma] = size(ZG.newt2);
            plot(ZG.newt2(:,ma),-ZG.newt2.Depth,'xk','Tag','plos1');
            set(gcf,'Pointer','arrow')
            %
            % plot circle containing events as circle
            x = -pi-0.1:0.1:pi;
            plot(xa0+sin(x)*l(ni), ya0+cos(x)*l(ni),'w')
            l(ni)
            
            %
            ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
            
            % Call program "timeplot to plot cumulative number
            %
            clear l s is
            bdiff(ZG.newt2)
            
        case 2 % select  events within ra
            
            l =  sort(l);
            ll = l <=ra;
            messtext = ['Number of events in Circle :' num2str(sum(ll)) ];
            disp(messtext)
            ZmapMessageCenter.set_message('Message',messtext)
            %
            % take first ni and sort by time
            %
            ZG.newt2 = ZG.newt2.subset(ll);
            ZG.newt2.sort('Date');
            %
            % plot Ni clostest events on map as 'x':
            
            hold on
            [na,ma] = size(ZG.newt2);
            plot(ZG.newt2(:,ma),-ZG.newt2.Depth,'xk','Tag','plos1');
            set(gcf,'Pointer','arrow')
            %
            % plot circle containing events as circle
            x = -pi-0.1:0.1:pi;
            plot(xa0+sin(x)*ra, ya0+cos(x)*ra,'w')
            l(ni)
            
            %
            ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
            
            % Call program "timeplot to plot cumulative number
            %
            clear l s is
            bdiff(ZG.newt2)
            
        case 3 % select  events within ra
            
            ax = findobj('Tag','mainmap_ax');
            [x,y, mouse_points_overlay] = select_polygon(ax);
            plot(x,y,'b-');
            YI = -newa(:,7);          % this substitution just to make equation below simple
            XI = newa(:,length(newa(1,:)));
            ll = polygon_filter(x,y, XI, YI, 'inside');
            
            %plot the selected eqs and mag freq curve
            newa2 = newa.subset(ll);
            ZG.newt2 = newa2;
            ZG.newcat = newa.subset(ll);
            pl = plot(newa2(:,length(newa2(1,:))),-newa2(:,7),'xk');
            set(pl,'MarkerSize',5,'LineWidth',1)
            bdiff(newa2)
        otherwise
            error('no option specified. 1: N closest events within radius, 2: radius')
    end
    ic=opt;
end

