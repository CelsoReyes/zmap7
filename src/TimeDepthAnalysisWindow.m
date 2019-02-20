classdef TimeDepthAnalysisWindow < AnalysisWindow
    % CUMRATEANALYSISWINDOW shows the cumulative event rate
    properties
    end
    methods
        function obj=TimeDepthAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            % prepare the cumulative event rate axes
            if isempty(obj.ax.Tag)
                obj.ax.Tag = 'dvTimeDepth';
            end
            obj.ax.YDir = 'reverse';
            obj.ax.Title.String='Depth through Time';
            obj.ax.XLabel.String='Time';
            obj.ax.YLabel.String='Depth';
        end
        
        function [x,y]=calculate(obj,catalog)
            % calculate the cumulative number of events (y) over time (x)
            x=sort(catalog.Date);
            y=catalog.Depth;
        end
        
    end
end