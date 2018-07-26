classdef AnalysisPoint < handle
    properties
        ax
        eventCircleProps={'LineStyle','-.','Color',[.75 .75 .75], 'LineWidth',1.5}
        clickLocProps={'LineStyle','--','Color',[.75 .75 .75], 'LineWidth',0.5,'HitTest','off'}
    end
    
    
    methods
        function obj = AnalysisPoint(ax)
            obj.ax=ax;
        end
        
        function c = color(obj, tagID)
        	h = findobj(obj.ax,'Tag',tagID);
        	dataLengths = arrayfun(@(x)numel(x.XData),h);
            c=get(h(dataLengths==1),'Color');
        end
           
            
        function add_point(obj,clickPos, tb, tagID, varargin)
            % tb is a single line of the table
            
            %unwrap varargin if it is a single thing
            if numel(varargin)==1 && iscell(varargin)
                varargin=varargin{1};
            end
            
            axx = clickPos(1);
            axy = clickPos(2);
            
            
            h = findobj(obj.ax,'Tag',tagID);
            if isempty(h)
                hold(obj.ax,'on');
                
                marker=varargin{find(strcmpi(varargin(1:2:end),'Marker')).*2};
                
                % plot line from click location to position in table
                h(1)=line(obj.ax,[axx ; tb.x] , [axy;tb.y],...
                    'Tag', tagID, 'Marker', marker, 'PickableParts','none', obj.clickLocProps{:},'DisplayName','do_not_show_in_legend');
                
                % plot selected event circle
                [lat,lon]=scircle1(tb.y,tb.x,km2deg(tb.RadiusKm));
                h(2)=line(obj.ax, lon, lat, obj.eventCircleProps{:},'Tag',tagID,'PickableParts','none','DisplayName','do_not_show_in_legend');
                
                % plot marker in actual location
                h(3)=plot(obj.ax,tb.x,tb.y,varargin{:},'Tag',tagID);
                
                %hold(obj.ax,'off');
                if isempty(findobj(obj.ax,'DisplayName','Sampled Radius'))
                    h(2).DisplayName = 'Sampled Radius';
                end
            else
                dataLengths = arrayfun(@(x)numel(x.XData),h);
                
                myCircle = h(dataLengths>2);
                myLine = h(dataLengths == 2);
                myPoint = h(dataLengths==1);
                
                % modify point marker
                myPoint.XData=tb.x;
                myPoint.YData=tb.y;
                
                % modify line
                myLine.XData=[axx ; tb.x];
                myLine.YData=[axy;tb.y];
                
                % modify selected event circle
                [lat,lon]=scircle1(tb.y,tb.x,km2deg(tb.RadiusKm));
                myCircle.XData=lon;
                myCircle.YData=lat;
            end
        end
        
        function remove_point(obj,tagID)
            myGraphics=findobj(obj.ax,'Tag',tagID);
            delete(myGraphics);
        end
        
    end
end
