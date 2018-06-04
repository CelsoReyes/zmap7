classdef DepthAnalysisWindow < AnalysisWindow
    properties
        binedges; %km
    end
    methods
        function obj=DepthAnalysisWindow(ax,binedges)
            obj@AnalysisWindow(ax);
            obj.binedges=binedges;
        end
        
        function prepare_axes(obj)
            %ax=axes(f,'units','pixels','Position',[1025 400 225 250]);
            obj.ax.Tag = 'dvEventsWidthDepth';
            obj.ax.YDir='reverse';
            %ax.YLim=[min(catalog.Depth) max(catalog.Depth)];
            obj.ax.Title.String='Depth Profile';
            obj.ax.XLabel.String='Number of events';
            obj.ax.YLabel.String='Depth';
        end
        
        function [x,y]=calculate(obj,catalog)
            %maxstep=ceil(max(catalog.Depth)./obj.depthsteps) .* obj.depthsteps;
            %minstep=floor(min(catalog.Depth)./obj.depthsteps) .* obj.depthsteps;
            %bins=minstep : obj.depthsteps : maxstep;
            x = histcounts(catalog.Depth,obj.binedges);
            y=obj.binedges(1:end-1) + diff(obj.binedges)./2;
        end
        
    end
end
