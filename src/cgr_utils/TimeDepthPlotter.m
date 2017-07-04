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
    
    properties
    end
    
    methods (Static)
        function pl=plot(catalog)
            % plot plot a time-depth series for this catalog, with symbol sizes representing
            % event size
            % pl = plot(catalog)
            %
            tag = 'time_depth_plot';
            ax = findobj(0,'Tag','time_depth_axis');
            if isempty(ax)
                figure('Name','Time Depth',...
                    'NumberTitle','off', ...
                    ...'MenuBar','none', ...
                    'Tag','time_depth_figure');
            else
                delete(ax);
            end
            ax=axes;
            ax.Visible = 'off';
            pl=scatter(ax, catalog.Date, catalog.Depth, mag2dotsize(catalog.Magnitude),'Tag',tag,...
                'DisplayName','Events');
            set(ax,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',14,'Linewidth',1.2);
            ax.YDir='reverse';
            ax.Tag='time_depth_axis';
            title(['Time Depth Plot for "' catalog.Name '"'],'Interpreter','none');
            xlabel('Date');
            ylabel('Depth [km]');
            grid
            ax.Visible = 'on';
        end
        %{
        function pl2=addCatalog(catalog,color)
            % add another catalog to this plot
            tag= 'time_depth_plotA';
            ax=findobj(0,'Tag','time_depth_axis');
            hold(ax,'on');
            pl2=scatter(ax, catalog.Date, catalog.Depth, mag2dotsize(catalog.Magnitude),color,'Tag',tag);
        end
        %}
        function overlayBigEvents(catalog)
        end
            
        function colorByLatLon(catalog)
            % colorByLatLon - color the values by their relative lat-lon position
            %
            % colorByLatLon(catalog)
            %   The further East an event is, the more red.
            %   The further North, the more blue
            
            pl = findobj(0,'Tag','time_depth_plot');
            ax=findobj(0,'Tag','time_depth_axis');
            
            lonRange = range(catalog.Longitude);
            blue_val = catalog.Longitude/lonRange;
            blue_val = blue_val - min(blue_val);
            
            latRange = range(catalog.Latitude);
            red_val = catalog.Latitude/latRange;
            red_val = red_val - min(red_val);
            pl.CData=[red_val .* 0.75 , zeros(size(red_val))+.2, blue_val .* 0.75];
            ypos = max(ax.YLim) - .05 * range(ax.YLim);
            xpos = min(ax.XLim) + .1 * range(ax.XLim);
            if isempty(findobj(0,'Tag','timedepth_colortext'))
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
            pl = findobj(0,'Tag','time_depth_plot');
            set(pl,'CData',color);
        end
        
        function ax = axes()
            % axes get axes for the time-depth plot
            %   ax = axes()
            ax=findobj(0,'Tag','time_depth_axis');
        end
        function close()
            ax = TimeDepthPlotter.axes();
            if ~isempty(ax)
                close([ax.Parent]);
            end
        end
            
            
        
    end
end
