classdef CatalogStorage < handle
    properties
        Catalogs struct
    end
    properties(Access=private)
        ValidCatalogList cell
    end
    
    methods
        function obj = CatalogStorage(validcataloglist)
            obj.ValidCatalogList = validcataloglist;
        end
        
        function set(obj, label, val)
            assert(ismember(label, obj.ValidCatalogList),'Unknown Catalog')
            assert(isa(val,'ZmapCatalog'),'This isn''t a catalog')
            obj.Catalogs(1).(label)= val;
        end
        
        function setcopy(obj, label, val)
            obj.set(label, copy(val));
        end
        
        function x = get(obj, label)
            x = obj.Catalogs.(label);
        end
        
        function x = getcopy(obj,label)
            x = copy(obj.Catalogs.(label));
        end
        
        function disp(obj)
            disp(obj.Catalogs)
        end
    end
    
end