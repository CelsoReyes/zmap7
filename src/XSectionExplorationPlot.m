classdef XSectionExplorationPlot < CatalogExplorationPlot
    % XSECTIONEXPLORATIONPLOT exploration plot, which modifies the axes specifically for xsec
    %
    % see also CatalogExplorationPlot
    properties
        xsec XSection
    end
    methods
        function obj=XSectionExplorationPlot(ax,catalogFcn,xsec)
            obj@CatalogExplorationPlot(ax, catalogFcn);
            obj.xsec = xsec;
            obj.y_by='Z'; 
            obj.x_by='DistAlongStrike';
        end
        function scatter(obj, tag, varargin)
            % scatter plot
            obj.scatter@CatalogExplorationPlot(tag, varargin);
            obj.fix_alongstrike_axis();
            obj.ax.YDir='reverse';    
            obj.ax.XAxis.Color=obj.xsec.Color .* 0.5;
            obj.ax.YAxis.Color=obj.xsec.Color .* 0.5;
            obj.ax.Title.String=sprintf('Profile: %s to %s',obj.xsec.StartLabel,obj.xsec.EndLabel);
        end
        function update(obj, varargin)
            % updates the cross section plot
            obj.update@CatalogExplorationPlot(varargin{:})
            obj.ax.XAxis.Color=obj.xsec.Color .* 0.5;
            obj.ax.YAxis.Color=obj.xsec.Color .* 0.5;
            obj.fix_alongstrike_axis(varargin{:})
        end
        
    end % METHODS
    methods(Hidden)
        function fix_alongstrike_axis(obj,specific)
            % embarrassingly (because it is a one-off), this just changes the names for axes
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
            if (isempty(specific) || specific == "x_by") && obj.x_by == "DistAlongStrike"
                modify_axis('XLim','XLabel','XTick','XTickLabel');
            end
            if (isempty(specific) || specific == "y_by") && obj.y_by == "DistAlongStrike"
                modify_axis('YLim','YLabel','YTick','YTickLabel');
            end
            if (isempty(specific) || specific == "z_by") && obj.z_by == "DistAlongStrike"
                modify_axis('ZLim','ZLabel','ZTick','ZTickLabel');
            end
 

            function modify_axis( xyzlim, xyzlabel, xyztick, xyzticklabel)
                % make the plot pretty.
                obj.ax.(xyzlabel).String=['Dist along strike [',shortenLengthUnit(obj.xsec.LengthUnit),']'];
                obj.ax.(xyzlim)=[0 obj.xsec.Extent];
                if obj.ax.(xyztick)(1) ~=0
                    obj.ax.(xyztick)=[0 obj.ax.(xyztick)];
                end
                obj.ax.(xyzticklabel)(1)={['\bf' obj.xsec.StartLabel]};
                if obj.ax.(xyztick)(end) ~= obj.xsec.Extent
                    obj.ax.(xyztick)(end+1)= obj.xsec.Extent;
                end
                %\bf makes it bold, and assumes interpreter TEX
                obj.ax.(xyzticklabel)(length(obj.ax.(xyztick)))={['\bf' obj.xsec.EndLabel]};
            end
        end
    end
            
end