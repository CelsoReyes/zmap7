classdef HoldStatus

    properties
        wasHeld logical
        ax matlab.graphics.axis.Axes
    end
    methods
        function obj=HoldStatus(ax,newstate)
            assert(isvalid(ax),'axis is invalid!');
            obj.wasHeld=ishold(ax);
            obj.ax=ax;
            if exist('newstate','var')
                hold(ax,newstate);
            end
        end
        
        function Undo(obj)
            if isempty(obj.ax)
                error('tried to undo empty axis. This shouldn''t be')
            end
            if isvalid(obj.ax)
                hold(obj.ax,tf2onoff(obj.wasHeld));
            end
        end
    end
end