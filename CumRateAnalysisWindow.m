classdef CumRateAnalysisWindow < AnalysisWindow
    properties
    end
    methods
        function obj=CumRateAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            if isempty(obj.ax.Tag)
                obj.ax.Tag = 'dvCumrate';
            end
            obj.ax.Title.String='Cumulative Rate';
            obj.ax.XLabel.String='Time';
            obj.ax.YLabel.String='Cumulative Events';
        end
        
        function [x,y]=calculate(obj,catalog)
            x=sort(catalog.Date);
            y=1:catalog.Count;
        end
        
    end
end