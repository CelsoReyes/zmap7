classdef AnalysisBvalues < AnalysisWindow
    properties
        %mcProps={}
        %lineProps={}
        bobj;
    end
    
    
    methods
        function obj = AnalysisBvalues(ax)
            obj@AnalysisWindow(ax);
            obj.nMarkers=2;
        end
        
        
        function prepare_axes(obj)
            obj.ax.Tag = 'dvBval';
            obj.ax.YScale='log';
            obj.ax.YLim=[1 10000];
            obj.ax.XLim=[-inf inf];
            title(obj.ax,'B-Value')
            xlabel(obj.ax,'Magnitude')
            ylabel(obj.ax,'# Events')
        end
        
        function add_series(obj, catalog, tagID, varargin)
            % obj.ADD_SERIES(catalog, tagID, [[Name, Value],...])
            % fit line
            %unwrap varargin if it is a single thing
            if numel(varargin)==1 && iscell(varargin)
                varargin=varargin{1};
            end
            basic_props = varargin;
            add_series@AnalysisWindow(obj, catalog, tagID, basic_props);
            color=get(findobj(obj.ax,'Tag',tagID),'Color');
            color=AnalysisWindow.getProperty(varargin,'Color',color);
            McProps=varargin; McProps(end+1:end+2)={'MarkerFaceColor',color};
            add_series@AnalysisWindow(obj, catalog, [tagID ' Mc'], 'UseCalculation',@obj.getMc,McProps{:});
            lineProps=varargin; lineProps(end+1:end+2)={'LineWidth',2};
            add_series@AnalysisWindow(obj, catalog, [tagID, ' line'], 'UseCalculation',@obj.getBvalLine,lineProps{:});
            
        end   
        
        function [x,y] = calculate(obj,catalog)
            if isempty(catalog)
                x=nan;
                y=nan;
                obj.bobj=[];
            else
                obj.bobj=bdiff2(catalog,false,'noplot');
                x=obj.bobj.magsteps_desc;
                y=obj.bobj.bvalsum3;
            end
        end
        function [x,y] = getMc(obj,~)
            if isempty(obj.bobj)
                y=nan;
                x=nan;
            else
                x=obj.bobj.magsteps_desc(obj.bobj.index_low);
                y=obj.bobj.bvalsum3(obj.bobj.index_low)*1.5;
            end
        end
        function [x,y] = getBvalLine(obj,~)
            if isempty(obj.bobj)|| isempty(obj.bobj.mag_zone)
                x=[nan nan];
                y=[nan nan];
            else
                x=obj.bobj.mag_zone([1 end]);
                y=obj.bobj.f([1 end]);
            end
        end
        
        function remove_series(obj,tagID)
            remove_series@AnalysisWindow(obj,tagID);
            remove_series@AnalysisWindow(obj,[tagID ' Mc']);
            remove_series@AnalysisWindow(obj,[tagID ' line']);
        end
    end
end
