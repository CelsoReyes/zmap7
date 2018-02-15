classdef XSectionExplorationPlot < CatalogExplorationPlot
    % XSECTIONEXPLORATIONPLOT exploration plot, which modifies the axes specifically for xsec
    %
    % see also CatalogExplorationPlot
    properties
        xsec
    end
    methods
        function obj=XSectionExplorationPlot(ax,catalogFcn,xsec)
            obj@CatalogExplorationPlot(ax, catalogFcn);
            obj.xsec = xsec;
            obj.y_by='Depth'; 
            obj.x_by='dist_along_strike_km';
        end
        function scatter(obj, tag, varargin)
            obj.scatter@CatalogExplorationPlot(tag, varargin);
            obj.fix_alongstrike_axis();
            obj.ax.YDir='reverse';    
            title(obj.ax,sprintf('Profile: %s to %s',obj.xsec.startlabel,obj.xsec.endlabel));
        end
        function update(obj, varargin)
            obj.update@CatalogExplorationPlot(varargin{:})
            obj.fix_alongstrike_axis(varargin{:})
        end
        
    end % METHODS
    methods(Hidden)
        function fix_alongstrike_axis(obj,specific)
            if ~exist('specific','var') 
                specific=[];
            else
                switch specific
                    case 'x_by'
                        xlim(obj.ax,'auto')
                        xticks(obj.ax,'auto')
                        obj.ax.XTickLabelMode='auto';
                    case 'y_by'
                        ylim(obj.ax,'auto')
                        yticks(obj.ax,'auto')
                        obj.ax.YTickLabelMode='auto';
                    case 'z_by'
                        zlim(obj.ax,'auto')
                        zticks(obj.ax,'auto')
                        obj.ax.ZTickLabelMode='auto';
                end
            end
            if (isempty(specific) || strcmp(specific,'x_by')) && strcmp(obj.x_by, 'dist_along_strike_km')
                modify_axis('XLim','XLabel','XTick','XTickLabel');
            end
            if (isempty(specific) || strcmp(specific,'y_by')) && strcmp(obj.y_by, 'dist_along_strike_km')
                modify_axis('YLim','YLabel','YTick','YTickLabel');
            end
            if (isempty(specific) || strcmp(specific,'z_by')) && strcmp(obj.z_by, 'dist_along_strike_km')
                modify_axis('ZLim','ZLabel','ZTick','ZTickLabel');
            end
            %{
            if strcmp(obj.x_by,'dist_along_strike_km')
                % make the plot pretty.
                obj.ax.XLabel.String='Dist along strike [km]';
                obj.ax.XLim=[0 obj.xsec.length_km];
                if obj.ax.XTick(1) ~=0
                    obj.ax.XTick=[0 obj.ax.XTick];
                end
                obj.ax.XTickLabel(1)={['\bf' obj.xsec.startlabel]};
                if obj.ax.XTick(end) ~= obj.xsec.length_km
                    obj.ax.XTick(end+1)= obj.xsec.length_km;
                end
                %\bf makes it bold, and assumes interpreter TEX
                obj.ax.XTickLabel(length(obj.ax.XTick))={['\bf' obj.xsec.endlabel]};
            end
            %}
            function modify_axis( xyzlim, xyzlabel, xyztick, xyzticklabel)
                % make the plot pretty.
                obj.ax.(xyzlabel).String='Dist along strike [km]';
                obj.ax.(xyzlim)=[0 obj.xsec.length_km];
                if obj.ax.(xyztick)(1) ~=0
                    obj.ax.(xyztick)=[0 obj.ax.(xyztick)];
                end
                obj.ax.(xyzticklabel)(1)={['\bf' obj.xsec.startlabel]};
                if obj.ax.(xyztick)(end) ~= obj.xsec.length_km
                    obj.ax.(xyztick)(end+1)= obj.xsec.length_km;
                end
                %\bf makes it bold, and assumes interpreter TEX
                obj.ax.(xyzticklabel)(length(obj.ax.(xyztick)))={['\bf' obj.xsec.endlabel]};
            end
        end
    end
            
end