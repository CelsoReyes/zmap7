classdef TimeDepthPlotter < TimeSomethingPlotter
    % Used to create time-depth plots
    
    methods
        function obj=TimeDepthPlotter()
            obj@TimeSomethingPlotter('Depth','km');
        end
        
        function pl=plot(obj,ax,catalog,bigcat)
            % plot plot a time-depth series for this catalog, with symbol sizes representing
            % event size
            % pl = plot(catalog)
            %
            
            if ~exist('ax','var') || isempty(ax)
                f=figure('Name','Time Depth','NumberTitle','off', ...
                    'Tag',obj.Tags.Figure);
                addAboutMenuItem();
                ax=axes(f);
            end
            obj.ax=ax;
            
            if isempty(ax.Tag)
                ax.Tag=obj.Tags.Axes;
            end
            
            ax.Visible = 'off';
            
            if obj.hasLotsOfEvents(catalog)
                obj.Marker='.';
            else
                obj.Marker='s';
            end
            pl=obj.scatter(catalog);
            
            obj.prepare_axes(catalog,'YDir','reverse');
            
            f=ancestor(ax,'figure');
            c=findobj(f,'Tag','TimeDepthContext');
            if isempty(c)
                c=uicontextmenu('Tag','TimeDepthContext');
                uimenu(c,'Label','Use Log Scale',MenuSelectedField(),@(s,~)logtoggle(s,'Y'));
            end
            ax.YLabel.UIContextMenu=c;
            
            if exist('bigcat','var')
                obj.overlayBigEvents(bigcat);
            end
            ax.Visible = 'on';
            
        end
        
    end
end
