classdef ZmapCatalogSnapshot
    properties
        name char
        catalog_name char
        active_events logical
        sortfield char
        sortdir char
    end
        
    methods
        function obj=ZmapCatalogSnapshot(catalog,filter,sortfield, sortdir)
            obj.name=catalog.Name;
            
            assert(islogical(filter) && numel(filter)==catalog.Count || isnumeric(filter));
            obj.active_events=false(catalog.Count,1);
            obj.active_events(filter)=true;
            
            obj.sortfield = sortfield;
            obj.sortdir = sortdir;
        end
            
    end
end
