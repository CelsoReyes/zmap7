classdef TimeSomethingPlotter < handle
    properties
        LotsOfEvents=100000
        Marker='s'
        Color = [.6 .6 .7]
        MarkerEdgeColor=[0.05 0.05 0.2]
        CFld='Color'
        SizeFcn = @(c)mag2dotsize(c.Magnitude)
        Tags struct
        ax = gobjects(1);
        hpl = gobjects(1);
        hbg = gobjects(1);
    end
    
    properties(SetAccess=immutable)
        YVar char
        YUnits char
    end
    
    methods
        function obj = TimeSomethingPlotter(yv, yunits)
            obj.YVar=yv;
            obj.YUnits=yunits;
            
            obj.Tags=struct();
            obj.Tags.Figure = "time_" + obj.YVar + "_figure";
            obj.Tags.Plot = "time_" + obj.YVar + "_plot";
            obj.Tags.Axes = "time_" + obj.YVar + "_axes";
            obj.Tags.BigEvents = "Large Events";
        end
        
        function tf=hasLotsOfEvents(obj, c)
          tf= ~isempty(c) && c.Count > obj.LotsOfEvents;
        end
        
        
        function prepare_axes(obj,catalog,varargin)
            
            set(obj.ax,'box','on', 'TickDir','out');
            obj.ax.Tag=obj.Tags.Axes;
            obj.ax.Title.String="Time "+ obj.YVar + [' Plot for "' catalog.Name '"'];
            obj.ax.Title.Interpreter='none';
            obj.ax.XLabel.String = 'Date';
            if ~isempty(obj.YUnits)
                obj.ax.YLabel.String = string(obj.YVar) + " ["+obj.YUnits+"]";
            else
                obj.ax.YLabel.String = obj.YVar;
            end
            if ~isempty(varargin)
                set(obj.ax,varargin{:}); % if varargin was empty, then set displays all options for obj.ax
            end
        end
        
        function pl=scatter(obj, catalog, varargin)
            obj.CFld='CData';
            obj.hpl=scatter(obj.ax,NaT,nan,'.','Visible','off',varargin{:});
            if ~isempty(catalog)
                obj.hpl.XData = catalog.Date;
                obj.hpl.YData = catalog.(obj.YVar);
            end
            obj.prettify_plot();
            obj.hpl.Visible='on';
            pl=obj.hpl;
        end
        
        function pl=stem(obj, catalog, varargin)
            obj.CFld='Color';
            obj.hpl=stem(obj.ax, NaT, nan, obj.Marker);
            obj.hpl.Visible='off';
            if ~isempty(varargin)
                set(obj.hpl,varargin{:});
            end
            if ~isempty(catalog)
                obj.hpl.XData = catalog.Date;
                obj.hpl.YData = catalog.(obj.YVar);
            end
            obj.prettify_plot();
            obj.hpl.Visible='on';
            pl=obj.hpl;
        end
        
        function prettify_plot(obj)
            obj.hpl.MarkerEdgeColor = obj.MarkerEdgeColor;
            obj.hpl.Tag = obj.Tags.Plot;
            obj.hpl.DisplayName = 'Events';
            obj.hpl.(obj.CFld) = obj.Color;
        end
        
        
        
        function update(obj, catalog, bigcat)
            if ~exist('bigcat','var')
                bigcat=[];
            end
            obj.hpl.XData=catalog.Date;
            obj.hpl.YData=catalog.(obj.YVar);
            obj.updateBigEvents(bigcat);
        end
        
        
        
        function overlayBigEvents(obj, bigcat)
            %overlayBigEvents plots large events as a different marker
            holdstate=HoldStatus(obj.ax,'on');
            
            if isempty(bigcat)
                obj.hbg=scatter(obj.ax, NaT, nan, 'h','Visible','off');
            else
                obj.hbg=scatter(obj.ax, bigcat.Date, bigcat.(obj.YVar), obj.SizeFcn(bigcat),'h',...
                    'Visible','off');
            end
            
            obj.hbg.MarkerEdgeColor='k';
            obj.hbg.MarkerFaceColor='y';
            obj.hbg.DisplayName=obj.Tags.BigEvents;
            obj.hbg.Tag=obj.Tags.BigEvents;
            
            obj.hbg.Visible='on';
            
            holdstate.Undo();
        end
        
        function updateBigEvents(obj, bigcat)
            if ~isvalid(obj.hbg) && ~isempty(bigcat)
                obj.overlayBigEvents(bigcat)
                return
            end
            
            if isempty(bigcat)
                obj.hbg.XData=NaT;
                obj.hbg.YData=nan;
                obj.hbg.SizeData=nan;
            else
                obj.hbg.XData=bigcat.Date;
                obj.hbg.YData=bigcat.(obj.YVar);
                obj.hbg.SizeData=obj.SizeFcn(bigcat);
            end
        end
        
    end
    
end