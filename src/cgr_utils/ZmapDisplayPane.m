classdef ZmapDisplayPane < handle
    % ZMAPDISPLAYPANE
    %
    % assumes caller has the following methods:
    %
    %   getCatalogUpdates - establish callback used when catalog is modified
    %   getXSectionUpdates - establish callback used when xsections change/add/are deleted
    
    properties
        ax
        Tags
    end
    
    properties(Constant)
        Type = 'zmappane';
    end
    
    methods
        function obj=ZmapDisplayPane(hContainer, hCaller)
            obj.setup(hContainer);
            hCaller.getCatalogUpdates(@obj.updateCatalog);
            hCaller.getXSectionUpdates(@obj.updateXSection);
            hCaller.getBigEventUpdates(@obj.updateBigEvents);
        end
    end
    
    methods(Abstract)
        setup(obj, hContainer);
        updateCatalog(obj, prop, evt);
        updateXSection(obj, prop, evt);
        updateBigEvents(obj, prop, evt);
    end
    
    %{
        
        function updateCatalog(obj,prop,evt)
            val = evt.AffectedObject.(prop.Name);
            cla(obj.ax);
            x = 1:numel(val);
            plot(obj.ax,x,val,'ro');
        end
        function updateXSection(obj, prop, evt)
        end
    %}
end