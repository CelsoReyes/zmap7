classdef CumRateAnalysisWindow < AnalysisWindow
    properties
    end
    methods
        function obj=CumRateAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            %ax=axes(f,'units','pixels','Position',[1025 400 225 250]);
            obj.ax.Tag = 'dvCumrate';
            obj.ax.Title.String='Cumulative Rate';
            obj.ax.XLabel='Time';
            obj.ax.YLabel='Cumulative Events';
        end
        
        function [x,y]=calculate(obj,catalog)
            %maxstep=ceil(max(catalog.Depth)./obj.depthsteps) .* obj.depthsteps;
            %minstep=floor(min(catalog.Depth)./obj.depthsteps) .* obj.depthsteps;
            %bins=minstep : obj.depthsteps : maxstep;
            x=sort(catalog.Date);
            y=1:catalog.Count;
        end
        
    end
end