classdef ZmapAnalysisPkg
    % ZMAPANALYSISPKG gathers disparate variables together for use in functions
    %
    % Constructor Usage:
    %   obj = ZMAPANALYSISPKG.fromGlobal(catname) retrieve all parameters from the globals, with
    %         the catalog being specified by catname. (eg. 'primeCatalog')
    %
    %   obj = ZmapAnalysisPkg([], catalog, eventparams, grid, shape) all values are provided as
    %         objects of the correct type.  CATALOG should be some sort of ZmapCatalog. EVENTPARAMS
    %         should be a struct containing details on how to choose evnets
    %
    %   obj = ZmapAnalysisPkg(s, catalogField, eventField, gridField, shapeField) retrieve all
    %         values from the structure or object "s".
    %
    %
    %  Items in the Package should be treated as read-only.
    %
    %  see also:
    %   EVENTSELECTIONCHOICE, ZMAPGRID, ZMAPCATALOG, ZMAPXSECTIONCATALOG, SHAPECIRCLE
    %   SHAPEPOLYGON
    
    properties(SetAccess = immutable)
        % can only be set in constructor
        
        Catalog % a ZMapCatalog. Do not change this catalog directly
        % EVENTSEL is a structure containing one or more fields used to map a catalog onto a grid point:
        %   numNearbyEvents, radius_km, useNumNearbyEvents, useEventsInRadius
        %   maxRadiusKm, requiredNumEvents
        EventSel
        Grid % ZmapGrid used to sample at points in space
        Shape % Shape used to mask a catalog
        
    end
    methods
        function obj = ZmapAnalysisPkg(s, catinfo, eventinfo, gridinfo, shapeinfo)
            % ZMAPANALYSISPKG constructor allows one to set the variables
            %   obj = ZmapAnalysisPkg([], catalog, eventparams, grid, shape) all values are provided as
            %         objects of the correct type.  CATALOG should be some sort of ZmapCatalog. EVENTPARAMS
            %         should be a struct containing details on how to choose evnets
            %
            %   obj = ZmapAnalysisPkg(s, catalogField, eventField, gridField, shapeField) retrieve all
            %         values from the structure or object "s".
            
            if isempty(s)
                obj.Catalog = catinfo;
                obj.EventSel = eventinfo;
                obj.Grid = gridinfo;
                obj.Shape = shapeinfo;
            else
                obj.Catalog = s.(catinfo);
                obj.EventSel = s.(eventinfo);
                obj.Grid = s.(gridinfo);
                obj.Shape = s.(shapeinfo);
            end
            
        end
    end
    
    methods(Static)
        function obj = fromGlobal(catname)
            % FROMGLOBAL create the package from the Zmap Globals, using the catalog specified
            %
            % obj = ZMAPANALYSISPKG.FROMGLOBAL(catname)
            %
            % see also ZMAPDATA, ZMAPGLOBAL
            ZG=ZmapGlobal.Data;
            obj=ZmapAnalysisPkg(ZG, catname, 'GridSelector', 'Grid', 'selection_shape');
        end
    end  
end
