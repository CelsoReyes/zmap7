classdef TimeDepthPlotter
    % Used to create time-depth plots
    %
    % plotting multiple times will simply replace the existing plot
    %
    % Example:
    %   TimeDepthPlotter.plot(catalog)
    %   TimeDepthPlotter.colorByLatLon(catalog);
    %   ax = TImeDepthPlotter.axes;
    %   TimeDepthPlotter.clear();
    
    
    %TODO add ability to plot "big" events
    
    properties (Constant)
        MAX_FOR_MARKER=100000
        MARKER='s'
    end
    
    methods (Static)
        function pl=plot(ax,catalog,bigcat)
            % plot plot a time-depth series for this catalog, with symbol sizes representing
            % event size
            % pl = plot(catalog)
            %
            tag = 'time_depth_plot';
            
            if ~exist('ax','var') || isempty(ax)
                f=figure('Name','Time Depth',...
                    'NumberTitle','off', ...
                    ......
                    'Tag','time_depth_figure');
                addAboutMenuItem();
                ax=axes(f);
                ax.Tag=tag;
            else
                if isempty(ax.Tag)
                    ax.Tag=tag;
                end
            end
            ax.Visible = 'off';
            if catalog.Count > TimeDepthPlotter.MAX_FOR_MARKER
                myMarker='.';
            else
                myMarker=TimeDepthPlotter.MARKER;
            end
            pl=scatter(ax, catalog.Date, catalog.Depth, mag2dotsize(catalog.Magnitude),'Tag',tag,...
                'DisplayName','Events','MarkerEdgeColor',[0.05 0.05 0.2],'Marker',myMarker);
            set(ax,'box','on','TickDir','out');
            ax.YDir='reverse';
            ax.Tag='time_depth_axis';
            ax.Title.String=['Time Depth Plot for "' catalog.Name '"'];
            ax.Title.Interpreter='none';
            ax.XLabel.String='Date';
            
            ax.YLabel.String='Depth [km]';
            f=ancestor(ax,'figure');
            delete(findobj(f,'Tag','TimeDepthContext'));
            c=uicontextmenu('Tag','TimeDepthContext');
            %uimenu(c,'Label','Use Log Scale',Futures.MenuSelectedFcn,{@logtoggle,ax,'Y'});
            uimenu(c,'Label','Use Log Scale',Futures.MenuSelectedFcn,{@logtoggle,'Y'});
            ax.YLabel.UIContextMenu=c;
            
            grid(ax,'on');
            if exist('bigcat','var')
                TimeDepthPlotter.overlayBigEvents(ax,bigcat);
            else
                TimeDepthPlotter.overlayBigEvents(ax);
            end
            ax.Visible = 'on';
            
        end
        
        function update(ax, catalog, bigcat)
            p=findobj(ax.Children,'flat','time_depth_plot');
            p.XData=catalog.Date;
            p.YData=catalog.Magnitude;
            p.SizeData=mag2dotsize(catalog.Magnitude);
            TimeDepthPlotter.updateBigEvents(ax, bigcat);
        end
        
        function overlayBigEvents(ax,bigcat)
            if nargin==1
                ZG=ZmapGlobal.Data;
                bigcat=ZG.maepi;
            end
            holdstate=HoldStatus(ax,'on');
            
            if isempty(bigcat)
                scatter(ax,[],[],[],'h','MarkerEdgeColor','k','MarkerFaceColor','y',...
                    'DisplayName','Large Events');
            else
                scatter(ax,bigcat.Date,bigcat.Depth, mag2dotsize(bigcat.Magnitude),...
                    'Marker','h','MarkerEdgeColor','k','MarkerFaceColor','y',...
                    'Tag','big events');
            end
            holdstate.Undo();
        end
        
        function updateBigEvents(ax,bigcat)
            sc = findobj(ax,'Tag','big events');
            if isempty(bigcat)
                sc.XData=[];
                sc.YData=[];
                sc.SizeData=[];
            else
                sc.XData=bigcat.Date;
                sc.YData=bigcat.Depth;
                sc.SizeData=mag2dotsize(bigcat.Magnitude);
            end
        end
            
            
        function colorByLatLon(catalog)
            % colorByLatLon - color the values by their relative lat-lon position
            %
            % colorByLatLon(catalog)
            %   The further East an event is, the more red.
            %   The further North, the more blue
            
            pl = findobj('Tag','time_depth_plot');
            ax=findobj('Tag','time_depth_axis');
            
            lonRange = range(catalog.Longitude);
            blue_val = catalog.Longitude/lonRange;
            blue_val = blue_val - min(blue_val);
            
            latRange = range(catalog.Latitude);
            red_val = catalog.Latitude/latRange;
            red_val = red_val - min(red_val);
            pl.CData=[red_val .* 0.75 , zeros(size(red_val))+.2, blue_val .* 0.75];
            ypos = max(ax.YLim) - .05 * range(ax.YLim);
            xpos = min(ax.XLim) + .1 * range(ax.XLim);
            if isempty(findobj('Tag','timedepth_colortext'))
                text(xpos, ypos, 'Colored by relative Position:East = blue, North = Red','Tag','timedepth_colortext');
            end
            
            
        end
        function setColor(color)
            % setColor  set color fo the time-depth plot
            % setColor(color), where color may be either a 1x3 RGB vector
            % or an Nx3 RGB array (where N is the number of earthquakes);
            if ~exist('color','var')
                color=[0 0 .3];
            end
            pl = findobj('Tag','time_depth_plot');
            set(pl,'CData',color);
        end
        
        function ax = axes()
            % axes get axes for the time-depth plot
            %   ax = axes()
            ax=findobj('Tag','time_depth_axis');
        end
        function close()
            ax = TimeDepthPlotter.axes();
            if ~isempty(ax)
                close([ax.Parent]);
            end
        end
            
            
        
    end
end
