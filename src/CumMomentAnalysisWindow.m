classdef CumMomentAnalysisWindow < AnalysisWindow
    % CUMMOMENTANALYSISWINDOW shows cumulative moment release
    properties
    end
    methods
        function obj=CumMomentAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            % prepare the moment release axes
            if isempty(obj.ax.Tag)
                obj.ax.Tag = 'dvMoment';
            end
            obj.ax.Title.String='Cum Moment Release';
            obj.ax.XLabel.String='time';
            obj.ax.YLabel.String='Cumulative Moment [N m]'; %units as per calc_moment
        end
        
        function [x,y]=calculate(~,catalog)
            if ~isa(catalog,'ZmapCatalog')
                catalog=catalog.Catalog;
            end
            % return the datetime and cumulative-moment for each event in the catalog
            x=catalog.Date;
            [~, y, ~] = calc_moment(catalog);
        end
        
    end
end