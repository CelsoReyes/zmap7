classdef GridOptions < handle
    properties
        dx % east-west distance between grid points
        dy % north-south distance between grid points
        dz % vertical distance between grid points
        dxUnits char {mustBeMember(dxUnits, {'deg','km'})} = 'deg';
        dyUnits char {mustBeMember(dyUnits, {'deg','km'})} = 'deg';
        dzUnits char {mustBeMember(dzUnits, {'km'})} = 'km';
        % Defines whether horizontal distances are constant, or whether they scale as the grid
        % deviates from the equator. 
        followMeridians matlab.lang.OnOffSwitchState = 'off';
        gridEntireArea matlab.lang.OnOffSwitchState = 'off';
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
                case 1
                    
                    if isstruct(dx)
                        % incoming struct.
                        gridopt = dx; % rename for better understanding
                        
                        obj.dx = gridopt.dx;
                        obj.dy = gridopt.dy;
                        obj.dz = gridopt.dz;
                        
                        obj.dxUnits = gridopt.dx_units;
                        obj.dyUnits = gridopt.dy_units;
                        obj.dzUnits = gridopt.dz_units;
                        
                        obj.gridEntireArea = gridopt.GridEntireArea;
                        
                        % assume intent is to follow meridians if dx units are in degrees
                        obj.followMeridians = matlab.lang.OnOffSwitchState(ismember(lower(obj.dxUnits),{"deg","degrees"}));
                    end
                case {0,2,3,4}
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
