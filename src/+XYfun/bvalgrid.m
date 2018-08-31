classdef bvalgrid < ZmapHGridFunction
    % CGR_BVALGRID Generate a B-value grid
    
    properties 
        % fMcFix                        = 1.0   % 2.2
        nBstSample   {mustBeNonnegative,mustBeInteger}  = 100   % number of bootstrap samples
        useBootstrap  logical           = false  % perform bootstrapping?
        fMccorr      double             = 0.2   % magnitude correction
        fBinning     {mustBePositive}   = 0.1   % magnitude bins
        mc_choice    McMethods          = McMethods.MaxCurvature % magnitude of completion method
        mc_auto_est  McAutoEstimate     = McAutoEstimate.auto
    end
    
    properties(Constant)
        PlotTag='bvalgrid';
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'Mc_value',     'Magnitude of Completion (Mc)', '';...
            'Mc_std',       'Std. of Magnitude of Completion', '';...
            'b_value',      'b-value', '';...
            'b_value_std',  'Std. of b-value', '';...
            'a_value',      'a-value', '';...
            'a_value_std',  'Std. of a-value', '';...
            'power_fit',    'Goodness of fit to power-law', '';...
            'Additional_Runs_b_std',  'Additional runs: Std b-value', '';...
            'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', ''
            }, 'VariableNames', {'Names','Descriptions','Units'})
            
        
        % fields returned by the calculation. must match column 1 of ReturnDetails
        CalcFields = {'Mc_value', 'Mc_std', 'b_value', 'b_value_std',...
            'a_value', 'a_value_std', 'power_fit',...
            'Additional_Runs_b_std', 'Additional_Runs_Mc_std'}
        
        ParameterableProperties = ["NodeMinEventCount", "nBstSample", "useBootstrap", "fMccorr", "fBinning", "mc_choice", "mc_auto_est"];
        
        References="";
    end
    
    methods
        function obj=bvalgrid(zap, varargin)
            % BVALGRID 
            % obj = BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapHGridFunction(zap, 'b_value');
            obj.NodeMinEventCount         =   50;
            report_this_filefun();
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            zdlg.AddHeader('Choose stuff');
            zdlg.AddMcAutoEstimateCheckbox('mc_auto_est');
            zdlg.AddMcMethodDropdown('mc_choice'); % McMethods.MaxCurvature
            checkboxTargets= {'nBstSample','nBstSample_label'};
            obj.AddDialogOption(zdlg, 'NodeMinEventCount'); 
            zdlg.AddEdit('fMccorr', 'Mc correction factor',   obj.fMccorr,'Correction term to be added to Mc');
            zdlg.AddCheckbox('useBootstrap',   'Use Bootstrapping',        false,  checkboxTargets ,...
                're takes longer, but provides more accurate results');
            zdlg.AddEdit('nBstSample',         'Number of bootstraps',     obj.nBstSample,...
                'Number of bootstraps to determine Mc');
            obj.AddDialogOption(zdlg,   'EventSelector')
            
            zdlg.Create('Name', 'b-Value Grid Parameters','WriteToObj',obj,'OkFcn', @obj.doIt);
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the b-value in the grid by sorting the 
            % seismicity and selecting the ni neighbors to each grid point

            % Overall b-value
            bv =  bvalca3(obj.RawCatalog.Magnitude, obj.mc_auto_est); %ignore all the other outputs
            
            obj.ZG.overall_b_value = bv;
            [~,mcCalculator]= calc_Mc([], obj.mc_choice, obj.fBinning, obj.fMccorr);
            obj.gridCalculations(@calculation_function);
        
            if nargout
                results=obj.Result.values;
            end
            
            function out=calculation_function(catalog)
                % calculate values at a single point
                
                % Added to obtain goodness-of-fit to powerlaw value
                % [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3(catalog.Magnitude);
                [~, ~, ~, ~, prf]=mcperc_ca3(catalog.Magnitude);
                
                Mc_value = mcCalculator(catalog);
                
                l = catalog.Magnitude >= Mc_value-(obj.fBinning/2);
                
                if sum(l) >= obj.NodeMinEventCount
                    [b_value, b_value_std, a_value] =  calc_bmemag(catalog.Magnitude(l), obj.fBinning);
                    % otherwise, they should be NaN
                else
                    [b_value, b_value_std, a_value] = deal(nan);
                end
                
                % Bootstrap uncertainties FOR EACH CELL
                if obj.useBootstrap
                    % Check Mc from original catalog
                    if sum(l) >= obj.NodeMinEventCount
                        % following line has only b, but maybe should be catalog.subset(l)
                        [Mc_value, Mc_std, ...
                            b_value, b_value_std, ...
                            a_value, a_value_std, ...
                            Additional_Runs_b_std, Additional_Runs_Mc_std] = ...
                            calc_McBboot(catalog, obj.fBinning, obj.nBstSample, obj.mc_choice);
                        % where Additiona_Runs_Mc_std = nBoot x [fMeanMag fBvalue fStdDev fAvalue];
                    else
                        Mc_std=NaN;
                        Mc_value = NaN;
                        a_value_std=NaN;
                        Additional_Runs_b_std=NaN;
                        Additional_Runs_Mc_std=NaN;
                        % fStd_Mc = NaN; fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                    end
                else
                    % Set standard deviation of a-value to NaN;
                    a_value_std= NaN;
                    Mc_std = NaN;
                    Additional_Runs_b_std=NaN;
                    Additional_Runs_Mc_std=NaN;
                end
                
                
                % Result matrix
                out  = [Mc_value Mc_std,...
                    b_value b_value_std a_value a_value_std,...
                    prf std(Additional_Runs_b_std) std(Additional_Runs_Mc_std(:,1))];
                
            end
        end
        
        function ModifyGlobals(obj)
            obj.ZG.bvg  = obj.Result.values;
            obj.ZG.Grid = obj.Grid; %TODO do we really write back the grid?
        end
    end % methods
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Mc, a- and b- value map';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.bvalgrid(zapFcn()));
        end
    end % static methods
    
end %classdef

