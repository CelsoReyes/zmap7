classdef AnalysisMagnitudeHist < HistAnalysisWindow
    methods
        function obj=AnalysisMagnitudeHist(ax)
            obj@HistAnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            % prepare the cumulative event rate axes
            if isempty(obj.ax.Tag)
                obj.ax.Tag = 'dvCumrate';
            end
            obj.ax.Title.String='Cumulative Rate';
            obj.ax.XLabel.String='Time';
            obj.ax.YLabel.String='Cumulative Events';
        end
        
        function [x,y]=calculate(obj,catalog)
            % calculate the cumulative number of events (y) over time (x)
            x=sort(catalog.Date);
            y=[]; % histogram?
        end
        
    end
end
