classdef GridOptions < handle
    properties
        dx              double {isfinite}                   % east-west distance between grid points
        dy              double                              % north-south distance between grid points
        dz              double                              % vertical distance between grid points
        % Defines whether horizontal distances are constant, or whether they scale as the grid
        % deviates from the equator. 
        followMeridians     matlab.lang.OnOffSwitchState                = 'off'
        gridEntireArea      matlab.lang.OnOffSwitchState                = 'off'
        FixedAnchorPoint    double                                      = []
        % grid cannot be used past these limits [xmin xmax ymin ymax]
        AbsoluteGridLimits  (1,4) double
        GridType            GridTypes           = GridTypes.XY;
        RefEllipsoid        referenceEllipsoid
    end
    
    properties(Dependent, Hidden)
        horizUnits
        dzUnits
    end
    
    methods
        function obj = GridOptions(grid_type, dx_dy_dz, RefEllipsoid, varargin)
            % old usage: obj = GridOptions(dx, dy, dz_km, horiz_units, follow_meridians, gridEntireArea)
            % GRIDOPTIONS defines parameters that are used to create ZmapGrids
            %
            % obj = GRIDOPTIONS( GRID_TYPE, [dx,dy,dz], ELLPSOID ) where GRID_TYPE is a GridType,
            % and defines the spatial orientation of the grid.  [dx,dy,dz] are a doublet or triplet 
            % describing the grid spacing, and ELLIPSOID defines how everything will be interpreted.
            % the ellipsoid's LengthUnit determines the units of this grid.  (See the option for
            % FollowMeridians, below). An specifying the Ellipsoid value of nonEllipsoid() will 
            % declare that this is a cartesian grid instead of a geodetic one.
            %
            % obj = GRIDOPTIONS( ..., 'FollowMeridians',true) Horizontal Units are degrees and grid
            % therefore narrows toward the poles.
            % 
            % obj = GRIDOPTIONS(...,'GridEntireArea',true) grids entire area.
            %
            % For a horizontal grid, the first parameter should be [dx, dy] or [dx,dy,nan]
            % For a cross-sectional grid, the first parameter should be [dS nan dz], where dS is
            % a linear distance.
            % For a 3-d grid, the first parameters should be [dx,dy,dz]
            %
            %  see also ZmapGrid, referenceEllipsoid, GridType, nonEllipsoid
            p = inputParser;
            p.addRequired('GridType');
            p.addRequired('dx_dy_dz');
            p.addRequired('RefEllipsoid');
            p.addParameter('FollowMeridians',false);
            p.addParameter('GridEntireArea', false);
            p.parse(grid_type, dx_dy_dz,RefEllipsoid,varargin{:})
            
            obj.GridType = p.Results.GridType;
            obj.RefEllipsoid = p.Results.RefEllipsoid;
            obj.followMeridians = p.Results.FollowMeridians;
            obj.gridEntireArea = p.Results.GridEntireArea;
            
            if iscartesian(obj.RefEllipsoid)
                assert(p.Results.FollowMeridians == false, 'Cannot follow Meridians for a cartesian grid');
            end
            
            switch obj.GridType
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
        end
        
        function u = get.horizUnits(obj) % for backwards compatibility
            if obj.followMeridians
                u = 'degree';
            else
                u = obj.RefEllipsoid.LengthUnit;
            end
        end
        
        function u = get.dzUnits(obj) % for backwards compatibility
            u = obj.RefEllipsoid.LengthUnit;
        end
        
    end % methods section
    
    methods(Static)
        function [mygrid, mygridopts] = fromDialog(existing_gridopt, ellipsoid, shape)
            % FROMDIALOG shows an interactive dialog box allowing user to choose grid
            mygrid=[];
            mygridopts=[];
            if ~exist('ellipsoid','var')
                ellipsoid = getappdata(groot,'ZmapDefaultReferenceEllipsoid');
            end
            
            if ~exist('shape','var')
                shape = ShapeGeneral();
            end
            if exist('existing_gridopt','var') && ~isempty(existing_gridopt)
                gc = grid_chooser(ellipsoid, existing_gridopt,shape); 
            else
                gc = grid_chooser(ellipsoid,[],shape);
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
