classdef AnalysisWindow < handle
    properties
        ax
        prepared=false
        nMarkers=3;
    end
    %properties(Constant)
    %    validMarkers='ox+v^sph.*x'
    %end
    methods
        function obj = AnalysisWindow(ax)
            obj.ax=ax;
        end
        
        function add_series(obj, catalog, tagID, varargin)
            % obj.ADD_SERIES(catalog, tagID, [[Name, Value],...])
            if ~obj.prepared
                obj.prepare_axes();
                obj.prepared=true;
            end
            %unwrap varargin if it is a single thing
            if numel(varargin)==1 && iscell(varargin)
                varargin=varargin{1};
            end 
            assert(~any(strcmpi(varargin(1:2:end),'Tag')), ...
                'Tags are controlled by this class and are not allowed to be specified');
            
            [altcalc,fnd,varargin]=AnalysisWindow.getProperty(varargin,'UseCalculation',@obj.calculate);

            %if isempty(altcalc)
            %[x,y] = obj.calculate(catalog);
            %else
                [x,y]=altcalc(catalog);
            %end
            
            h = findobj(obj.ax,'Tag', tagID, '-and','Type','line');
            marker_indices = round(linspace(1,length(y),obj.nMarkers));
            if isempty(h)
                hold(obj.ax,'on');
                line(obj.ax,x,y,varargin{:},...
                    'DisplayName',catalog.Name,'Tag',tagID,...
                    'MarkerIndices',marker_indices);
                hold(obj.ax,'off');
            else
                h.XData=x;
                h.YData=y;
                if any(marker_indices==0)
                    marker_indices=[];
                end
                h.MarkerIndices=marker_indices;
                set(h,varargin{:});
                h.DisplayName=catalog.Name;
            end
        end
        
        function remove_series(obj,tagID)
            myline=findobj(obj.ax,'Tag',tagID);
            delete(myline);
        end
        
    end
    methods(Abstract)
        prepare_axes(obj)
        [x,y]=calculate(obj,catalog)
    end
    methods(Access=protected, Static)
        function [v,found,strippedC] = getProperty(C,name,defaultval)
            % [v,found,strippedC] = GETPROPERTY(C,name,defaultval)
            % looks for property NAME in cell C. if not found, returns DEFAULTVAL
            flds=C(1:2:end);
            strippedC=C;
            is_the_one=strcmpi(flds,name);
            found=any(is_the_one);
            if found
                valIdx=find(is_the_one,1,'last').*2;
                v=C{valIdx};
                strippedC(valIdx-1:valIdx)=[];
            else
                if exist('defaultval','var')
                    v=defaultval;
                else
                    v=[];
                end
            end
        end
    end
end

