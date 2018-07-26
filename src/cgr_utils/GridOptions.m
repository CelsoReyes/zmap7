classdef GridOptions < handle
    properties
        dx % east-west distance between grid points
        dy % north-south distance between grid points
        dz % vertical distance between grid points
        dxUnits char {mustBeMember(dxUnits, {'deg','degrees','km','kilometers'})} = 'deg'
        dyUnits char {mustBeMember(dyUnits, {'deg','degrees','km','kilometers'})} = 'deg'
        dzUnits char {mustBeMember(dzUnits, {'km','kilometers'})} = 'km'
        % Defines whether horizontal distances are constant, or whether they scale as the grid
        % deviates from the equator. 
        followMeridians matlab.lang.OnOffSwitchState = 'off'
        gridEntireArea matlab.lang.OnOffSwitchState = 'off'
        FixedAnchorPoint double = []
        AbsoluteGridLimits double = [-180 180 -90 90] % grid cannot be used past these limits [xmin xmax ymin ymax]
    end
    
    properties(Dependent)
        horizUnits;
    end
    
    methods
        function obj = GridOptions(dx, dy, dz_km, horiz_units, follow_meridians, gridEntireArea)
            % GRIDOPTIONS defines parameters that are used to create ZmapGrids
            % obj = GRIDOPTIONS( DX , DY , DZ_KM, HORIZ_UNITS, FOLLOW_MERIDIANS)
            % obj = GRIDOPTIONS(..., GRIDENTIREAREA)
            %
            % deprecated:
            % obj = GRIDOPTIONS(gridopt_struct);
            %
            % see also ZmapGrid
            
            switch nargin
                case {1,2}
                    
                    if isstruct(dx)
                        % incoming struct.
                        gridopt = dx; % rename for better understanding
                        if nargin==2
                            fixedptopts = dy;
                        else
                            fixedptopts.UseFixedAnchorPoint=false; % declaring as a struct
                        end
                        
                        if isfield(gridopt,'dx')
                            obj.dx = gridopt.dx;
                            obj.dy = gridopt.dy;
                            obj.dz = gridopt.dz;
                        elseif isfield(gridopt,'Dx')
                            obj.dx = gridopt.Dx;
                            obj.dy = gridopt.Dy;
                            obj.dz = gridopt.Dz;
                        else
                            error('expected field dx,dy,dz')
                        end
                        
                        if isfield(gridopt,'dx_units')
                            obj.dxUnits = lower(gridopt.dx_units);
                            obj.dyUnits = lower(gridopt.dy_units);
                            obj.dzUnits = lower(gridopt.dz_units);
                        elseif isfield(gridopt,'xyunits')
                            obj.dxUnits = lower(gridopt.xyunits);
                            obj.dyUnits = lower(gridopt.xyunits);
                            obj.dzUnits = 'kilometers';
                        end
                        
                        if isfield(gridopt,'GridEntireArea')
                        obj.gridEntireArea = gridopt.GridEntireArea;
                        end
                        
                        % assume intent is to follow meridians if dx units are in degrees
                        if isfield(gridopt,'FollowMeridians')
                            obj.followMeridians = gridopt.FollowMeridians;
                        else
                            obj.followMeridians = ismember(lower(obj.dxUnits),{"deg","degrees"});
                        end
                        
                        if fixedptopts.UseFixedAnchorPoint
                            obj.FixedAnchorPoint = [fixedptopts.XAnchor, fixedptopts.YAnchor, fixedptopts.ZAnchor];
                        end
                        
                    end
                case {0,3,4}
                    warning(help('GridOptions.GridOptions'));
                    error('Incorrect inputs into GridOptions.');
                    
                otherwise
                    obj.dx = dx;
                    obj.dy = dy;
                    obj.dz = dz_km;
                    obj.horizUnits = horiz_units;
                    
                    obj.followMeridians = matlab.lang.OnOffSwitchState(follow_meridians);
                    if exist('gridEntireArea','var')
                        obj.gridEntireArea = matlab.lang.OnOffSwitchState(gridEntireArea);
                    end
            end
            
        end
        
        function units = get.horizUnits(obj)
            assert(strcmp(obj.dxUnits, obj.dyUnits),'dx and dy units differ');
            units = obj.dxUnits;
        end
        
        function set.horizUnits(obj, units)
            obj.dxUnits = units;
            obj.dyUnits = units;
        end
        
    end % methods section
    
    methods(Static)
        function [mygrid, mygridopts] = fromDialog(existing_gridopt)
            % FROMDIALOG shows an interactive dialog box allowing user to choose grid
            mygrid=[];
            mygridopts=[];
            gc = grid_chooser;
            if exist('existing_gridopt','var')
                gc.GridOpts = existing_gridopt; 
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
