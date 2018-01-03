%function mapdata_viewer(res,)
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

    tb = res.values; % perhaps get sample data from running an Mc, a- and b- calcualtion from the main map
    
    
    try
        if isvalid(f),close(f),end
    end
    f=figure('Name','Data View');
    f.Units='pixels';
    f.Position = [60 60 1200 700];
    f.Resize='off';
    %f.KeyPressFcn=@(src,ev)disp(ev);
    
    
    % main axes, with map-view of data
    mapax=axes(f,'units','pixels','Position',[50 250 750 400]);
    mapax.Tag = 'dvMap';
    grid on
    %f.KeyReleaseFcn = @(src,ev)disp(mapax.CurrentPoint);
    title(mapax, 'Data Map');
    xlabel(mapax,'Longitude');
    ylabel(mapax,'Latitude');
    mapax.YLim=[45.5 48]
    mapax.XLim=[5.75 8.75]
    
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
    while true % ESC
        keydown = waitforbuttonpress;
        if (keydown == 0)
            disp('Mouse button was pressed');
            % axes CurrentPoint is updated
        else
            curChar = f.CurrentCharacter;
            if double(curChar) == 27 % ESC
                break
            end
            disp('Key was pressed');
            
            if isSymb(curChar)
                field=toField(curChar);
            end
            [axx, axy] = screenpix2axes(mapax,[],[]);
            [~,i]=min( distance([tb.y,tb.x], [axy, axx]) )% find closest point
            
            
            
            
            disp(f.SelectionType)
            disp(['[' curChar '] : ' num2str(double(curChar))]);
            % axes CurrentPoint is NOT updated.
            
            % % modify map 
           
            [lat,lon]=reckon(tb.y(i),tb.x(i),km2deg(tb.Radius_km(i)),(0:1:360)');
            
            createNewField=~isfield(selections,field);
            if createNewField
                
                % create a new circle plot
                hold(mapax,'on')
                selections.(field).m1=plot(mapax,[axx ; tb.x(i)] , [axy;tb.y(i)],'--', 'Marker',curChar,'Color',[.5 .5 .5]);
                selections.(field).m2=plot(mapax,tb.x(i),tb.y(i),curChar);
                selections.(field).m3=plot(mapax, lon, lat, 'color',[.25 .25 .25]);
                hold(mapax, 'off')
            else
                % move the circle plot
                selections.(field).m1.XData=[axx ; tb.x(i)];
                selections.(field).m1.YData=[axy;tb.y(i)];
                
                selections.(field).m2.XData=tb.x(i);
                selections.(field).m2.YData=tb.y(i);
                
                selections.(field).m3.XData=lon;
                selections.(field).m3.YData=lat;
            end
            
            % plot circle of radius showing events
            
            % % modify cum rate
            if createNewField
                hold(rateax,'on');
                selections.(field).cr1=plot(rateax, [datetime(2000,1,1),datetime(2002,12,31)],...
                    [0;tb.Number_of_Events(i)],...
                    'marker',curChar);
                hold(rateax,'off');
                rateax.XLimMode='auto'
                rateax.YLimMode='auto'
            else
                selections.(field).cr1.XData=[datetime(2000,1,1),datetime(2002,12,31)];
                selections.(field).cr1.YData=[0;tb.Number_of_Events(i)];
            end
            
            % % modify b-val
            if createNewField
                hold(bvalax,'on');
                selections.(field).bv1=semilogy(bvalax,tb.max_mag(i),1,curChar);
                selections.(field).bv2=semilogy(bvalax,tb.Mc_value(i),    tb.Number_of_Events(i),curChar);
                selections.(field).bv3=semilogy(bvalax,[tb.Mc_value(i); tb.max_mag(i)],	[tb.Number_of_Events(i); 1]);
                hold(bvalax,'off');
                bvalax.XLim=[-inf inf];
                bvalax.YLim=[-inf inf];
            else
                selections.(field).bv1.XData=tb.max_mag(i);
                selections.(field).bv1.YData=1;
                
                selections.(field).bv2.XData=tb.Mc_value(i);
                selections.(field).bv2.YData=tb.Number_of_Events(i);
                
                selections.(field).bv3.XData=[tb.Mc_value(i); tb.max_mag(i)];
                selections.(field).bv3.YData=[tb.Number_of_Events(i); 1];
            end
        end
    end
    set(f,'Pointer','arrow');
    
    %disp('axis current point:')
    %disp(mapax.CurrentPoint)
    %disp('..')
    %disp('Current Character, Axes, Point')
    %disp(curChar)
    %disp(f.CurrentAxes)
    %disp(f.CurrentPoint)
    
    %{
    function OnClickAxes( hax, evt )
        % sample routine.
        disp('in box')
        point1 = get(hax,'CurrentPoint'); % hax is handle to axes
        disp(point1)
        recpos=rbbox
        point2 = get(hax,'CurrentPoint'); % hax is handle to axes
        disp(point2)
    end
    %}
    
%end
