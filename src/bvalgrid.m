classdef bvalgrid < ZmapGridFunction
    % CGR_BVALGRID Generate a B-value grid
    
    properties
        Nmin = 50
        fMcFix=1.0  %2.2
        nBstSample=100
        useBootstrap  % perform bootstrapping?
        fMccorr = 0.2  % magnitude correction
        fBinning = 0.1  % magnitude bins
        mc_choice
    end
    
    properties(Constant)
        PlotTag='myplot';
        ReturnDetails = { ... VariableNames, VariableDescriptions, VariableUnits
            'Mc_value', 'Magnitude of Completion (Mc)', '';...
            'Mc_std', 'Std. of Magnitude of Completion', '';...
            'x', 'Longitude', 'deg';...
            'y', 'Latitude', 'deg';...
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';...
            'b_value', 'b-value', '';...
            'b_value_std', 'Std. of b-value', '';...
            'a_value', 'a-value', '';...
            'a_value_std', 'Std. of a-value', '';...
            'power_fit', 'Goodness of fit to power-law', '';...
            'max_mag', 'Maximum magnitude at node', 'mag';...
            'Additional_Runs_b_std', 'Additional runs: Std b-value', '';...
            'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', '';...
            'Number_of_Events', 'Number of events in node', ''...
            };
    end
    
    methods
        function obj=bvalgrid(zap, varargin)
            % CGR_BVALGRID 
            % obj = CGR_BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CGR_BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            report_this_filefun(mfilename('fullpath'));
            
            obj@ZmapGridFunction(zap, 'b_value');
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            if nargin<2
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                % run this function without human interaction
                obj.doIt();
            end
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            % if autoCalculate, then do the calculation immediately.
            % if autoPlot, then plot results immediately after calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            zdlg.AddBasicHeader('Choose stuff');
            zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',calc_Mc(),1,...
                'Choose the calculation method for Mc');
            zdlg.AddBasicCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
                're takes longer, but provides more accurate results');
            zdlg.AddBasicEdit('nBstSample','Number of bootstraps', obj.nBstSample,...
                'Number of bootstraps to determine Mc');
            zdlg.AddBasicEdit('Nmin','Min. No. of events > Mc', obj.Nmin,...
                'Min # events greater than magnitude of completeness (Mc)');
            zdlg.AddBasicEdit('fMccorr', 'Mc correction for MaxC',obj.fMccorr,...
                'Correction term to be added to Mc');
            
            [res,okPressed] = zdlg.Create('b-Value Grid Parameters');
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            % called when the dialog's OK button is pressed
            
            obj.Nmin=res.Nmin;
            obj.nBstSample=res.nBstSample;
            obj.fMccorr=res.fMccorr;
            obj.mc_choice = res.mc_choice;
            %obj.ZG.inb1=res.mc_choice;
            obj.useBootstrap=res.useBootstrap;
        end
        
        function CheckPreconditions(obj)
            % check to make sure any important conditions are met.
            % for example,
            % - catalogs have what are expected.
            % - required variables exist or have valid values
            
            assert(~isempty(obj.Grid), 'No grid exists. please create one first');
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the b-value in the grid by sorting the 
            % seimicity and selecting the ni neighbors to each grid point

            % Overall b-value
            bv =  bvalca3(obj.RawCatalog.Magnitude, obj.mc_choice); %ignore all the other outputs of bvalca3
            
            obj.ZG.bo1 = bv;
            
            obj.gridCalculations(@calculation_function, 14);
        
            if nargout
                results=obj.Result.values;
            end
            
            function out=calculation_function(catalog)
                % calulate values at a single point
                
                % Added to obtain goodness-of-fit to powerlaw value
                % [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3(catalog.Magnitude);
                [~, ~, ~, ~, prf]=mcperc_ca3(catalog.Magnitude);
                
                [Mc_value] = calc_Mc(catalog, obj.mc_choice, obj.fBinning, obj.fMccorr);
                l = catalog.Magnitude >= Mc_value-(obj.fBinning/2);
                
                if sum(l) >= obj.Nmin
                    [b_value, b_value_std, a_value] =  calc_bmemag(catalog.subset(l), obj.fBinning);
                    % otherwise, they should be NaN
                else
                    [b_value, b_value_std, a_value] = deal(nan);
                end
                
                % Bootstrap uncertainties FOR EACH CELL
                if obj.useBootstrap
                    % Check Mc from original catalog
                    if sum(l) >= obj.Nmin
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
                        %fStd_Mc = NaN; fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                    end
                else
                    % Set standard deviation ofa-value to NaN;
                    a_value_std= NaN;
                    Mc_std = NaN;
                    Additional_Runs_b_std=NaN;
                    Additional_Runs_Mc_std=NaN;
                end
                
                mab = max(catalog.Magnitude);
                if isempty(mab); mab = NaN; end
                
                % Result matrix
                out  = [Mc_value Mc_std nan nan, ... nan's were x and y
                    nan b_value b_value_std a_value a_value_std,... was rd
                    prf mab std(Additional_Runs_b_std) std(Additional_Runs_Mc_std(:,1)) nan]; % nan was nX
                
            end
        end
        
        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
            obj.ZG.Grid = obj.Grid; %TODO do we really write back the grid?
        end
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Mc, a- and b- value map';
            h=uimenu(parent,'Label',label,'Callback', @(~,~)bvalgrid(zapFcn()));
        end
    end % static methods
    
end %classdef

