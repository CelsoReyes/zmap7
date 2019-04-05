classdef (ConstructOnLoad, Abstract)ZmapCatalogAddon < matlab.mixin.Copyable
    % ZMAPCATALOGADDON is a base class for add-ons to a zmap catalog. FOr exaample, Moment Tensors
    properties(Abstract, Constant)
        Type
    end
    
    methods 
        function obj = ZmapCatalogAddon()
        end
        
        function subsetInPlace(obj, idx)
            pef = obj.possibly_empty_fields();
            for ii =1: numel(pef)
                fn = pef{ii};
                if ~isempty(obj.(fn))
                    obj.(fn) = obj.(fn)(idx,:);
                end
            end
        end
        
        function newobj = subset(obj, idx)
            newobj=copy(obj);
            newobj.subsetInPlace(idx)
        end
        
        function disp(obj)
            display_helper(obj)
        end
        
    end
    methods (Abstract, Static, Hidden)
    	pef = possibly_empty_fields()
        s = display_order()
    end
end