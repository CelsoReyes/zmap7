classdef bvalgrid < ZmapHGridFunction
    % CGR_BVALGRID Generate a B-value grid
    
    properties 
        % fMcFix                        = 1.0   % 2.2
        nBstSample   {mustBeNonnegative,mustBeInteger}  = 100   % number of bootstrap samples
        useBootstrap logical            = false  % perform bootstrapping?
        fMccorr      double             = 0.2   % magnitude correction
        fBinning     {mustBePositive}   = 0.1   % magnitude bins
        mc_choice    McMethods          = McMethods.MaxCurvature % magnitude of completion method
        mc_auto_est  McAutoEstimate     = McAutoEstimate.auto
    end
    
    properties(Constant)
        PlotTag='bvalgrid'
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'Mc_value'      , 'Magnitude of Completion (Mc)'    , '';...
            'Mc_std'        ,'Std. of Magnitude of Completion'  , '';...
            'b_value'       , 'b-value'                         , '';...
            'b_value_std'   , 'Std. of b-value'                 , '';...
            'a_value'       , 'a-value'                         , '';...
            'a_value_std'   , 'Std. of a-value'                 , '';...
            'power_fit'     , 'Goodness of fit to power-law'    , '';...
            'Additional_Runs_b_std'  , 'Additional runs: Std b-value'   , '';...
            'Additional_Runs_Mc_std' , 'Additional runs: Std of Mc'     , '';...
            'failreason'    , 'reason b-value was nan'                  , '';...
            'nEvents_gt_local_Mc', 'nEvents > local Mc'                 , '';...
            }, 'VariableNames', {'Names','Descriptions','Units'})
            
        
        % fields returned by the calculation. must match column 1 of ReturnDetails
        CalcFields = {'Mc_value', 'Mc_std', 'b_value', 'b_value_std',...
            'a_value', 'a_value_std', 'power_fit',...
            'Additional_Runs_b_std', 'Additional_Runs_Mc_std', 'failreason', 'nEvents_gt_local_Mc'}
        
        ParameterableProperties = ["NodeMinEventCount", "nBstSample", "useBootstrap", "fMccorr",...
            "fBinning", "mc_choice", "mc_auto_est"]
        
        References = "";
    end
    
    methods
        function obj=bvalgrid(zap, varargin)
            % BVALGRID 
            % obj = BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapHGridFunction(zap, 'b_value');
            obj.NodeMinEventCount         =   50;
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            
            checkboxTargets = {'nBstSample', 'nBstSample_label'};
            
            zdlg = ZmapDialog();
            
            zdlg.AddHeader('Choose stuff');
            zdlg.AddMcAutoEstimateCheckbox('mc_auto_est');
            zdlg.AddMcMethodDropdown('mc_choice'); % McMethods.MaxCurvature
            obj.AddDialogOption(zdlg, 'NodeMinEventCount'); 
            zdlg.AddEdit('fMccorr'         , 'Mc correction factor' , obj.fMccorr,...
                'Correction term to be added to Mc');
            zdlg.AddCheckbox('useBootstrap', 'Use Bootstrapping'    , false    , checkboxTargets,...
                'bootstrapping takes longer, but provides more accurate results');
            zdlg.AddEdit('nBstSample'      , 'Number of bootstraps' , obj.nBstSample,...
                'Number of bootstraps to determine Mc');
            obj.AddDialogOption(zdlg,   'EventSelector')
            
            zdlg.Create('Name', 'b-Value Grid Parameters', 'WriteToObj', obj, 'OkFcn', @obj.doIt);
        end
        
        function results = Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the b-value in the grid by sorting the 
            % seismicity and selecting the ni neighbors to each grid point

            % Overall b-value
            bv =  bvalca3(obj.RawCatalog.Magnitude, obj.mc_auto_est); %ignore all the other outputs
            
            obj.ZG.overall_b_value = bv;
            [~, mcCalculator] = calc_Mc([], obj.mc_choice, obj.fBinning, obj.fMccorr);            
            obj.useBootstrap = obj.useBootstrap && obj.nBstSample > 0;
            if obj.useBootstrap
                obj.gridCalculations(@(catalog) do_calculation(catalog, @calculate_boot));
            else
               obj.gridCalculations(@(catalog) do_calculation(catalog, @calculate_noboot));
            end
            
            if nargout
                results = obj.Result.values;
            end
            
            return 
            %%
            
            function out = do_calculation(catalog, calcFcn)       
                % calculate values at a single point
                out = nan(1,11);         
                
                % Added to obtain goodness-of-fit to powerlaw value  
                [~, ~, ~, ~, out(7)] = mcperc_ca3(catalog.Magnitude); 
                Mc_value = mcCalculator(catalog);
                
                idx = catalog.Magnitude >= Mc_value-(obj.fBinning/2);
                nEvents_gt_local_mc = sum(idx);
                
                out(11) = nEvents_gt_local_mc;
                
                if nEvents_gt_local_mc >= obj.NodeMinEventCount
                    out = calcFcn(catalog, idx, out); % runs either calculation_function_boot or calculation_function_noboot
                else
                    out(10) = 1;
                end
            end
            
            function out = calculate_boot(catalog, idx, out)
                [   out(1), out(2), ... % Mc      , Mc_std
                    out(3), out(4), ... % b-value , b-value std
                    out(5), out(6), ... % a-value , a-value std
                    Additional_Runs_b_std,...
                    Additional_Runs_Mc_std] = ...
                    calc_McBboot(catalog.subset(idx), obj.fBinning, obj.nBstSample, obj.mc_choice);
                % where Additiona_Runs_Mc_std = nBoot x [fMeanMag fBvalue fStdDev fAvalue];
                
                out(8) = std(Additional_Runs_b_std);
                out(9) = std(Additional_Runs_Mc_std(:,1));
            end
            
            function out = calculate_noboot(catalog,idx, out)
                [out(3), out(4), out(5)] =  calc_bmemag(catalog.Magnitude(idx), obj.fBinning);
            end
        end
        
        function ModifyGlobals(obj)
            obj.ZG.bvg  = obj.Result.values;
            obj.ZG.Grid = obj.Grid; %TODO do we really write back the grid?
        end
    end % methods
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'Mc, a- and b- value map';
            h =  uimenu(parent, 'Label', label,...
                MenuSelectedField(), @(~,~)XYfun.bvalgrid(zapFcn()),...
                varargin{:});
        end
    end % static methods
    
end %classdef

