classdef sample_preview < ZmapHGridFunction
    % see sampling
    
    properties 
    end
    
    properties(Constant)
        PlotTag='sampling';
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'min_mag',     'Min Magnitude', '';...
            }, 'VariableNames', {'Names','Descriptions','Units'})
            
        
        % fields returned by the calculation. must match column 1 of ReturnDetails
        CalcFields = {'min_mag'}
        
        ParameterableProperties = ["NodeMinEventCount", "active_col"]
        
        References="";
    end
    
    methods
        function obj=sample_preview(zap, varargin)
            % BVALGRID 
            % obj = sample_preview() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = sample_preview(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapHGridFunction(zap, 'Number_of_Events');
            obj.NodeMinEventCount         =   1;
            report_this_filefun();
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            obj.AddDialogOption(zdlg,   'EventSelector')
            
            zdlg.Create('Name', 'Sampling','WriteToObj',obj,'OkFcn', @obj.doIt);
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the b-value in the grid by sorting the 
            % seismicity and selecting the ni neighbors to each grid point

            obj.gridCalculations(@calculation_function);
        
            if nargout
                results=obj.Result.values;
            end
            
            function out=calculation_function(catalog)
                     out=min(catalog.Magnitude);
            end
        end
        
        function ModifyGlobals(obj)
            %obj.ZG.bvg  = obj.Result.values;
            %obj.ZG.Grid = obj.Grid; %TODO do we really write back the grid?
        end
    end % methods
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'sampling preview';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)XYfun.sample_preview(zapFcn()),...
                varargin{:});
        end
    end % static methods
    
end %classdef

