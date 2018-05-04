classdef XSection
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
    %   % plot the projection of a catalog (distalong projection vs depth)
    %   % sized by magnitude, colored by date.
    %
    %   obj.plot_events_along_strike(ax,ZG.primeCatalog); 
    %   %... OR ... instead...
    %   obj.plot_events_along_strike(ax,c2, true); %plot a ZmapXsectionCatalog without projecting
    
    properties
        width_km (1,1) double % width of cross section, in kilometers
        startpt (1,2) double % [lat lon] start point for cross section
        endpt (1,2) double % [lat lon] end point for cross section
        color % color used when plotting cross section
        linewidth (1,1) {mustBePositive} = 2.0 % line width for cross section
        startlabel char % label for start point
        endlabel char % label for end point
        curvelons (:,1) double % longitudes that define the cross-section curve
        curvelats (:,1) double % latitudes that define the cross-section curve
        polylats (:,1) double % latitudes that define the polygon containing points within width of curve
        polylons (:,1) double % longitudes that define the polygon containing points within width of curve
        DeleteFcn function_handle % function that will remove the plotted polygon from the map
        
    end
    properties(Dependent)
        length_km % length of cross section [read only]
        azimuth % direction 
        name
    end
    
    methods
        function obj=XSection(ax, zans, startpt, endpt)
            % XSECTION create a cross section
            %  [CatalogInCrossSection, optionsUsed] = PLOT_CROSS_SECTION
            %
            % you can choose section width, start & end labels, and color.
            %
            % plots cross-section (great-circle curve) on map, along with boundary for selected events.
            % brings up new figure containing cross-section, with selected events plotted with depth,
            % and histograms of events along sgtrike and with depth
            %
            % plots into the ZmapMainWindow
            %
            % see also ZmapXsectionCatalog
            
            %catalog=ZG.primeCatalog;
            
            % zans contains:
            obj.width_km = zans.slicewidth_km;  % slicewidth_km
            obj.startlabel = zans.startlabel;   % startlabel
            obj.endlabel = zans.endlabel;       % endlabel
            obj.color = zans.color;             % color
            %method = zans.chooser;               % chooser
            
            % dialog box to choose cross-section
            if ~exist('startpt','var')||~exist('endpt','var')
                obj=obj.set_endpoints(ax); %gca
            else
                obj.startpt = startpt;
                obj.endpt = endpt;
            end
            % get waypoints along the great-circle curve
            [obj.curvelats, obj.curvelons]=gcwaypts(obj.startpt(1), obj.startpt(2), obj.endpt(1),obj.endpt(2),100);
            
            % get width polygon
            [obj.polylats,obj.polylons] = xsection_poly(obj.startpt, obj.endpt, obj.width_km/2);
            % mask so that we can plot original quakes in original positions
           [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax);
            
            obj.DeleteFcn = @(~,~)delete([xs_line, xs_slabel, xs_elabel, xs_poly]); % autodelete xsection when figure is closed
            
        end
        
        function ln = get.length_km(obj)
            ln=deg2km(distance(obj.startpt,obj.endpt));
        end
        
        function obj = change_width(obj, w, ax)
            % CHANGE_COLOR changes the width for the cross section and area outline
            %
            % obj = obj.CHANGE_WIDTH( WIDTH_KM, AZ)
            
            obj.width_km=w;
            
            % get waypoints along the great-circle curve
            [obj.curvelats, obj.curvelons]=gcwaypts(obj.startpt(1), obj.startpt(2), obj.endpt(1),obj.endpt(2),100);
            
            % get width polygon
            [obj.polylats,obj.polylons] = xsection_poly(obj.startpt, obj.endpt, obj.width_km/2);
            obj.DeleteFcn();
            
            % mask so that we can plot original quakes in original positions
           [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax);
            obj.DeleteFcn = @(~,~)delete([xs_line, xs_slabel, xs_elabel, xs_poly]); % autodelete xsection when figure is closed
            
        end
            
        function obj = change_color(obj, color, container)
            % CHANGE_COLOR changes the color for the cross section and area outline
            %
            % obj = obj.CHANGE_COLOR(color, ax)
            if isempty(color)
                color=uisetcolor(obj.color,['Color for ' obj.name]);
            end
                
            obj.color = color;
            
            set(findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','line'), 'Color',color);
            set(findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','text'), 'Color',color .* 0.8);
            ax=findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','axes');
            if ~isempty(ax)
                set(get(ax,'XAxis'),'color',color .* 0.5);
                set(get(ax,'YAxis'),'color',color .* 0.5);
            end
            set(findobj(container,'-regexp','Tag',['Xsection .*' obj.name],'Type','histogram'), 'EdgeColor',color);
            
            %obj.DeleteFcn();
            %% mask so that we can plot original quakes in original positions
           %[xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax);
           % obj.DeleteFcn = @(~,~)delete([xs_line, xs_slabel, xs_elabel, xs_poly]); 
        end
        
        function obj = swap_ends(obj, ax)
            % SWAP_ENDS reverses the direction of the cross section
            xxx = obj.startpt;
            obj.startpt = obj.endpt;
            obj.endpt = xxx;
            
            % get waypoints along the great-circle curve
            [obj.curvelats, obj.curvelons]=gcwaypts(obj.startpt(1), obj.startpt(2), obj.endpt(1),obj.endpt(2),100);
            
            % get width polygon
            [obj.polylats,obj.polylons] = xsection_poly(obj.startpt, obj.endpt, obj.width_km/2);
            
            obj.DeleteFcn();
            % mask so that we can plot original quakes in original positions
           [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax);
            obj.DeleteFcn = @(~,~)delete([xs_line, xs_slabel, xs_elabel, xs_poly]); 
        end
            
        function mask = inside(obj, catalog)
            % INSIDE get a T/F vector, telling which events are within defined distance of xsection
            %
            % mask = obj.INSIDE(catalog)
            
            mask=polygon_filter(obj.polylons,obj.polylats,catalog.Longitude,catalog.Latitude,'inside');
        end
        
        function c2 = project(obj,catalog)
            % PROJECT get a catalog with included events projected onto the cross section
            % 
            % projectedCat = obj.PROJECT(catalog)
            
            c2=ZmapXsectionCatalog(catalog, obj.startpt, obj.endpt, obj.width_km);
        end
        
        function obj = set_endpoints(obj,ax)
            % SET_ENDPOINTS select beginning and ending point for cross section
            %
            % obj = obj.set_endpoints(AX) select segments with a mouse
            
            disp('click on start and end points for cross section');
            
            if exist('ax','var')
                % pick first point
                ptdetails = selectSegmentUsingMouse(ax, 'deg','km',obj.color);
                obj.startpt=[ptdetails.xy1(2), ptdetails.xy1(1)];
                obj.endpt=[ptdetails.xy2(2), ptdetails.xy2(1)];
            else
                error('expecting axes to be able to choose endpoints');
                % get endpoints via dialog box
                %{
                zdlg=ZmapDialog([]);
                zdlg.AddBasicEdit('startpt',['Starting point "', obj.startlabel, '" : [lat lon]'],[nan nan],...
                    'First point');
                zdlg.AddBasicEdit('endpt',['Ending point "', obj.startlabel, '" : [lat lon]']', [nan nan], ...
                    'Other endpoint');
                [res, ok]=zdlg.Create('Choose start and end points for cross section');
                assert(ok, 'Endpoints not set');
                %}
            end
            
        end
        
        function [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax)
            % PLOT_MAPVIEW shows cross section with endpoints and width on the specified ax
            % plot great-circle path
            %   [xs_line, xs_poly, xs_slabel, xs_elabel] = plot_mapview(obj,ax)
            % these items might pollute the legend. consider turning off the Legend's autoupdate
            % function to avoid this
            
            hold(ax,'on')
            prev_xlimmode=ax.XLimMode;
            ax.XLimMode='manual';
            prev_ylimmode=ax.YLimMode;
            ax.YLimMode='manual';
            xs_line=line(ax,obj.curvelons,obj.curvelats,'LineStyle','--',...
                'linewidth',obj.linewidth,...
                'Color',obj.color,...
                'MarkerIndices',[1 numel(obj.curvelons)],'Marker','x',...
                'Tag',['Xsection Line ', obj.name],...
                'DisplayName',['Xsection ' obj.startlabel]);
            
            % plot width polygon
            xs_poly=line(ax,obj.polylons,obj.polylats,'LineStyle','-.',...
                'Color',obj.color,...
                'LineWidth',obj.linewidth * 0.75,...
                'Tag',['Xsection Area ' obj.name],...
                'DisplayName','');
            %label it: put labels offset and outside the great-circle line.
            hOffset=@(x,polarity) x+(1/75).*diff(xlim(ax)) * sign(obj.endpt(2)-obj.startpt(2)) * polarity;
            vOffset=@(x,polarity) x+(1/75).*diff(ylim(ax)) * sign(obj.endpt(1)-obj.endpt(1)) * polarity;
            textStartX = hOffset(obj.startpt(2),-1);
            textStartY = vOffset(obj.startpt(1),-1);
            xs_slabel = text(ax,textStartX,textStartY,obj.startlabel,...
                'Color',obj.color.*0.8, 'fontweight','bold',...
                'Tag',['Xsection Start ' obj.name]);
            textEndX = hOffset(obj.endpt(2),1);
            textEndY = vOffset(obj.endpt(1),1);
            xs_elabel = text(ax,textEndX,textEndY,obj.endlabel,...
                'Color',obj.color.*0.8, 'fontweight','bold',...
                'Tag',['Xsection End ' obj.name]);
            ax.XLimMode=prev_xlimmode;
            ax.YLimMode=prev_ylimmode;
            drawnow
        end
        
        % TODO add method to toggle between shape and not
        function h=plot_events_along_strike(obj,ax, catalog, noproject)
            % PLOT_EVENTS_ALONG_STRIKE plots dist along x vs depth, sized by magnitude, colored by date
            if exist('noproject','var') && isa(catalog,'ZmapXsectionCatalog') && noproject
                mycat=catalog;
            else
                mycat = obj.project(catalog);
            end
            % PLOT_EVENTS_ALONG_STRIKE plots X vs Depth
            h=findobj(ax,'Tag','ev_along_strike_plot');
            cep=XSectionExplorationPlot(ax,@()mycat,obj);
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
            name=sprintf('gridxs %s - %s',obj.startlabel, obj.endlabel);
            gr=ZmapVGrid(name,lolaz);
        end
        
        function s = get.name(obj)
            s=[obj.startlabel ' - ' obj.endlabel];
        end
        
        function s = info(obj)
            displayer=@(x)sprintf(...
                    'X-Sec %s: %g km long by %g km wide [(%g,%g) to (%g,%g)]',...
                    x.name, x.length_km, x.width_km, x.startpt, x.endpt);
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
        

        
    end % METHODS
    
    methods(Static)
        
        function obj=initialize_with_mouse(ax, default_width)
                ptdetails = selectSegmentUsingMouse(ax, 'deg','km','m');
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
            C = colororders(cidx,:); % color for cross section
            
            prime='''';
            % dialog box to choose cross-section
            zdlg=ZmapDialog([]);
            zdlg.AddBasicEdit('slicewidth_km','Width of slice [km]',default_width,...
                'distance from slice for which to select events. 1/2 distance in either direction');
            zdlg.AddBasicEdit('startlabel','start label', lastletter, ...
                'start label for map');
            zdlg.AddBasicEdit('endlabel','end label', [lastletter prime],...
                'end label for map');
            zdlg.AddBasicCheckbox('choosecolor',sprintf('choose cross-section color [%s]',alt_colorlist(C)), false,{},...
                'When checked, a color selection dialog will allow you to choose a different cross-section color');
            if ~exist('ptdetails','var')
                zdlg.AddBasicPopup('chooser','Choose Points',{'choose start and end with mouse'},1,...
                    'no choice');
            end
            [zans,okPressed]=zdlg.Create('slicer');
            
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
                obj=XSection(ax, zans, ptdetails.xy1([2,1]), ptdetails.xy2([2,1]));
            else
                obj=XSection(ax, zans);
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
                        assert(~strcmp(lastletter,'ZZ'),'Error. too many cross sections');
                        ll(1)=char(ll(1)+1);
                        ll(2)='A';
                    end
                end
            end
        end
        
    end
    
    
end