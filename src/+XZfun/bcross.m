classdef bcross < ZmapVGridFunction
    % BCROSS calculate b-values along a cross section
    properties
        nBstSample   {mustBeNonnegative,mustBeInteger}  = 100   % number of bootstrap samples
        useBootstrap logical            = false  % perform bootstrapping?
        fMccorr      double             = 0.0   % magnitude correction
        fBinning     {mustBePositive}   = 0.1   % magnitude bins
        mc_choice    McMethods          = McMethods.MaxCurvature % magnitude of completion method
        mc_auto_est  McAutoEstimate     = McAutoEstimate.auto
        
    end
    
    properties(Constant)
        PlotTag         = 'bcross'
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
        
        
        CalcFields = {'Mc_value', 'Mc_std', 'b_value', 'b_value_std',...
            'a_value', 'a_value_std', 'power_fit',...
            'Additional_Runs_b_std', 'Additional_Runs_Mc_std', 'failreason', 'nEvents_gt_local_Mc'}
        
        ParameterableProperties = ["NodeMinEventCount", "nBstSample", "useBootstrap", "fMccorr",...
            "fBinning", "mc_choice", "mc_auto_est"];
        References = ""
    end
    
    methods
        function obj=bcross(zap, varargin)
            % BCROSS
            % obj = BCROSS() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CBCROSS(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapVGridFunction(zap, 'b_value');
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
            
            zdlg.AddMcMethodDropdown('mc_choice');
            zdlg.AddEdit('fBinning'         , 'Magnitude binning'       , obj.fBinning,...
                'Bins for magnitudes');
            obj.AddDialogOption(zdlg, 'NodeMinEventCount');
            zdlg.AddEdit('fMccorr'          , 'Mc correction factor'    , obj.fMccorr,...
                'Correction term to be added to Mc');
            zdlg.AddCheckbox('useBootstrap' , 'Use Bootstrapping'       , false, checkboxTargets,...
                'bootstrapping takes longer, but provides more accurate results');
            zdlg.AddEdit('nBstSample'       , 'Number of bootstraps'    , obj.nBstSample,...
                'Number of bootstraps to determine Mc');
            
            zdlg.Create('Name', 'b-Value XSec Parameters', 'WriteToObj', obj, 'OkFcn', @obj.doIt);
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
                [~, ~, ~, out(7)] = mcperc_ca3(catalog.Magnitude);
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
        
        % view_bv2([],valueMap) % view the b-value map
        
        function ModifyGlobals(obj)
            obj.ZG.bvg  = obj.Result.values;
        end
    end
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'b-value [xsec]';
            h = uimenu(parent, 'Label', label, ...
                'MenuSelectedFcn', @(~,~)XZfun.bcross(zapFcn()),...
                varargin{:});
        end
    end
end

%{
function bcross_orig(sel)
    % This subroutine  creates a grid with
    % spacing dx,dy (in degreees). The size will
    % be selected interactively or grids the entire cross section.
    % The b-value in each volume is computed around a grid point containing ni earthquakes
    % or in between a certain radius
    % The standard deviation is calcualted either with the max. likelihood or by bootstrapping, when that box is checked.
    % If not, both options can be assigned by the additional run assignment.
    % Standard deviation of b-value in non-bootstrapping case is calculated from Aki-formula!
    % Org: Stefan Wiemer 1/95
    % updated: J. Woessner, 02.04.2005
    
    % JW: Removed Additional random runs for uncertainty determination since
    % this is incorporated in new functions to determine Mc and B with
    % bootstrapping
    
    ZG=ZmapGlobal.Data
    report_this_filefun();
    error('Update this file to the new catalog')
    if ~exist('sel','var'), sel='in',end
    
    
    switch sel
        case 'load'
            myload()
            return
    end
    
    
    % Do we have to create the dialogbox?
    % Set the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    bv2 = NaN;
    Nmin = 50;
    stan2 = NaN;
    stan = NaN;
    prf = NaN;
    av = NaN;
    %nRandomRuns = 1000;
    bGridEntireArea = false;
    nBstSample = 100;
    fMccorr = 0;
    fBinning = 0.1;
    bBst_button = false;
    fMcFix = 1.5;
    
    
    
    %% make the interface
    %{
    zdlg = ZmapDialog();
    %zdlg = ZmapDialog(obj, @obj.doIt);
    
    zdlg.AddHeader('Choose stuff');
    zdlg.AddMcMethodDropdown('mc_choice');
    zdlg.AddGridSpacing('gridOpts',dx,'km',[],'',dd,'km');
    zdlg.AddEventSelector('eventSelector',obj.EventSelector);
    
    zdlg.AddEdit('fBinning','Magnitude binning', fBinning,...
        'Bins for magnitudes');
    zdlg.AddCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
        're takes longer, but provides more accurate results');
    zdlg.AddEdit('nBstSample','Number of bootstraps', nBstSample,...
        'Number of bootstraps to determine Mc');
    zdlg.AddEdit('Nmin','Min. No. of events > Mc', Nmin,...
        'Min # events greater than magnitude of completeness (Mc)');
    zdlg.AddEdit('fMcFix', 'Fixed Mc',fMcFix,...
        'fixed magnitude of completeness (Mc)');
    zdlg.AddEdit('fMccorr', 'Mc correction factor',fMccorr,...
        'Correction term to be added to Mc');
    
    [res,okPressed] = zdlg.Create('Name', 'b-Value X-section Grid Parameters');
            
    if ~okPressed
        return
    end
    hndl2=res.mc_choice;
    dx = res.gridOpts.dx;
    dd = res.gridOpts.dz;
    tgl1 = res.eventSelector.UseNumClosestEvents;
    tgl2 = ~tgl1;
    ni = res.eventSelector.NumClosestEvents;
    ra = res.eventSelector.RadiusKm;
    Nmin = res.eventSelector.requiredNumEvents;
    bGridEntireArea = res.gridOpts.GridEntireArea;
    bBst_button = res.useBootstrap;
    nBstSample = res.nBstSample;
    fMccorr = res.fMccorr;
    fBinning = res.fBinning;
    
        mycalculate();
    %}
    
    %tgl1 : use Number of Events
    %tgl2 : use Constant Radius
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selecting the ni neighbors
    % to each grid point
    
    % Load exist b-grid
    function myload()
        [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            xsecx = newa(:,end)';
            xsecy = newa(:,7);
            xvect = gx; yvect = gy;
            tmpgri=zeros((length(xvect)*length(yvect)),2);
            
            
            normlap2=NaN(length(tmpgri(:,1)),1); % no longer used(?)
            % initialize a few matrices
            [magComp, McStdDev, mRadRes, b_value, mStdB, a_value, mStdA, fitToPowerlaw, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
            % replace the indexed values within
            
            magComp(ll) = bvg(:,1);         % Magnitude of completness
            McStdDev(ll) = bvg(:,2);       % Standard deviation Mc
            mRadRes(ll) = bvg(:,5);     % Radius resolution
            b_value(ll) = bvg(:,6);      % b-value
            mStdB(ll) = bvg(:,7);        % Standard deviation b-value
            a_value(ll)= bvg(:,8);      % a-value M(0)
            mStdA(ll) = bvg(:,9);        % Standard deviation a-value
            fitToPowerlaw(ll) = bvg(:,10);       % Goodness of fit to power-law map
            ro(ll) = bvg(:,11);          % Whatever this is
            mNumEq(ll) = bvg(:,12);     % number of events
            
            valueMap = b_value;
            
            nlammap
            globalcatalog = ZG.primeCatalog;
            [xsecx xsecy,  inde] =mysect(globalcatalog.Y',globalcatalog.X',globalcatalog.Z,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            set(gca,'NextPlot','add')
            plot(newgri(:,1),newgri(:,2),'+k')
            view_bv2([],valueMap)
        else
            return
        end
    end
end

%}