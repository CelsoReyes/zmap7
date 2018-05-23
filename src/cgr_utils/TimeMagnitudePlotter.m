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

    properties (Constant)
        MAX_FOR_STEM=100000
        MARKER='s'
    end
    
    methods (Static)
        function pl=plot(catalog,ax)
            % plot plot a time-mag series for this catalog, with symbol sizes representing
            % event size
            % pl = plot(catalog)
            %
            tag = 'time_mag_plot';
            if ~exist('ax','var')
                % ax = findobj('Tag','time_mag_axis');
                f=figure('Name','Time-Magnitude Plot',...
                    'NumberTitle','off', ...
                    ......
                    'Tag','time_mag_figure');
                addAboutMenuItem();
                ax=axes(f);
                ax.Tag=tag;
            else
                if isempty(ax.Tag)
                    ax.Tag=tag;
                end
            end
            ax.Visible = 'off';

            % plotting from ZERO magnitude is arbitrary, and stemplot becomes unusable if all magnitudes
            % are below zero. Therefore, make sure stems are always going up
            minMag= min(catalog.Magnitude);
            if minMag>0
                BaseValue=0;
            else
                BaseValue=floor(minMag);
            end
            if catalog.Count > TimeMagnitudePlotter.MAX_FOR_STEM
                scatter(ax, catalog.Date, catalog.Magnitude,'.','CData',[.6 .6 .7],...
                    'Tag',tag,'DisplayName','Events',...
                    'MarkerEdgeColor',[0.05 0.05 0.2]);
            elseif isempty(catalog)
                stem(ax, catalog.Date, catalog.Magnitude,TimeMagnitudePlotter.MARKER,...
                    'Color',[.6 .6 .7],'Tag',tag,'DisplayName','Events',...
                    'MarkerEdgeColor',[0.05 0.05 0.2]);
            else
                stem(ax, catalog.Date, catalog.Magnitude,TimeMagnitudePlotter.MARKER,...
                    'BaseValue',BaseValue,'Color',[.6 .6 .7],'Tag',tag,'DisplayName','Events',...
                    'MarkerEdgeColor',[0.05 0.05 0.2]);
            end
            
            set(ax,'box','on', 'TickDir','out');
            
            ax.Tag='time_mag_axis';
            title(['Time Magnitude Plot for "' catalog.Name '"'],'Interpreter','none');
            xlabel('Date');
            
            yl=ylabel('Magnitude');
            
            grid on
            TimeMagnitudePlotter.overlayBigEvents(ax);
            ax.Visible = 'on';
        end
        
        function overlayBigEvents(ax)
            %overlayBigEvents plots large events as a different marker
            ZG=ZmapGlobal.Data;
            bigcat=ZG.maepi;
            
            holdstate=HoldStatus(ax,'on');
            scatter(ax,ZG.maepi.Date,ZG.maepi.Magnitude,mag2dotsize(ZG.maepi.Magnitude),'h',...
                'MarkerEdgeColor','k','MarkerFaceColor','y',...
                'DisplayName','Large Events');
            holdstate.Undo();
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
