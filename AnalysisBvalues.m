classdef AnalysisBvalues < AnalysisWindow
    % ANALYSISBVALUES shows b-value plot (FMD)
    properties
        bobj; % points to an existing bobj (bdiff2 object)
    end
    
    
    methods
        function obj = AnalysisBvalues(ax, other_bobj)
            obj@AnalysisWindow(ax);
            obj.nMarkers=2;
            if exist('other_bobj','var')
                obj.bobj = other_bobj;
            end
        end
        
        
        function prepare_axes(obj)
            % label and scale the axes
            obj.ax.Tag          = 'dvBval';
            obj.ax.YScale       = 'log';
            obj.ax.YLim         = [1 10000];
            obj.ax.XLim         = [-inf inf];
            obj.ax.Title.String = 'B-Value';
            obj.ax.XLabel.String= 'Magnitude';
            obj.ax.YLabel.String= '# Events';
        end
        
        function h=add_series(obj, catalog, tagID, varargin)
            % obj.ADD_SERIES(catalog, tagID, [[Name, Value],...])
            % fit line
            xlm=obj.ax.XLimMode;
            xl = obj.ax.XLim;
            
            p=inputParser();
            p.addRequired('tagID', @(x)isstring(tagID)||ischar(tagID));
            p.addParameter('Ypos',0.6);
            p.KeepUnmatched=true;
            p.parse(tagID,varargin{:});
            
            
            countProps = p.Unmatched;
            countProps.LineStyle='none';
            countProps.MarkerIndices='all';
            countProps.LineWidth=1;
            obj.ax.XLimMode='auto';
            
            h=add_series@AnalysisWindow(obj, catalog, tagID, countProps);
            
            obj.ax.XLimMode='Manual';
            
            seriesText=obj.bobj.descriptive_text([]);
            textHandle = findobj('Type','text','-and','-regexp','Tag',[tagID,' txt']);
            xStart = range(xlim(obj.ax))*0.6 + min(xlim(obj.ax));
            if ~isempty(textHandle)
                textHandle.String=seriesText;
                textHandle.Position(1)=xStart;
            else
                logLim = log10(ylim(obj.ax));
                myLogY = p.Results.Ypos * range(logLim)+min(logLim);
                if ~isfield(p.Unmatched,'Color')
                    p.Unmatched.Color=[.2 .2 .2]; 
                end
                text(obj.ax, xStart, 10^myLogY, seriesText,'Color',p.Unmatched.Color .* 0.75,'Tag',[tagID,' txt']);
            end
            
            % maybe each other add_series should contribute to h, too.
            
            % magnitude of completeness point
            %McProps = p.Unmatched; 
            %McProps.DisplayName = '';
            %if ~isfield(McProps,'Color')
            %    McProps.MarkerFaceColor = get(findobj(obj.ax,'Tag',tagID),'Color');
            %else
            %    McProps.MarkerFaceColor = McProps.Color;
            %end
            %add_series@AnalysisWindow(obj, catalog, [tagID ' Mc'], 'UseCalculation',@obj.getMc, McProps);
            
            % linear fit
            lineProps = p.Unmatched; 
            lineProps.LineWidth = 2;
            lineProps.MarkerFaceColor = 'auto';
            lineProps.DisplayName = '';
            lineProps.MarkerIndices=2;
            lineProps.MarkerSize=10;
            add_series@AnalysisWindow(obj, catalog, [tagID, ' line'], 'UseCalculation',@obj.getBvalLine, lineProps);
            obj.ax.XLim=xl;
            obj.ax.XLimMode=xlm;
        end   
        
        function [x,y] = calculate(obj,catalog)
            % Cumulative events by magnitude
            if isempty(catalog)
                x=nan;
                y=nan;
            else
                obj.bobj.RawCatalog=catalog;
                obj.bobj.Calculate();
                x=obj.bobj.mag_bin_centers;
                y=obj.bobj.cum_b_values;
            end
        end
        
        function [x,y] = getMc(obj,~)
            % Determine magnitude of completion. X is magnitude, y is approximately # of events below MC
            if isempty(obj.bobj)
                y=nan;
                x=nan;
            else
                x=obj.bobj.Result.Mc_value;
                y=obj.bobj.cum_b_values(obj.bobj.Result.index_low)*1.5;
            end
        end
        
        function [x,y] = getBvalLine(obj,~)
            % Show the B-value trend line
            if isempty(obj.bobj) || isempty(obj.bobj.Result.mag_zone)
                x=[nan nan];
                y=[nan nan];
            else
                x=obj.bobj.Result.mag_zone([1 end]);
                y=obj.bobj.fitted([1 end]);
            end
        end
        
        function remove_series(obj,tagID)
            % remove  B-value graphical objects associated with this tag
            if iscell(tagID) || isstring(tagID)
                for j=1:numel(tagID)
                    obj.remove_series(tagID{j});
                end
            else
                remove_series@AnalysisWindow(obj,tagID);
                % remove_series@AnalysisWindow(obj,[tagID ' Mc']);
                remove_series@AnalysisWindow(obj,[tagID ' line']);
            end
        end
    end
end
