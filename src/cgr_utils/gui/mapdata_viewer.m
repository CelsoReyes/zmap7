function mapdata_viewer(res,resfig)
    % MAPDATA_VIEWER (PROTOTYPE) explore map data
    % interactive data map, based on results in the table from a ZmapFunction
    % put mouse in DataMap, and choose a symbol key (such as o+v^shp*. )
    %
    % closest grid datapoint is found.
    % - Circle is drawn, showing the radius for which events were used
    % in the calculation
    % - Bvalue is (WILL BE) plotted
    % - Cum Rate is (WILL BE) plotted
    %
    %  keep choosing symbols. If symbol isn't already chosen, it is added to the plot. this way several
    %  poinds can be simultaneously compared
    %  if the symbol already exists, the plot will move.
    %
    %  pressing ESCAPE stops the selection loop
    %
    % still in prototype mode
    %
    % Maybe TO add:
    %
    % - polar plots: show # events in radius
    % - radius plots: show # events as functiuon of radius
    % - 3d depth plots of selection
    %
    % RES is the results table
    % AX is 
    ZG=ZmapGlobal.Data;
    tb = res.values; % perhaps get sample data from running an Mc, a- and b- calcualtion from the main map
    
    keyBindings.delete = 8; %backspace
    %keyBindings.delete = 127; %del
    keyBindings.quit = 27; %escape
    
    bvalBinEdges=-1.15:.1:8.05;
    binCenters=-1.1:.1:8;
    
    try
        if isvalid(f),close(f),end
    end
    
    f=figure('Name','Data View');
    f.Units='pixels';
    f.Position = [60 60 1200 700];
    f.Resize='off';
    %f.KeyPressFcn=@(src,ev)disp(ev);
    
    
    if exist('resfig','var')
        % use existing figure as the base of our axes
        mapax=copyobj(findobj(resfig,'Type','axes'),f);
        set(findobj(mapax,'Tag','pointgrid'),'visible','off');
        mapax.Units='pixels';
        mapax.Position=[50 150 700 500];
        mapax.Tag = 'dvMap';
        grid on
    else
        % main axes, with map-view of data
        mapax=axes(f,'units','pixels','Position',[50 150 700 500]);
        mapax.Tag = 'dvMap';
        grid on
        %f.KeyReleaseFcn = @(src,ev)disp(mapax.CurrentPoint);
        title(mapax, 'Data Map');
        xlabel(mapax,'Longitude');
        ylabel(mapax,'Latitude');
        mapax.YLim=[45.5 48];
        mapax.XLim=[5.75 8.75];
    end
    colorbar(mapax);
    
    
    
    % b-value axes, showing b-value rates
    bvalax=axes(f,'units','pixels','Position',[850 375 300 275]);
    bvalax.Tag = 'dvBval';
    bvalax.YScale='log';
    bvalax.YLim=[0 10000];
    bvalax.XLim=[-2 7];
    title(bvalax,'B-Value')
    xlabel('Magnitude')
    ylabel('# Events')
    
    % cumulative event axes
    rateax=axes(f,'units','pixels','Position',[850 50 300 275]);
    rateax.Tag = 'dvCumrate';
    title(rateax,'Cumulative Rate');
    xlabel('Time')
    ylabel('Cumulative Events')
    
    
    %%
    axes(mapax);
    set(f,'Pointer','cross')
    pause(.01)
    
    
    remapper=[...
        'abcdefghijk';...
        'ox+v^sph.*x'];
    
    toSymb=@(x) remapper(2,x==remapper(1,:));
    toField=@(x) remapper(1,x==remapper(2,:));
    isSymb=@(x)any(x==remapper(2,:));
    isField=@(x)any(x==remapper(1,:));
    
    selections=struct();
    disp('entering loop')
    curChar='o';
    field=toField(curChar);
    
    
    % Instructions
    uicontrol('Style','text','Position',[10 45 200 20],...
        'String','LC: add/Move Pt, CC:Quit, RC:delete Pt',...
        'HorizontalAlignment','left');
    htmp=uicontrol('Style','text','Position',[10 25 200 20],'String','Change marker by pressing one of:',...
        'HorizontalAlignment','left');
    uicontrol('Style','text','Position',[(htmp.Position(1)+htmp.Extent(3)+5) 25 200 20],'String','os+.*xphv^',...
        'HorizontalAlignment','left', 'FontWeight','bold','FontName','fixedwidth');
    htmp=uicontrol('Style','text','Position',[10 5 105 20],...
        'String','Active marker: ', 'FontWeight','bold',...
        'HorizontalAlignment','left');
    amh= uicontrol('Style','text','Position',[(htmp.Position(1)+htmp.Extent(3)+5) 6 20 20],...
        'String', curChar, 'FontWeight','bold',...
        'HorizontalAlignment','left','FontName','fixedwidth');
    amh.FontSize=amh.FontSize * 1.2;
    
    
    while true % ESC
        keydown = waitforbuttonpress;
        prevChar=curChar;
        if (keydown == 0)
            axx = mapax.CurrentPoint(1,1);
            axy = mapax.CurrentPoint(1,2);
            %[~,i]=min( distance([tb.y,tb.x], [axy, axx]) );% find closest point
            % which button?
            disp(['Selection Type: ', f.SelectionType])
            switch f.SelectionType
                case 'normal'
                    disp('MOUSE:left button')
                    %curChar=curChar;
                case 'alt'
                    disp('MOUSE:right button')
                    curChar=keyBindings.delete;
                case 'extend'
                    disp('MOUSE:center button');
                    % curChar=keyBindings.quit;
                otherwise
                    disp(['MOUSE:other [' f.SelectionType ']' ]);
                    continue
            end
            
            % axes CurrentPoint is updated
        else
            curChar = f.CurrentCharacter;
            
            if isSymb(curChar)
                field=toField(curChar);
                amh.String=curChar;
            end
            [axx, axy] = screenpix2axes(mapax,[],[]);
            % disp(f.SelectionType)
        end
        
        if double(curChar) == keyBindings.quit
            disp('done')
            break
        end
        
        [~,i]=min( distance([tb.y,tb.x], [axy, axx]) );% find closest point
        disp(tb(i,:))
        
        % if BACKSPACE is pressed, then delete closest selection
        if curChar == keyBindings.delete
            % delete closest selection
            disp('deleting closest selection');
            fn=fieldnames(selections);
            for n=numel(fn):-1:1
                myfn=fn{n};
                if selections.(fn{n}).residx == i
                    fprintf('Found %s is idx %d\n',myfn, n);
                    delete(selections.(myfn).m1)
                    delete(selections.(myfn).m2)
                    delete(selections.(myfn).m3)
                    delete(selections.(myfn).cr1)
                    delete(selections.(myfn).bv1)
                    delete(selections.(myfn).bv3)
                    selections=rmfield(selections,myfn);
                end
            end
            curChar=prevChar;
            continue
        end
        
        disp(['[' curChar '] : ' num2str(double(curChar))]);
        % axes CurrentPoint is NOT updated.
        
        %% modify map
        
        [lat,lon]=reckon(tb.y(i),tb.x(i),km2deg(tb.Radius_km(i)),(0:1:360)');
        
        createNewField=~isfield(selections,field);
        selections.(field).residx = i;
        if createNewField
            disp('creating new field')
            % create a new circle plot
            hold(mapax,'on')
            
            % plot click location
            selections.(field).m1=plot(mapax,[axx ; tb.x(i)] , [axy;tb.y(i)],'--', 'Marker',curChar,'Color',[.75 .75 .75],'linewidth',1.5);
            
            % plot marker in actual location
            selections.(field).m2=plot(mapax,tb.x(i),tb.y(i),curChar,'MarkerSize',12,'MarkerFaceColor','k','linewidth',2);
            
            % plot selected event circle
            selections.(field).m3=plot(mapax, lon, lat, '-.','color',[.75 .75 .75],'linewidth',2);
            hold(mapax, 'off')
        else
            disp('modifying field')
            % move the circle plot
            selections.(field).m1.XData=[axx ; tb.x(i)];
            selections.(field).m1.YData=[axy;tb.y(i)];
            
            selections.(field).m2.XData=tb.x(i);
            selections.(field).m2.YData=tb.y(i);
            
            selections.(field).m3.XData=lon;
            selections.(field).m3.YData=lat;
        end
        thiscolor = selections.(field).m2.Color;
        amh.ForegroundColor=thiscolor;
        % plot circle of radius showing events
        
        %% modify cum rate
        theseEvents = ZG.(res.InCatalogName{1}).selectCircle(res.EventSelector,tb.x(i),tb.y(i));
        
        if createNewField
            hold(rateax,'on');
            selections.(field).cr1=plot(rateax, ...
                theseEvents.Date, 1:theseEvents.Count,...
                'marker',curChar);
            hold(rateax,'off');
            rateax.XLimMode='auto';
            rateax.YLimMode='auto';
        else
            selections.(field).cr1.XData=theseEvents.Date;
            selections.(field).cr1.YData=1:theseEvents.Count;
        end
        selections.(field).cr1.Color=thiscolor;
        
        
        %% modify b-val
        cs=cumsum(histcounts(theseEvents.Magnitude,bvalBinEdges),'reverse');
        Y_mc = cs(binCenters==tb.Mc_value(i));
        Y_maxmag = cs(binCenters==tb.max_mag(i));
        minmaxmag = [tb.Mc_value(i) ; tb.max_mag(i)];
        b_line = 10.^(tb.a_value(i) - tb.b_value(i) .* minmaxmag);
        if createNewField
            hold(bvalax,'on');
            % plot cumulative magnitudes
            selections.(field).bv1=semilogy(bvalax,binCenters,cs,curChar,'Color',thiscolor);
            
            %plot slope
            selections.(field).bv3=semilogy(bvalax, minmaxmag, b_line,...
                'Marker',curChar,...
                'Color', thiscolor,'MarkerFaceColor',thiscolor);
            
            hold(bvalax,'off');
            bvalax.XLim=[min(ZG.(res.InCatalogName{1}).Magnitude) max(ZG.(res.InCatalogName{1}).Magnitude)+.1];
            bvalax.YLim=[-inf inf];
        else
            selections.(field).bv1.YData=cs;  % X data remains the same, based on main catalog
            
            selections.(field).bv3.XData=minmaxmag; % [tb.Mc_value(i); tb.max_mag(i)];
            selections.(field).bv3.YData=b_line; % [Y_mc; Y_maxmag];
        end
        
        % keep colors synchronized
        selection.(field).bv1.Color=thiscolor;
        selection.(field).bv1.MarkerEdgeColor=thiscolor;
        selection.(field).bv3.Color=thiscolor;
        selection.(field).bv3.MarkerEdgeColor=thiscolor;
    end
    set(f,'Pointer','arrow');
end