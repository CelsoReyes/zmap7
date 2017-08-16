classdef TimeMagnitudePlotter
    % Used to create time-mag plots
    %
    % plotting multiple times will simply replace the existing plot
    %
    % Example:
    %   TimeMagnitudePlotter.plot(catalog)
    %   TimeMagnitudePlotter.colorByLatLon(catalog);
    %   ax = TimeMagnitudePlotter.axes;
    %   TimeMagnitudePlotter.clear();
    
    %TODO add ability to plot "big" events
    properties
    end
    
    methods (Static)
        function pl=plot(catalog)
            % plot plot a time-mag series for this catalog, with symbol sizes representing
            % event size
            % pl = plot(catalog)
            %
            tag = 'time_mag_plot';
            ax = findobj('Tag','time_mag_axis');
            if isempty(ax)
                figure('Name','Time-Magnitude Plot',...
                    'NumberTitle','off', ...
                    ......
                    'Tag','time_mag_figure');
            else
                delete(ax);
            end
            ax=axes;
            ax.Visible = 'off';
            %% to do a colored-by depth plot, use this
            %{
            depcolors=catalog.Depth - min(catalog.Depth);
            colormap('jet')
            pl=scatter(ax, catalog.Date, catalog.Magnitude,12,depcolors,'Tag',tag,...
                'DisplayName','Events');
            pl.Marker='+';
            cb=colorbar('peer',ax,'YDir','reverse');
            ylabel(cb,'depth [km]')
            %}
            %% to do a not-colored plot, use this
            
            pl=scatter(ax, catalog.Date, catalog.Magnitude,12,'Tag',tag,...
                'DisplayName','Events');
            pl.Marker='+';
            
            set(ax,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',14,'Linewidth',1.2);
            ax.Tag='time_mag_axis';
            title(['Time Magnitude Plot for "' catalog.Name '"'],'Interpreter','none');
            xlabel('Date');
            ylabel('Magnitude');
            grid
            ax.Visible = 'on';
        end
        %{
        function pl2=addCatalog(catalog,color)
            % add another catalog to this plot
            tag= 'time_mag_plotA';
            ax=findobj('Tag','time_mag_axis');
            hold(ax,'on');
            pl2=scatter(ax, catalog.Date, catalog.Magnitude, mag2dotsize(catalog.Magnitude),color,'Tag',tag);
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
            
            pl = findobj('Tag','time_mag_plot');
            ax=findobj('Tag','time_mag_axis');
            
            lonRange = range(catalog.Longitude);
            blue_val = catalog.Longitude/lonRange;
            blue_val = blue_val - min(blue_val);
            
            latRange = range(catalog.Latitude);
            red_val = catalog.Latitude/latRange;
            red_val = red_val - min(red_val);
            pl.CData=[red_val .* 0.75 , zeros(size(red_val))+.2, blue_val .* 0.75];
            ypos = max(ax.YLim) - .05 * range(ax.YLim);
            xpos = min(ax.XLim) + .1 * range(ax.XLim);
            if isempty(findobj('Tag','timemag_colortext'))
                text(xpos, ypos, 'Colored by relative Position:East = blue, North = Red','Tag','timemag_colortext');
            end
            
            
        end
        function setColor(color)
            % setColor  set color fo the time-mag plot
            % setColor(color), where color may be either a 1x3 RGB vector
            % or an Nx3 RGB array (where N is the number of earthquakes);
            if ~exist('color','var')
                color=[0 0 .3];
            end
            pl = findobj('Tag','time_mag_plot');
            set(pl,'CData',color);
        end
        
        function ax = axes()
            % axes get axes for the time-mag plot
            %   ax = axes()
            ax=findobj('Tag','time_mag_axis');
        end
        function close()
            ax = TimeMagnitudePlotter.axes();
            if ~isempty(ax)
                close([ax.Parent]);
            end
        end
            
            
        
    end
end
