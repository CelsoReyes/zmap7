classdef calc_Omoricross < ZmapVGridFunction
    % CALC_OMORICROSS calculate omori parameters (p, c, k) along a cross section
    
    properties
        mc_method       McMethods   = McMethods.FixedMc % this function might only know [' Fixed Mc (Mc = Mmin) | Automatic Mc (max curvature) | EMR-method'];
        bootloops       double      = 50
        learningPeriod  duration    = days(100)
        Nmin            double      = 50
        MainShock       ZmapCatalog
        MainShockSelection char {mustBeMember(MainShockSelection,{'Largest','FirstInGlobal','LargestInXsection'})} = 'Largest'
    end
    
    properties(Constant)
        PlotTag         = 'calc_Omoricross'
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'p_value',      'p-Value','';...
            'p_value std',  'p-value standard deviation','';...
            'c_value',      'c-value','';...
            'c_value std',  'c-value standard deviation','';...
            'k_value',      'k-value','';...
            'k_value std',  'k-value standard deviation','';...
            'model',        'Chosen fitting model','';...
            'p_value2',     'p-Value2 UNUSED(?)','';...
            'p_value2 std', 'p-value2 standard deviation UNUSED(?)','';...
            'c_value2',     'c-value2  UNUSED(?)','';...
            'c_value2 std', 'c-value2 standard deviation UNUSED(?)','';...
            'k_value2',     'k-value UNUSED(?)','';...
            'k_value2 std', 'k-value standard deviation UNUSED(?)','';...
            'KS_Test H',    'KS-Test (H-value) binary rejection criterion at 95% confidence level','';...
            'KS_Test stat', 'KS-Test statistic for goodness of fit','';...
            'KS_Test P_value','KS-Test p-value','';...
            'RMS',          'RMS value for goodness of fit','';...
            ...'Mc_value','Mc value',''...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {'p_value','p_value std', 'c_value','c_value std','k_value','k_value std',...
            'model','p_value2','p_value2 std', 'c_value2','c_value2 std', 'k_value2', 'k_value2 std',...
            'KS_Test H',' KS_Test stat','KS_Test P_value', 'RMS'} % cell array of charstrings, matching into ReturnDetails.Names
        
        ParameterableProperties = ['nBstSample','Nmin','learningPeriod', 'MainShock']; % array of strings matching into obj.Properties
        References="";
    end
    
    methods
        function obj=calc_Omoricross(zap, varargin)
            % CALC_OMORICROSS
            % obj = CALC_OMORICROSS() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CALC_OMORICROSS(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapVGridFunction(zap, 'p_value');
            obj.MainShock = ZG.maepi.subset(1);
            report_this_filefun();
            unimplemented_error()
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            magtype=  ZG.maepi.MagnitudeType(1);
            if isundefined(magtype)
                magtype = "mag";
            end
            
            zdlg.AddHeader(sprintf('starting %s with an %s %g event', ZG.maepi.Date(1),magtype, ZG.maepi.Magnitude(1)));
            
            zdlg.AddMcMethodDropdown('mc_method');
            % original list:  [' Fixed Mc (Mc = Mmin) | Automatic Mc (max curvature) | EMR-method']
            
            zdlg.AddEventSelector('evsel', ZG.GridSelector);
            
            zdlg.AddGridSpacing('gridOpts',1.00,'km',[],'',1.0,'km');
            zdlg.AddDurationEdit('learningPeriod','Learning Period', obj.learningPeriod, '', @days);
            
            zdlg.AddCheckbox('useBootstrap',   'Use Bootstrapping',        true,  {'nBstSample'},...
                're takes longer, but provides more accurate results');
            zdlg.AddEdit('nBstSample',         'Number of bootstraps',     obj.bootloops,...
                'Number of bootstraps to determine Mc');
            zdlg.AddEdit('Nmin','Minimum number of events', obj.Nmin);
            zdlg.AddCheckbox('useEventInXsection','Use first largest event in within cross section as mainshock',false,{},'');
            
            zdlg.Create('Name', 'Omori Parameters [xsec]','WriteToObj', obj,'OkFcn', @obj.doIt);
            
            
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the values in the grid by sorting the
            % seismicity and selecting the appropriate neighbors to each grid point
                        
            if obj.MainShock.Count ~= 1
                error('There must be a single mainshock provided to this function');
            end
            % if fixed magnitude of completeness, request from user
            if obj.mc_method == McMethods.FixedMc
                [~,~,fMcFix] = smart_inputdlg('Fixed Mc input',...
                    struct('prompt','Enter Mc:', 'value', 1.5));
            else
                fMcFix=0;
            end
                        
           [~, mcCalculator] = calc_mc([], obj.mc_method, fBinning, fMcFix);
            
            obj.gridCalculations(@calculation_function); % Workhorse that calls calculation_function
        
            if nargout
                results=obj.Result.values;
            end
            
            % catsave3('calc_Omoricross_orig')
            
            % View the map
            % view_Omoricross(myvalues, mygrid, 'p-value');
            
            
            %% -----
            
            function out=calculation_function(catalog)
                % calulate values at a single point
                % Grid coordinates
                
                fMc = mcCalculator(catalog);
                
                % for some reason this was only associated with radius
                if ~isnan(fMc)
                    catalog = catalog.subset(catalog.Magnitude >= fMc);
                end
                
                % Number of events per gridnode
                nY=catalog.Count;
                
                % Calculate the relative rate change, p, c, k, resolution
                if nY >= Nmin  % enough events?
                    nMod = OmoriModel.pck; % Single Omori law
                    [mResult] = calc_Omoriparams(catalog,obj.learningPeriod, timef, obj.bootloops, ZG.maepi, nMod);
                    
                    % Result matrix
                    out = [...
                        mResult.pval1 mResult.pmeanStd1 ...
                        mResult.cval1 mResult.cmeanStd1...
                        mResult.kval1 mResult.kmeanStd1 ...
                        mResult.nMod ... nY fMaxDist...
                        mResult.pval2 mResult.pmeanStd2 ...
                        mResult.cval2 mResult.cmeanStd2...
                        mResult.kval2 mResult.kmeanStd2...
                        mResult.H...
                        mResult.KSSTAT mResult.P mResult.fRMS ...fMc
                        ];
                else
                    out = [NaN NaN NaN NaN NaN NaN NaN ...
                        ...nY fMaxDist 
                        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ... fMc
                        ];
                end
            end
        end
        
        function ModifyGlobals(obj)
        end
    end
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'omori parameters (p-, k-,c-) [xsec]';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)XZfun.calc_Omoricross(zapFcn()),...
                varargin{:});
        end
        
    end
end
