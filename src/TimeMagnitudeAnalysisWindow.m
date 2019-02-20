classdef TimeMagnitudeAnalysisWindow < AnalysisWindow
    % CUMRATEANALYSISWINDOW shows the cumulative event rate
    properties
    end
    methods
        function obj=TimeMagnitudeAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            % prepare the cumulative event rate axes
            if isempty(obj.ax.Tag)
                obj.ax.Tag = 'dvTimeMag';
            end
            obj.ax.Title.String='Magnitude through Time';
            obj.ax.XLabel.String='Time';
            obj.ax.YLabel.String='Magnitude';
        end
        
        function [x,y]=calculate(obj,catalog)
            % calculate the cumulative number of events (y) over time (x)
            x=sort(catalog.Date);
            y=catalog.Magnitude;
        end
        
    end
end