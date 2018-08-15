classdef HoldStatus
% allows memory of hold-state, so that that axes can be left in original hold-state
%
% usage
% holdstatus = HoldStatus(gca, 'on') % attach to axes you'll affect and set the status
%  % do something
% holdstatus.Undo();

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
                switch newstate
                case 'on'
                    ax.NextPlot='add';
                case 'off'
                    ax.NextPlot='replace';
                otherwise
                hold(ax,newstate);
                end
            end
        end
        
        function Undo(obj)
            if isempty(obj.ax)
                error('tried to undo empty axis. This shouldn''t be')
            end
            if isvalid(obj.ax)
                if obj.wasHeld
                    obj.ax.NextPlot='add';
                else
                    obj.ax.NextPlot='replace';
                end
            end
        end
    end
end