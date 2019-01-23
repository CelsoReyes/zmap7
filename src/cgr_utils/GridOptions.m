classdef GridOptions < handle
    properties
        dx {isfinite}                           % east-west distance between grid points
        dy                                      % north-south distance between grid points
        dz                                      % vertical distance between grid points
        horizUnits          char       = 'kilometer'
        dzUnits             char       = 'kilometer'
        % Defines whether horizontal distances are constant, or whether they scale as the grid
        % deviates from the equator. 
        followMeridians     matlab.lang.OnOffSwitchState                = 'off'
        gridEntireArea      matlab.lang.OnOffSwitchState                = 'off'
        FixedAnchorPoint    double                                      = []
        % grid cannot be used past these limits [xmin xmax ymin ymax]
        AbsoluteGridLimits  double                                      = [-180 180 -90 90] 
        GridType            GridTypes = 'XY';
        CoordinateSystem CoordinateSystems
    end
    
    methods
        function obj = GridOptions(coordinate_system, grid_type, dx_dy_dz, spatial_units, gridEntireArea)
            % old usage: obj = GridOptions(dx, dy, dz_km, horiz_units, follow_meridians, gridEntireArea)
            % GRIDOPTIONS defines parameters that are used to create ZmapGrids
            % obj = GRIDOPTIONS( [dx,dy,dz], UNITS);
            % obj = GRIDOPTIONS( [dx,dy,dz], ELLPSOID ) units are used from the reference ellipsoid
            %
            % obj = GRIDOPTIONS( [dx,dy,dz], 'FollowMeridians') Horizontal Units are assumed to be
            %       degrees, Vertical units are assumed to be kilometers.
            % 
            % obj = GRIDOPTIONS(...,'GridEntireArea') grids entire area.
            %
            % For a horizontal grid, the first parameter should be [dx, dy] or [dx,dy,nan]
            % For a cross-sectional grid, the first parameter should be [dS nan dz], where dS is
            % a linear distance.
            % For a 3-d grid, the first parameters should be [dx,dy,dz]
            %
            %  see also ZmapGrid, referenceEllipsoid
            
            
            narginchk(4,5);
            obj.CoordinateSystem = coordinate_system;
            obj.GridType = grid_type;
            switch grid_type
                case 'XY'
                    obj.dx = dx_dy_dz(1);
                    obj.dy = dx_dy_dz(2);
                    obj.dz = 1;
                    
                case 'XZ'
                    obj.dx = dx_dy_dz(1);
                    obj.dy = nan;
                    obj.dz = dx_dy_dz(end);
                    
                case 'XYZ'
                    obj.dx = dx_dy_dz(1);
                    obj.dy = dx_dy_dz(2);
                    obj.dz = dx_dy_dz(3);
            end
            obj.followMeridians = ischarlike(spatial_units) && spatial_units=="FollowMeridians";
            if isa(spatial_units,'referenceEllipsoid')
                obj.horizUnits = spatial_units.LengthUnit;
            elseif obj.followMeridians
                obj.horizUnits = 'degrees';
            else
                obj.horizUnits = spatial_units;
            end
            
            
            obj.gridEntireArea = exist('GridEntireArea','var') && strcmpi(gridEntireArea,'GridEntireArea');
            
            
        end
        
        
    end % methods section
    
    methods(Static)
        function [mygrid, mygridopts] = fromDialog(existing_gridopt, ellipsoid)
            % FROMDIALOG shows an interactive dialog box allowing user to choose grid
            mygrid=[];
            mygridopts=[];
            if ~exist('ellipsoid','var')
                ellipsoid = ZmapGlobal.Data.referenceEllipsoid;
            end
            if exist('existing_gridopt','var') && ~isempty(existing_gridopt)
                gc = grid_chooser(ellipsoid, existing_gridopt); 
            else
                gc = grid_chooser(ellipsoid);
            end
            gc.ResultDump = @set_values;
            waitfor(gc)
            function set_values(g, gop)
                mygrid = g;
                mygridopts = gop;
            end
        end
    end %static methods
end
