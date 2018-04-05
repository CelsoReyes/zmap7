classdef simple_ZmapHGridFunction < ZmapHGridFunction
    properties
        depth_km (1,1) double = 5 % default depth
    end
    
    properties(Constant)
        ReturnDetails= {... VariableNames, VariableDescriptions, VariableUnits
            'nEvents_top','number of events in top layer','';...
            'mean_mag_top','mean magnitude of events in top layer','mag';...
            'nEvents_bottom','number of events in bottom layer','';...
            'mean_mag_bottom','mean magnitude of events in bottom layer','mag';...
            'ratio','number of events in top to bottom',''...
            }
            
        % CalcFields is the label for each column coming out of the Calculate function
        % and should match items first column of ReturnDetails
        CalcFields = {'nEvents_top','mean_mag_top','nEvents_bottom','mean_mag_bottom'};
        
        PlotTag = 'my_simple_plot';
    end

    methods
        function obj=simple_ZmapHGridFunction(zap, depth_in_km)
            obj@ZmapHGridFunction(zap, 'shallow_mag');
            if nargin < 2 
                obj.InteractiveSetup();
            else
                obj.depth_km = depth_in_km;
                obj.do_It();
            end
        end
        
        function InteractiveSetup(obj)
            %as your user for their details here
            % see also ZmapDialog
            
            zdlg = ZmapDialog();
            zdlg.AddBasicEdit('depth_km','Enter Depth [km]', depth, 'Enter depth for comparison');
            zdlg.AddEventSelectionParameters('evsel', obj.EventSelector)
            [res,okPressed] = zdlg.Create('b-Value Grid Parameters');
            
            if ~okPressed
                return
            end
            
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj,res)
            % all results are in a structure "res" that has fields matching the first parameter
            % of each item added to the ZmapDialog
            obj.depth_km = res.depth_km;
            obj.EventSelector=res.evsel;
        end
        
        function results=Calculate(obj)
            
            % this is where the magic happens. The results of the calculation will be
            % stored in a obj.Result.values as a table.
            obj.gridCalculations(@calculation_function, @calc_additional_results);
            
            
            % stash values that are NOT grid dependent, but would be useful to recreate calculation 
            obj.Result.depth_km = obj.depth_km; 
            if nargout
                results=obj.Result.values;
            end
            
            function out=calculation_function(catalog)
                % this is called for each point in the grid
                % because it is a sub-function of calculate, it has access to all of Calculate's variables.
                inTop=catalog.Depth >= obj.depth_km;
                meanTopMag = mean(catalog.Magnitude(inTop));
                meanBotMag = mean(catalog.Magnitude(~inTop));
                nTop = sum(inTop);
                nBot = sum(~inTop);
                out = [nTop meanTopMag nBot meanBotMag];
            end
            
            function rslt=calc_additional_results(rslt)
                % This is where you would add additional calculated values.
                % rslt will be a table with fields that match the first column of ReturnDetails,
                % plus some automatcally added fields
                rslt.ratio = rslt.nEvents_top / rslt.nEvents_bottom;
            end
        end
        
        
    end
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item that knows how to call this function with all the required parameters
            % such as grid, catalog, and event selection.
            label='Examine magnitudes above and below a level';
            h=uimenu(parent,'Label',label,MenuSelectedFcnName(), @(~,~)simple_ZmapHGridFunction(zapFcn()));
        end
    end
end