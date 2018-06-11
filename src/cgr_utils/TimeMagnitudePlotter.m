classdef TimeMagnitudePlotter < TimeSomethingPlotter
    % Used to create time-mag plots
    %
    % plotting multiple times will simply replace the existing plot
    %
    % Example:
    %   TimeMagnitudePlotter.plot(catalog,bigCat)
    %   ax = TimeMagnitudePlotter.axes;
    %   TimeMagnitudePlotter.clear();
    
    %TODO add ability to plot "big" events

    
    methods
        function obj=TimeMagnitudePlotter()
            obj@TimeSomethingPlotter('Magnitude','');
        end
        
        function pl=plot(obj,ax,catalog,bigcat)
            % plot plot a time-mag series for this catalog, with symbol sizes representing
            % event size
            % pl = plot(catalog)
            %
            if ~exist('ax','var') || isempty(ax)
                % ax = findobj('Tag','time_mag_axis');
                f=figure('Name','Time-Magnitude Plot','NumberTitle','off', ...
                    'Tag',obj.Tags.Figure);
                addAboutMenuItem();
                obj.ax=axes(f);
            else
                obj.ax=ax;
            end
            if isempty(obj.ax.Tag)
                obj.ax.Tag=obj.Tags.Axes;
            end
            
            obj.ax.Visible = 'off';

            % plotting from ZERO magnitude is arbitrary, and stemplot becomes unusable if all magnitudes
            % are below zero. Therefore, make sure stems are always going up
            minMag= min(catalog.Magnitude);
            baseValue = min([0 , floor(minMag)]);
            
            
            if obj.hasLotsOfEvents(catalog)
                pl=obj.scatter(catalog);
            else
                pl=obj.stem(catalog, 'BaseValue', baseValue);
            end
            
            obj.prepare_axes(catalog);
            
            if exist('bigcat','var')
                obj.overlayBigEvents(bigcat);
            end
            obj.ax.Visible = 'on';
        end
        
    end
end
