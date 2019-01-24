classdef XSection < handle
    % XSECTION create and manage cross-sections. Location, labels, plotting attributes.
    %
    %   XSECTION 
    %
    % Example:
    %   % create a cross section, selecting from the current axes, with a default width of 50 km.
    %   obj=XSection.initialize_with_dialog(gca,50)
    %
    %   % project the catalog onto the xsection, and store as c2
    %   c2 = obj.project(ZG.primeCatalog) 
    %
    %   figure;
    %   ax=axes;
    %   
    %   % plot the projection of a catalog (dist along projection vs depth)
    %   % sized by magnitude, colored by date.
    %
    %   obj.plot_events_along_strike(ax,ZG.primeCatalog); 
    %   %... OR ... instead...
    %   obj.plot_events_along_strike(ax,c2, true); %plot a ZmapXsectionCatalog without projecting
    
    properties(SetObservable, AbortSet)
        width (1,1) double = ZmapGlobal.Data.CrossSectionOpts.WidthKm; % width of cross section
        width_units (1,:) char = 'kilometer'
        startpt (1,2) double % [lat lon] start point for cross section
        endpt (1,2) double % [lat lon] end point for cross section
        startlabel char % label for start point
        endlabel char % label for end point
        CoordinateSystem CoordinateSystems
    end
    
    properties
        color % color used when plotting cross section
        linewidth (1,1) {mustBePositive} = ZmapGlobal.Data.CrossSectionOpts.LineProps.LineWidth % line width for cross section
        markersize (1,1) {mustBePositive} = ZmapGlobal.Data.CrossSectionOpts.LineProps.MarkerSize % size of the end marker
        curvelons (:,1) double % longitudes that define the cross-section curve
        curvelats (:,1) double % latitudes that define the cross-section curve
        polylats (:,1) double % latitudes that define the polygon containing points within width of curve
        polylons (:,1) double % longitudes that define the polygon containing points within width of curve
        DeleteFcn function_handle % a function to remove the plotted polygon from the map
        
    end
    properties(SetAccess=immutable)
        refellipsoid referenceEllipsoid = referenceEllipsoid('wgs84','kilometer');
    end
        
    
    properties(Access=private)
        handles=gobjects(0);
    end
    
    properties(Dependent)
        length_km % length of cross section [read only]
        azimuth % direction 
        name
    end
    
    properties(Constant)
        MainMenuLabel = [char(402) , '(s,z)'];
    end
    
    events
        XsecChanged; % event to send that will force a redraw.
        LabelChanged; %
        Deleted;
    end
    
    methods
        function obj=XSection(ax, zans, startpt, endpt, ref_ellipsoid)
            % XSECTION create a cross section
            % obj = XSECTION(ax, zans, startpt, endpt)
            %  where zans is a struct with fields: 'width', 'startlabel', 'endlabel', and 'color'
            % and startpt, endpoint are each [lat,lon]
            
            obj.width    = zans.slicewidth_km;   % slicewidth_km
            obj.startlabel  = zans.startlabel;      % startlabel
            obj.endlabel    = zans.endlabel;        % endlabel
            obj.color       = zans.color;           % color
            
            if exist('ref_ellipsoid','var')
                if ischarlike(ref_ellipsoid)
                    obj.refellipsoid = referenceEllipsoid(ref_ellipsoid,'kilometer');
                else
                    obj.refellipsoid = ref_ellipsoid;
                end
            end
                
            
            % dialog box to choose cross-section
            if ~exist('startpt','var')||~exist('endpt','var')
                obj=obj.set_endpoints(ax); %gca
            else
                obj.startpt = startpt;
                obj.endpt = endpt;
            end
            
            addlistener(obj, 'width'  , 'PostSet', @XSection.handlePropertyEvents);
            addlistener(obj, 'startpt'   , 'PostSet', @XSection.handlePropertyEvents);
            addlistener(obj, 'endpt'     , 'PostSet', @XSection.handlePropertyEvents);
            addlistener(obj, 'startlabel', 'PostSet', @XSection.handlePropertyEvents);
            addlistener(obj, 'endlabel'  , 'PostSet', @XSection.handlePropertyEvents);
            
            obj.recalculate_xsec_curve();
            obj.recalculate_boundary();
            
            plot_mapview(obj, ax);
            % mask so that we can plot original quakes in original positions
            obj.DeleteFcn = @(~,~)obj.delete_graphics();
        end
        
        function ln = get.length_km(obj)
            ln=distance(obj.startpt,obj.endpt,obj.refellipsoid);
        end
        
        function change_width(obj, w)
            % CHANGE_COLOR changes the width for the cross section and area outline
            %
            % obj = obj.CHANGE_WIDTH( WIDTH_KM, AZ)
            if ~exist('w','var') || isempty(w)
                obj.width = obj.widthZmapGlobal.Data.CrossSectionOpts.WidthKm;
            else
                obj.width = w;
            end

        end
            
        function change_color(obj, color, container)
            % CHANGE_COLOR changes the color for the cross section and area outline
            %
            % obj = obj.CHANGE_COLOR(color, ax)
            if isempty(color)
                color=uisetcolor(obj.color,['Color for ' obj.name]);
            end
                
            obj.color = color;
            
            set(findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','line'), 'Color',color);
            mytexts = findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','text');
            set(mytexts, 'Color', color .* 0.8);
            
            set(findobj(mytexts,'-regexp','Tag',['Xsection .*' obj.name, '$']), 'EdgeColor',color);
            
            ax=findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','axes');
            if ~isempty(ax)
                set(get(ax,'XAxis'),'color',color .* 0.5);
                set(get(ax,'YAxis'),'color',color .* 0.5);
            end
            set(findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','histogram'), 'EdgeColor',color);

        end
        
        function swap_ends(obj, ax)
            % SWAP_ENDS reverses the direction of the cross section
            xxx = obj.startpt;
            obj.startpt = obj.endpt;
            obj.endpt = xxx;
        end
            
        function mask = inside(obj, catalog)
            % INSIDE get a T/F vector, telling which events are within defined distance of xsection
            %
            % mask = obj.INSIDE(catalog)
            
            mask=inpoly([catalog.X,catalog.Y],[obj.polylons,obj.polylats]);
        end
        
        function c2 = project(obj,catalog)
            % PROJECT get a catalog with included events projected onto the cross section
            % 
            % projectedCat = obj.PROJECT(catalog)
            
            c2=ZmapXsectionCatalog(catalog, obj.startpt, obj.endpt, obj.width);
        end
        
        function set_endpoints(obj,ax)
            % SET_ENDPOINTS select beginning and ending point for cross section
            %
            % obj = obj.set_endpoints(AX) select segments with a mouse
            
            disp('click on start and end points for cross section');
            
            if exist('ax','var')
                % pick first point
                try
                    ptdetails = selectSegmentUsingMouse(ax, obj.color, obj.CoordinateSystem, obj.ref_ellipsoid);
                    obj.startpt=[ptdetails.xy1(2), ptdetails.xy1(1)];
                    obj.endpt=[ptdetails.xy2(2), ptdetails.xy2(1)];
                catch ME
                    warning(ME.message)
                end
            else
                error('expecting axes to be able to choose endpoints');
            end
            
        end
        
        function [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax)
            % PLOT_MAPVIEW shows cross section with endpoints and width on the specified ax
            % plot great-circle path
            %   [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax)
            % these items might pollute the legend. consider turning off the Legend's autoupdate
            % ability to avoid this
            ZGOpts = ZmapGlobal.Data.CrossSectionOpts;
            
            hold(ax,'on')
            prev_xlimmode=ax.XLimMode;
            ax.XLimMode='manual';
            prev_ylimmode=ax.YLimMode;
            ax.YLimMode='manual';
            xs_line=line(ax,obj.curvelons,obj.curvelats,...
                'LineStyle',ZGOpts.LineProps.LineStyle,...
                'LineWidth',obj.linewidth,...
                'Color',obj.color,...
                'MarkerIndices',[1 numel(obj.curvelons)],...
                'Marker',ZGOpts.LineProps.Marker,...
                'MarkerSize',obj.markersize,...
                'Tag',['Xsection Line ', obj.name],...
                'DisplayName',['Xsection ' obj.startlabel]);
            
            % plot width polygon (border)
            xs_poly=line(ax,obj.polylons,obj.polylats,...
                'LineStyle',ZGOpts.BorderProps.LineStyle,...
                'Color',obj.color,...
                'LineWidth',ZGOpts.BorderProps.LineWidth,...
                'Tag',['Xsection Area ' obj.name],...
                'DisplayName','');
            
            %label it: put labels offset and outside the great-circle line.
            
            xs_slabel = text(ax, obj.startpt(2), obj.startpt(1),obj.startlabel,...
                'Color',obj.color.*0.8, ...
                'FontSize',ZGOpts.LabelProps.FontSize,...
                'FontWeight',ZGOpts.LabelProps.FontWeight,...
                'BackgroundColor',FancyColors.rgb(ZGOpts.LabelProps.BackgroundColor),...
                'EdgeColor',obj.color,...
                'Tag',['Xsection Start ' obj.name]);
            
            
            xs_elabel = text(ax,obj.endpt(2),obj.endpt(1),obj.endlabel,...
                'Color',obj.color.*0.8,... 
                'FontSize',ZGOpts.LabelProps.FontSize,...
                'FontWeight',ZGOpts.LabelProps.FontWeight,...
                'BackgroundColor',FancyColors.rgb(ZGOpts.LabelProps.BackgroundColor),...
                'EdgeColor',obj.color,...
                'Tag',['Xsection End ' obj.name]);
            
            obj.add_graphics(ax,xs_line, xs_slabel, xs_elabel, xs_poly);
            obj.update_label('startlabel',ax);
            obj.update_label('endlabel',ax);
            
            ax.XLimMode=prev_xlimmode;
            ax.YLimMode=prev_ylimmode;
            drawnow
        end
        
        % TODO add method to toggle between shape and not
        function plot_events_along_strike(obj,ax, catalog, noproject)
            % PLOT_EVENTS_ALONG_STRIKE plots dist along x vs depth, sized by magnitude, colored by date
            if exist('noproject','var') && isa(catalog,'ZmapXsectionCatalog') && noproject
                mycat = catalog;
            else
                mycat = obj.project(catalog);
            end
            % PLOT_EVENTS_ALONG_STRIKE plots X vs Depth
            if isstruct(ax.UserData) && isfield(ax.UserData,'cep')
                cep=ax.UserData.cep;
                cep.catalogFcn=@()mycat;
            else
                cep=XSectionExplorationPlot(ax,@()mycat,obj);
            end
            cep.scatter(['Xsection plot ' obj.name]);
            ax.Tag=['Xsection strikeplot ' obj.name];
        end
        
        function gr = getGrid(obj, x_km, zs_km)
            % GETGRID get a grid from this cross section
            if numel(x_km) == 1
                % x_km is the delta spacing in km
                % keep x_km/2 away from both edges to avoid edge effects
                xDists_deg = km2deg( (x_km/2) : x_km : (obj.length_km - x_km/2));
            else
                xDists_deg = km2deg(x_km);
            end
            
            [latout, lonout]=reckon(...
                obj.startpt(1),obj.startpt(2),...
                xDists_deg,...
                azimuth(obj.startpt, obj.endpt)...
                ); %#ok<CPROPLC>
            
            nPts = numel(latout(:));
            nZs = numel(zs_km);
            lolaz=[ lonout(:), latout(:), zeros(nPts,1)];
            lolaz=repmat(lolaz,nZs,1);
            for n=1:nZs
                st = (n - 1) * nPts + 1;
                ed = st + nPts;
                lolaz( st : ed , 3) = zs_km(n);
            end
            gname=sprintf('gridxs %s - %s',obj.startlabel, obj.endlabel);
            gr=ZmapVGrid(gname, 'FromPoints', lolaz);
        end
        
        function s = get.name(obj)
            s=[obj.startlabel ' - ' obj.endlabel];
        end
        
        function s = info(obj)
            displayer=@(x)sprintf(...
                    'X-Sec %s: %g km long by %g %ss wide [(%g,%g) to (%g,%g)]',...
                    x.name, x.length_km, x.width, x.width_units, x.startpt, x.endpt);
            nObj = numel(obj);
            if isempty(nObj)
                s=('No cross section(s) or empty cross section');
            elseif nObj==1
                s=sprintf('%s', displayer(obj));
            else
                s=sprintf('%d XSection slices:', nObj);
                for n=1:nObj
                    s=sprintf('%s]n%s',s,displayer(nObj(n)));
                end
            end
        end
        
        function disp(obj)
            disp(info(obj));
        end
        
        function recalculate_boundary(obj)
            [obj.polylats,obj.polylons] = xsection_poly(obj.startpt, obj.endpt, obj.width/2,false,obj.refellipsoid);
        end
        
        function recalculate_xsec_curve(obj)
            % RECALCULATE if the width, startpoint, or endpoint changes, then recalculate boundaries
            % get waypoints along the great-circle curve
            nPoints  = 100;
            [obj.curvelats, obj.curvelons]=gcwaypts(obj.startpt(1), obj.startpt(2), obj.endpt(1),obj.endpt(2),nPoints);
        end

        function delete(obj)
           graphicsToDelete = isvalid(obj.handles(:,2:end));
           delete(obj.handles(graphicsToDelete));
           notify(obj, 'Deleted');
        end
    end % METHODS
    
    methods(Access=private)
        function add_graphics(obj, ax,hLine, hStart, hEnd, hPoly)
            obj.handles(end+1,1:5)=[ax, hLine, hStart, hEnd, hPoly];
        end
        function delete_graphics(obj, ax)
            if exist('ax','var')
                thisRow = obj.handles(:,1)==ax;
            else
                thisRow= true(size(obj.handles,1),1);
            end
            delete(obj.handles(thisRow, 2:5 ));
            obj.handles(thisRow)=[];
        end

        function update_label(obj,whichLabel, ax)
            % update the label names as well as their position relative to the xsection
            
            if ~exist('ax','var')
                i=true(size(obj.handle,1),1);
            else
                i = obj.handles(:,1)==ax;
            end
            
            
            l2r_orientation = obj.startpt(2) <= obj.endpt(2);
            u2d_orientation = obj.startpt(1) >= obj.endpt(1);
            
            % avoid overlapping the label with the plot
            if u2d_orientation
                dy = 1;
            else
                dy = -1;
            end
            dx = 1.5;
            
            switch whichLabel
                case 'startlabel'
                    mylabels = obj.handles(i,3);
                    
                    for n=1:numel(mylabels)
                        mylabel=mylabels(n);
                        if l2r_orientation
                            mylabel.Position([1 2]) = mylabel.Position([1 2]) + [-dx dy].* mylabel.Extent([3 4]);
                            mylabel.HorizontalAlignment = 'right';
                        else
                            mylabel.Position([1 2]) = mylabel.Position([1 2]) + [dx dy].*mylabel.Extent([3 4]);
                            mylabel.HorizontalAlignment = 'left';
                        end
                    end
                    set(mylabel,'Tag',['Xsection Start ' obj.name]);
                    
                case 'endlabel'
                    mylabels = obj.handles(i,4);
                    for n=1:numel(mylabels)
                        mylabel=mylabels(n);
                        if l2r_orientation
                            mylabel.Position([1 2]) = mylabel.Position([1 2]) + [dx -dy].*mylabel.Extent([3 4]);
                            mylabel.HorizontalAlignment = 'left';
                        else
                            mylabel.Position([1 2]) = mylabel.Position([1 2]) + [-dx -dy].*mylabel.Extent([3 4]);
                            mylabel.HorizontalAlignment = 'right';
                        end
                    end
                    set(mylabel,'Tag',['Xsection End ' obj.name]);
            end
        end
        
        function update_xsec_plots(obj)
            polys = obj.handles(:,5);
            lines = obj.handles(:,2);
            set(polys,'XData',obj.polylons, ...
                'YData',obj.polylats,...
                'Color',obj.color,...
                'Tag',['Xsection Area ' obj.name]);
            set(lines,'XData',obj.curvelons, 'YData', obj.curvelats,'Color', obj.color,...
                'Tag',['Xsection ' obj.name]);
        end
    end
    
    methods(Static)
        
        function obj=initialize_with_mouse(ax, default_width, coord_system, ref_ellipsoid)
                ptdetails = selectSegmentUsingMouse(ax, 'm', coord_system, ref_ellipsoid); % could throw
                if isequal(ptdetails.xy1,ptdetails.xy2)
                    error('Cannot create a zero-length cross section');
                end
                obj = XSection.initialize_with_dialog(ax, default_width, ptdetails);
        end
        function obj=initialize_with_dialog(ax, default_width, ptdetails)
            %INITIALIZE_WITH_DIALOG get a XSECTION, where parameters are determined via dialog box
            %
            %obj=XSECTION.INITIALIZE_WITH_DIALOG(ax, default_width)
            
            persistent lastletter
            persistent colororders
            persistent coloridx
            if isempty(lastletter)
                lastletter='A';
            end
            if ~exist('default_width','var')
                default_width=20;
            end
            
            if isempty(colororders)
                colororders=get(gca,'ColorOrder');
                coloridx=1;
            end
            
            cidx=mod(coloridx-1,size(colororders,1))+1;
            C = colororders(cidx,:); % color for cross section [rgb]
            
            prime='''';
            % dialog box to choose cross-section
            zdlg=ZmapDialog();
            zdlg.AddEdit('slicewidth_km','Width of slice [km]',default_width,...
                'distance from slice for which to select events. 1/2 distance in either direction');
            zdlg.AddEdit('startlabel','start label', lastletter, ...
                'start label for map');
            zdlg.AddEdit('endlabel','end label', [lastletter prime],...
                'end label for map');
            cname = FancyColors.name(C);
            cname = FancyColors.colorize(cname,cname,'nohtml');
            zdlg.AddCheckbox('choosecolor',...
                sprintf('<html>change x-section color : <b>[%s]</b>',cname), false,{},...
                'When checked, a color selection dialog will allow you to choose a different cross-section color');
            
            if ~exist('ptdetails','var')
                zdlg.AddPopup('chooser','Choose Points',{'choose start and end with mouse'},1,...
                    'no choice');
                zdlg.AddHeader('Start point:');
                zdlg.AddEdit('startx','x',nan,'Cross section starting point (x or lon)');
                zdlg.AddEdit('starty','y',nan,'Cross section starting point (y or lat)');
                zdlg.AddHeader('End point:');
                zdlg.AddEdit('endx','x',nan,'Cross section ending point (x or lon)');
                zdlg.AddEdit('endy','y',nan,'Cross section ending point (y or lat)');
            else
                zdlg.AddHeader('Start point:');
                zdlg.AddEdit('startx','x',ptdetails.xy1(1),'Cross section starting point (x or lon)');
                zdlg.AddEdit('starty','y',ptdetails.xy1(2),'Cross section starting point (y or lat)');
                zdlg.AddHeader('End point:');
                zdlg.AddEdit('endx','x',ptdetails.xy2(1),'Cross section ending point (x or lon)');
                zdlg.AddEdit('endy','y',ptdetails.xy2(2),'Cross section ending point (y or lat)');
            end
            
            
            [zans,okPressed]=zdlg.Create('Name', 'slicer');
            
            if ~okPressed
                obj=[];
                return
            end
            if zans.choosecolor
                C=uisetcolor(C,['Color for ' zans.startlabel '-' zans.endlabel]);
            else
                coloridx=coloridx+1;
            end
            zans.color=C;
            if exist('ptdetails','var')
                obj = XSection(ax, zans, [zans.starty, zans.startx] , [zans.endy, zans.endx]);
            else
                obj = XSection(ax, zans);
            end
            if strcmp(lastletter,zans.startlabel)
                lastletter=increment_lettercode(lastletter);
            end
            
            
            function ll=increment_lettercode(ll)
                % incement the last letter used. Will automatically run from A to ZZ
                ll(end)=char(ll(end)+1);
                if ll(end)=='Z'
                    if length(ll)==1
                        ll='AA';
                    else
                        assert(lastletter ~= "ZZ",'Error. too many cross sections');
                        ll(1)=char(ll(1)+1);
                        ll(2)='A';
                    end
                end
            end
        end
        
        
        function handlePropertyEvents(src,ev)
            obj = ev.AffectedObject;
            switch src.Name
                case 'width'
                    obj.recalculate_boundary();
                    obj.update_xsec_plots();
                    notify(obj,'XsecChanged');
                    
                case {'startpt','endpt'}
                    obj.recalculate_xsec_curve();
                    obj.recalculate_boundary();
                    obj.update_xsec_plots();
                    obj.update_label(obj, 'startlabel');
                    obj.update_label(obj, 'endlabel');
                    notify(obj,'XsecChanged');
                    
                case {'startlabel','endlabel'}
                    obj.update_label(obj, src.Name);
                    
            end
        end
    end
end % classdef
