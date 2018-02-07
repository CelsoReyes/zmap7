classdef XSection
    % XSECTION create and manage cross-sections
    %
    %   obj=XSection.initialize_with_dialog(gca,50)
    %   c2 = obj.project(ZG.primeCatalog) % project the catalog onto the xsection, and store as c2
    %   figure;ax=axes;obj.plot_events_along_strike(ax,ZG.primeCatalog)
    properties
        width_km
        startpt % [lat lon]
        endpt % [lat lon]
        color
        linewidth=2.0
        startlabel
        endlabel
        curvelons
        curvelats
        polylats
        polylons
        DeleteFcn
        
    end
    properties(Dependent)
        length_km
        azimuth
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
            if ~exist('endpt1','var')||~exist('endpt2','var')
                obj=obj.set_endpoints(gca);
            else
                obj.startpt = startpt;
                obj.endpt = endpt;
            end
            
            % get waypoints along the great-circle curve
            [obj.curvelats, obj.curvelons]=gcwaypts(obj.startpt(1), obj.startpt(2), obj.endpt(1),obj.endpt(2),100);
            
            % get width polygon
            [obj.polylats,obj.polylons] = xsection_poly(obj.startpt, obj.endpt, obj.width_km/2);
            
            % mask so that we can plot original quakes in original positions
           [xs_line, xs_endpts, xs_poly, xs_slabel, xs_elabel] = plot_mapview_(obj,ax);
            
            obj.DeleteFcn = @(~,~)delete([xs_endpts, xs_line, xs_slabel, xs_elabel, xs_poly]); % autodelete xsection when figure is closed
            
        end
        
        function obj = change_width(obj, w, ax)
            obj.width_km=w;
            % get waypoints along the great-circle curve
            [obj.curvelats, obj.curvelons]=gcwaypts(obj.startpt(1), obj.startpt(2), obj.endpt(1),obj.endpt(2),100);
            
            % get width polygon
            [obj.polylats,obj.polylons] = xsection_poly(obj.startpt, obj.endpt, obj.width_km/2);
            obj.DeleteFcn();
            % mask so that we can plot original quakes in original positions
           [xs_line, xs_endpts, xs_poly, xs_slabel, xs_elabel] = plot_mapview_(obj,ax);
            obj.DeleteFcn = @(~,~)delete([xs_endpts, xs_line, xs_slabel, xs_elabel, xs_poly]); % autodelete xsection when figure is closed
            
        end
            
        function obj = change_color(obj, color, ax)
            obj.color = color;
            obj.DeleteFcn();
            % mask so that we can plot original quakes in original positions
           [xs_line, xs_endpts, xs_poly, xs_slabel, xs_elabel] = plot_mapview_(obj,ax);
            obj.DeleteFcn = @(~,~)delete([xs_endpts, xs_line, xs_slabel, xs_elabel, xs_poly]); 
        end
        
        function mask = inside(obj, catalog)
            mask=polygon_filter(obj.polylons,obj.polylats,catalog.Longitude,catalog.Latitude,'inside');
        end
        
        function c2 = project(obj,catalog)
            % PROJECT get a catalog with included events projected onto the cross section
            c2=ZmapXsectionCatalog(catalog, obj.startpt, obj.endpt, obj.width_km);
        end
        
        function obj = set_endpoints(obj,ax)
            % returns lat, lon where each is [start,end] along with handle used to pick endpoints
            
            disp('click on start and end points for cross section');
            
            if exist('ax','var')
                % pick first point
                [lon, lat] = ginput(1);
                obj.startpt=[lat, lon];
                hold(ax,'on');
                h=plot(ax,lon,lat,'x-','linewidth',2,'MarkerSize',6,'Color',obj.color);
                
                % pick second point
                [lon(2), lat(2)] = ginput(1);
                
                h.XData=lon;
                h.YData=lat;
                pause(.1);
                delete(h);
                obj.endpt=[lat(2), lon(2)];
                
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
        
        function [xs_line, xs_endpts, xs_poly, xs_slabel, xs_elabel] = plot_mapview_(obj,ax)
            % PLOT_MAPVIEW shows cross section with endpoints and width on the specified ax
            % plot great-circle path
            %   [xs_line, xs_endpts, xs_poly, xs_slabel, xs_elabel] = plot_mapview_(obj,ax)
            % these items might pollute the legend. consider turning off the Legend's autoupdate
            % function to avoid this
            
            hold(ax,'on')
            xs_line=plot(ax,obj.curvelons,obj.curvelats,'--',...
                'linewidth',obj.linewidth,...
                'Color',obj.color,...
                'Tag','Xsection Line','DisplayName',['Xsection ' obj.startlabel]);
            
            xs_endpts = plot(ax,...
                [obj.startpt(2),obj.endpt(2)], [obj.startpt(1),obj.endpt(1)],'Marker','x',...
                'Color',obj.color,...
                'lineStyle','none',...
                'MarkerSize',8,...
                'Tag','Xsection Endpoints','DisplayName','');
            
            % plot width polygon
            xs_poly=plot(ax,obj.polylons,obj.polylats,'-.',...
                'Color',obj.color,...
                'LineWidth',obj.linewidth * 0.75,...
                'Tag','Xsection Area','DisplayName','');
            %label it: put labels offset and outside the great-circle line.
            hOffset=@(x,polarity) x+(1/75).*diff(xlim(ax)) * sign(obj.endpt(2)-obj.startpt(2)) * polarity;
            vOffset=@(x,polarity) x+(1/75).*diff(ylim(ax)) * sign(obj.endpt(1)-obj.endpt(1)) * polarity;
            textStartX = hOffset(obj.startpt(2),-1);
            textStartY = vOffset(obj.startpt(1),-1);
            xs_slabel = text(ax,textStartX,textStartY,obj.startlabel,...
                'Color',obj.color.*0.8, 'fontweight','bold');
            textEndX = hOffset(obj.endpt(2),1);
            textEndY = vOffset(obj.endpt(1),1);
            xs_elabel = text(ax,textEndX,textEndY,obj.endlabel,...
                'Color',obj.color.*0.8, 'fontweight','bold');
        end
        
        function h=plot_events_along_strike(obj,ax, catalog)
            mycat = obj.project(catalog);
            % PLOT_EVENTS_ALONG_STRIKE plots X vs Depth
            h=scatter(ax,...
                mycat.dist_along_strike_km,... X
                mycat.Depth,... Y
                mag2dotsize(mycat.Magnitude),... SIZE
                years(mycat.Date - min(mycat.Date))... COLOR
                );
            ax.YDir='reverse';
            ax.XLim=[0 mycat.curvelength_km];
            ax.XTickLabel{1}=obj.startlabel;
            if ax.XTick(end) ~= mycat.curvelength_km
                ax.XTick(end+1)=mycat.curvelength_km;
                ax.XTickLabel{end+1}=obj.endlabel;
            else
                ax.XTickLabel{end}=obj.endlabel;
            end
            
            grid(ax,'on');
            xlabel(ax,'Distance along strike [km]');
            ylabel(ax,'Depth [km]');
            title(ax,sprintf('Profile: %s to %s',obj.startlabel,obj.endlabel));
        end
        
        
        function c = menu(obj,parent)
            % DELETE
            % CHANGE COLOR
            % CHANGE WIDTH
            % INFO
            % PLOT ELSEWHERE
        end
        
    end % METHODS
    
    methods(Static)
        
        function obj=initialize_with_dialog(ax, default_width)
            %INITIALIZE_WITH_DIALOG
            %obj=initialize_with_dialog(ax, catalog, default_width)
            
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
            prime='''';
            % dialog box to choose cross-section
            zdlg=ZmapDialog([]);
            zdlg.AddBasicEdit('slicewidth_km','Width of slice [km]',default_width,...
                'distance from slice for which to select events. 1/2 distance in either direction');
            zdlg.AddBasicEdit('startlabel','start label', lastletter, ...
                'start label for map');
            zdlg.AddBasicEdit('endlabel','end label', [lastletter prime],...
                'end label for map');
            zdlg.AddBasicCheckbox('choosecolor','choose cross-section color', false,{},...
                'When checked, a color selection dialog will allow you to choose a different cross-section color');
            zdlg.AddBasicPopup('chooser','Choose Points',{'choose start and end with mouse'},1,...
                'no choice');
            [zans,okPressed]=zdlg.Create('slicer');
            
            if ~okPressed
                obj=[];
                return
            end
            cidx=mod(coloridx-1,size(colororders,1))+1;
            C = colororders(cidx,:); % color for cross section
            if zans.choosecolor
                C=uisetcolor(C,['Color for ' zans.startlabel '-' zans.endlabel]);
            else
                coloridx=coloridx+1;
            end
            zans.color=C;
            obj=XSection(ax, zans);
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