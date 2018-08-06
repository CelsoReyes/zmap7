classdef DepthAnalysisWindow < AnalysisWindow
    % DEPTHANALYSISWINDOW shows the number of events, binned per depth
    properties
        binedges; % km
    end
    methods
        function obj=DepthAnalysisWindow(ax,binedges)
            obj@AnalysisWindow(ax);
            obj.binedges=binedges;
        end
        
        function prepare_axes(obj)
            % prepare the depth profile axes
            obj.ax.Tag = 'dvEventsWidthDepth';
            obj.ax.YDir='reverse';
            obj.ax.Title.String='Depth Profile';
            obj.ax.XLabel.String='Number of events';
            obj.ax.YLabel.String='Depth';
        end
        
        function [x,y]=calculate(obj,catalog)
            % calculate the number of events (y) for each binned depth(x)
            x = histcounts(catalog.Depth,obj.binedges);
            y=obj.binedges(1:end-1) + diff(obj.binedges)./2;
        end
        
    end
end
