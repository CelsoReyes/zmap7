classdef bpvalgrid < ZmapHGridFunction
    % calculate P values on X-Y grid
    properties
        c_initial    double           = 2     % omori c parameter 
        use_const_c  logical    = false
        minpe      double            = nan   % min goodness percentage
        mc_choice  McMethods              = McMethods.MaxCurvature % magnitude of completion method
        wt_auto    LSWeightingAutoEstimate  = true
        mc_auto    McAutoEstimate           = true
        main_event ZmapCatalog
    end
    properties(Constant)
        PlotTag = 'bpvalgrid';
        
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'b_value_wls',  'b-value map (WLS)',    '';...      1 bv
            'Mc_value',     'Mag of completeness',  '';...    2 magco
            'b_value_maxlikelihood',        'b(max likelihood) map',    '';...  6: bv2
            'b_value_std_maxlikelihood',    'Error in b',               '';...             7 {pro} stan2
            'a_value',      'a-value',          '';...                8 av
            'stan',         'est. std predicting future based on A and B','';... stanm9: stan estimate of the std deviation of the error in predicting a future observation at X by A and B
            'power_fit',    'Goodness of fit to power-law', '';... prf
            'p_value',      'p-value',          '';...                11: pv
            'pstd',         'p-val std',        '';...              12: pstd
            'c_value',      'c in days',        '';...              14 cv
            'mmav',         'R&J a-value (unadjusted, untrusted)',             '';...      mmav, untrusted
            'k_value',      'kv',               '';...                     kv
            'mbv',          'R&J b-value (unadjusted, untrusted)',              '';...     mbv, untrusted
            'deltaB',       'difference in b',  '';...
            'dM',           'Magnitude range map (Mmax - Mcomp)',   ''...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields = {'b_value_wls',    'Mc_value', 'b_value_maxlikelihood',...
            'b_value_std_maxlikelihood','a_value', ...
            'stan',     'power_fit',    'p_value',  'pstd',...
            'c_value',  'mmav',         'k_value',  'mbv'};
        ParameterableProperties = ["c_initial", "use_const_c", "minpe", "mc_choice", "main_event"];
        References="";
    end
    methods
        function obj=bpvalgrid(zap, varargin)
            % CGR_BVALGRID
            % obj = CGR_BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CGR_BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            
            obj@ZmapHGridFunction(zap, 'p_value'); %set default column here
            report_this_filefun();
            
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            zdlg = ZmapDialog();
            
            % TODO: replace this haphazard list with zdlg.AddMcMethodDropdown('mc_choice',      obj.mc_choice);
            Mc_Methods={'Automatic Mcomp (max curvature)',...
            'Fixed Mc (Mc = Mmin)',...
            'Automatic Mcomp (90% probability)',...
            'Automatic Mcomp (95% probability)',...
            'Best (?) combination (Mc95 - Mc90 - max curvature)',...
            'Constant Mc'};

            zdlg.AddPopup('mc_choice', 'Magnitude of Completeness (Mc) method:', Mc_Methods, 5,...
                'Choose the calculation method for Mc');
            
            zdlg.AddMcAutoEstimateCheckbox('mc_auto',  obj.mc_auto);
            
            zdlg.AddCheckbox('use_const_c', 'fixed c',              obj.use_const_c,[],  'keep the Omori C parameter fixed');
            zdlg.AddEdit('c_initial',  'initial omori c parameter', obj.c_initial, 'C-parameter parameter');
            zdlg.AddEdit('minpe',      'min goodness %',            obj.minpe,     'Minimum goodness of fit (percentage)');
            obj.AddDialogOption(zdlg,'EventSelector');
            obj.AddDialogOption(zdlg,'NodeMinEventCount');
            
            zdlg.Create('Name', 'B P val grid','WriteToObj',obj,'OkFcn', @obj.doIt);
        end
        
        function results=Calculate(obj)
            %In the following line, the program selgp.m is called, which creates a rectangular grid from which then selects,
            %on the basis of the vector ll, the points within the selected poligon.
            
            ZG=ZmapGlobal.Data;
            Nmin = obj.NodeMinEventCount;
            minThreshMag = min(obj.RawCatalog.Magnitude);
            
            % get the grid parameter
            % initial values
            mainshock_idx = find(obj.RawCatalog.Magnitude==max(obj.RawCatalog.Magnitude),1,'first');
            mainshock = obj.RawCatalog.subset(mainshock_idx);
            
            ZG.maepi = mainshock;  % TODO remove maepi dependencies from called functions (mypval2m, z.B.)
            
            if ~ensure_mainshock()
                return
            end
            
            % cut catalog at mainshock time:
            obj.RawCatalog = obj.RawCatalog.subset(obj.RawCatalog.Date > mainshock.Date);
            
            % cut cat at selected magnitude threshold
            obj.RawCatalog = obj.RawCatalog.subset(obj.RawCatalog.Magnitude >= minThreshMag);
            
            %%%%%%%
            
            % overall b-value
            [bv, magco, stan, av] =  bvalca3(obj.RawCatalog.Magnitude,obj.mc_auto);
            overall_b_value = bv;
            ZG.overall_b_value = bv;
            
            % 
            mpvc = MyPvalClass;
            mpvc.MinThreshMag = minThreshMag;
            mpvc = mpvc.setMainEvent(mainshock);
            mpvc.c_initial      = obj.c_initial;
            mpvc.UseConstantC   = obj.use_const_c;
            
            %
            mycalcmethods= {@calcguts_opt1,...
                @calcguts_opt2,...
                @calcguts_opt3,...
                @calcguts_opt4,...
                @calcguts_opt5};
            calculation_function = mycalcmethods{obj.mc_choice};
            
            % calculate at all points
            obj.gridCalculations(calculation_function);
            
            % prepare output to desktop
            obj.Result.minpe         = obj.minpe; %min goodness of fit (%)
            
            % ADDITIONAL VALUES
            obj.Result.values.dM     = obj.Result.values.max_mag - obj.Result.values.Mc_value;
            obj.Result.values.deltaB = obj.Result.values.b_value_wls - obj.Result.values.b_value_maxlikelihood;
            
            if nargout
                results = obj.Result.values;
            end
            
            
            % plot the results
            % old and valueMap (initially ) is the b-value matrix
            %
            % gridstats = array2gridstats(bpvg, ll);
            % gridstats.valueMap = gridstats.pvalg;
            
            % View the b-value and p-value map
            % view_bpva(sel, 11) % where sel was the original results
            % one menu option "histogram" called zhist()
            
            
            function bpvg = calcguts_opt1(b)
                [bv, magco, stan, av] =  bvalca3(b.Magnitude, McAutoEstimate.auto);
                maxcat = b.subset(b.Magnitude >= magco-0.05);
                if maxcat.Count  >= Nmin
                    mpvc = mpvc.setEvents(maxcat);
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude, 0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mpvc.mypval2m();
                    
                    bpvg = [bv magco bv2 stan2 av stan nan pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
            
            function bpvg = calcguts_opt2(b)
                [bv, magco, stan, av] =  bvalca3(b.Magnitude, McAutoEstimate.manual);
                [bv2, stan2] = calc_bmemag(b.Magnitude, 0.1);

                mpvc = mpvc.setEvents(b);
                [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mpvc.mypval2m();
                
                bpvg = [bv magco bv2 stan2 av stan nan pv pstd cv mmav kv mbv];
            end
            
            function bpvg = calcguts_opt3(b)
                [~, Mc90, ~, ~, ~]=bvalca3(b.Magnitude, McAutoEstimate.manual);
                maxcat = b.subset(b.Magnitude >= Mc90-0.05);
                magco = Mc90;
                if Nmin <= maxcat.Count
                    mpvc = mpvc.setEvents(maxcat);
                    [bv, ~, stan, av] =  bvalca3(maxcat.Magnitude, McAutoEstimate.manual, overall_b_value );
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude,0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mpvc.mypval2m();
                    bpvg = [bv magco bv2 stan2 av stan prf pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
            
            function bpvg = calcguts_opt4(b)
                [~, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                maxcat= b.subset(b.Magnitude >= Mc95-0.05);
                magco = Mc95;
                if maxcat.Count >= Nmin
                    mpvc = mpvc.setEvents(maxcat);
                    [bv, ~, stan, av] =  bvalca3(maxcat.Magnitude, McAutoEstimate.manual);
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude,0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mpvc.mypval2m();
                    
                    bpvg = [bv magco bv2 stan2 av stan prf pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
            
            function bpvg = calcguts_opt5(b)
                [Mc90, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                if ~isnan(Mc95)
                    magco = Mc95;
                elseif ~isnan(Mc90)
                    magco = Mc90;
                else
                    [bv, magco, stan, av] =  bvalca3(b.Magnitude,McAutoEstimate.auto);
                end
                maxcat= b.subset(b.Magnitude >= magco-0.05);
                if maxcat.Count  >= Nmin
                    mpvc = mpvc.setEvents(maxcat);
                    [bv, ~, stan, av] =  bvalca3(maxcat.Magnitude, McAutoEstimate.manual);
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude,0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mpvc.mypval2m();
                    bpvg = [bv magco bv2 stan2 av stan prf pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
        end
        
        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
        end
    end
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'p- and b-value map';
            h =  uimenu(parent, 'Label', label,...
                MenuSelectedField(), @(~,~)XYfun.bpvalgrid(zapFcn()),...
                varargin{:});
        end
    end
end

%{
function my_load()
        % Load exist b-grid
        [file1,path1] = uigetfile('*.mat','b-value gridfile');
        if length(path1) > 1
            
            gridstats=load_existing_bgrid(fullfile(path1, file1));
            view_bpva(lab1,gridstats.valueMap)
        else
            return
        end
    end
%}
