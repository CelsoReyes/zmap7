classdef rcvalgrid_a2 < ZmapHGridFunction
    % RCVALGRID_A2 Calculates relative rate change map, p-,c-,k- values and standard deviations after model selection by AIC
    % Uses view_rcva_a2 to plot the results
    
    properties
        bootloops           = 100       % number of bootstrap loops [bootloops]
        forec_period duration      = days(20)  % forecast period [forec_period]
        learn_period duration       = days(47)  % learning period  [learn_period]
        addtofig logical    = false     % should this plot in current figure? [oldfig_button]
        minThreshMag        = 0
    end
    properties(Constant)
        PlotTag         ='rcvalgrid_a2'
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'learn_period',     'learning period','days';...                #1
            'absdiff',  'obs. aftershocks - #events in modeled forecast period','';... #2
            'numreal',  'observed # aftershocks',''; ...            #3
            'nummod',   '#events in modeled forecast period','';... #4
            ...  p,c,k- values for period before large aftershock or just modified Omori law
            'pval1',    'p-value','';...                        #5 [mPval]
            'pmedStd1', 'p-value standard deviation', '';...    #6 [mPvalstd]
            'cval1',    'c-value','';...                        #7 [mCval]
            'cmedStd1', 'c-value standard deviation','';...     #8 [mCvalstd]
            'kval1',    'k-value','';...                        #9 [mKval]
            'kmedStd1', 'k-value standard deviation','';...     #10 [mKvalstd]
            ... Resolution parameters
            'fStdBst',  '',''; ... #11 [?]
            'nMod',     'Chosen fitting model', '';...                  #12 [mMd]
            'nY',       'Number of events per grid node', '';...        #13 [mNumevents]
            'fMaxDist', 'Radii of chosen events, Resolution', '';...    #14 [vRadiusRes]
            'fRcBst',   'Relative rate change (bootstrap)','';...       #15 [mRelchange]
            ... p,c,k- values for period AFTER large aftershock
            'pval2',    'p-value (after large aftershock)','';...           #16 [mPval2]
            'pmedStd2', 'p-value std dev (after large aftershock)','';...   #17 [mPvalstd2]
            'cval2',    'c-value (after large aftershock)','';...           #18 [mCval2]
            'cmedStd2', 'c-value std dev (after large aftershock)','';...   #19 [mCvalstd2]
            'kval2',    'k-value (after large aftershock)','';...           #20 [mKval2]
            'kmedStd2', 'k-value std dev (after large aftershock)','';...   #21 [mKvalstd2]
            'H',        'KS-Test (H-value) binary rejection criterion at 95% confidence level','';...#22 [mKstestH]
            'KSSTAT',   'KS-Test statistic for goodness of fit','';...      #23 [mKsstat]
            'P',        'KS-Test p-value','';...                            #24 [mKsp]
            'fRMS',     'RMS value for goodness of fit','';...              #25 [mRMS]
            'fTBigAf',  'Times of secondary afterhsock',''...               #26 [mBigAf]
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {...
            'learn_period',     'absdiff',  'numredal', 'nummod',...
            'pval1',    'pmedStd1', 'cval1',    'cmedStd1',...
            'kval1',    'kmedStd1', 'fStdBst',  'nMod',...
            'nY',       'fMaxDist', 'fRcBst',...
            'pval2',    'pmedStd2', 'cval2',    'cmedStd2',...
            'kval2',    'kmedStd2', 'H',        'KSSTAT',...
            'P',        'fRMS',     'fTBigAf'}
        
        ParameterableProperties = ["bootloops" "forec_period"....
                "learn_period" "addtofig"...
                "NodeMinEventCount" "minThreshMag"];
            
        References="";
    end
    methods
        function obj=rcvalgrid_a2(zap,varargin)
            
            obj@ZmapHGridFunction(zap, 'fRcBst'); % rfRcBst is rate change
            report_this_filefun();
           
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            
            zdlg = ZmapDialog();
            
            %zdlg.AddPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',McMethods.dropdownList(),double(McMethods.MaxCurvature),...
            %    'Choose the calculation method for Mc')
            
            % add fMaxRadius
            obj.AddDialogOption(zdlg, 'EventSelector');
            zdlg.AddEdit(        'bootloops',   '# boot loops',           obj.bootloops,  'number of bootstraps');
            zdlg.AddDurationEdit('forec_period','forecast period',        obj.forec_period,      'forecast period', @days);
            zdlg.AddDurationEdit('learn_period','learn period',           obj.learn_period,       'learning period', @days);
            zdlg.AddCheckbox(    'addtofig',    'plot in current figure', obj.addtofig,[],'plot in the current figure');
            zdlg.AddEdit(        'minThreshMag', 'min. threshhold Mag',    obj.minThreshMag, 'Minimum magnitude');
            obj.AddDialogOption(zdlg, 'NodeMinEventCount');
            % FIXME min number of events should be the number > Mc
            
            zdlg.Create('Name', 'relative rate change map','WriteToObj',obj,'OkFcn', @obj.doIt);
        end

        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
        end
        
        function results=Calculate(obj)

            % check pre-conditions
            assert(ensure_mainshock(),'No mainshock was defined')

            % cut catalog at mainshock learn_period:
            mainshock=obj.ZG.maepi.subset(1);
            mainshock_time = mainshock.Date;
            learn_to_date = mainshock_time + obj.learn_period;
            forecast_to_date = learn_to_date + obj.forec_period;
            l = obj.RawCatalog.Date > mainshock_time & obj.RawCatalog.Magnitude > obj.minThreshMag;
            
            assert(any(l),'no events meet the criteria of being after the mainshock and greater than threshold magnitude');
            
            obj.RawCatalog = obj.RawCatalog.subset(l);
            obj.ZG.newt2 = obj.RawCatalog;
            
            
            obj.gridCalculations(@calculation_function);
            
            if nargout
                results=obj.Result.values;
            end
            % view_rcva_a2(lab1,valueMap)
            
            function [cat_learn, cat_forecast] = prep_catalog(catalog)
                % Choose between constant radius or constant number of events with maximum radius
                if UseEventsInRadius   % take point within r
                    catalog = catalog.selectRadius(y,x,ra,'kilometer');
                    fMaxDist = max(catalog.epicentralDistanceTo(y,x));
                    % Calculate number of events per gridnode in learning period learn_period
                    cat_learn = catalog.subset(catalog.Date <= learn_to_date);
                else
                    % Determine ni number of events in learning period
                    % Set minimum number to constant number
                    NodeMinEventCount = ni;
                    % Select events in learning learn_period period
                    cat_learn = catalog.subset(catalog.Date <= learn_to_date);
                    
                    cat_forecast = catalog.subset(...
                        catalog.Date > learn_to_date & ...
                        catalog.Date <= forecast_to_date);
                    
                    % Distance from grid node for learning period and forecast period
                    [cat_learn, fMaxDist] = cat_learn.selectClosestEvents(ni);
                    
                    if fMaxDist <= fMaxRadius
                        vSel3 = cat_forecast.epicentralDistanceTo(y,x) <= fMaxDist;
                        cat_forecast = cat_forecast.subset(vSel3);
                        catalog = cat_learn.cat(cat_forecast);
                    else
                        vSel4 = (catalog.epicentralDistanceTo(y,x) < fMaxRadius & catalog.Date <= learn_to_date);
                        catalog = catalog.subset(vSel4);
                        cat_learn = catalog;
                    end
                    cat_forecast.Count
                    catalog.Count
                end
                
            end
            
            function out = calculation_function(catalog)
                
                error('hey developer, finish editing the prep_catalog function first')
                [cat_learn, cat_forecast] = prep_catalog(catalog);
                
                % Calculate the relative rate change, p, c, k, resolution
                if cat_learn.Count >= obj.NodeMinEventCount  % enough events?
                    [mRc] = calc_rcloglike_a2(catalog,obj.learn_period,obj.forec_period,obj.bootloops, mainshock);
                    % Relative rate change normalized to sigma of bootstrap
                    if mRc.fStdBst~=0
                        mRc.fRcBst = mRc.absdiff/mRc.fStdBst;
                    else
                        mRc.fRcBst = NaN;
                    end
                    
                    % Number of events per gridnode
                    % Final grid
                    mRc.nY = cat_learn.Count;
                    mRc.fMaxDist = fMaxDist;
                    out = [mRc.learn_period mRc.absdiff mRc.numreal mRc.nummod ...
                        mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
                        mRc.kval1 mRc.kmedStd1 mRc.fStdBst...
                        mRc.nMod mRc.nY mRc.fMaxDist mRc.fRcBst...
                        mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2...
                        mRc.kval2 mRc.kmedStd2 mRc.H mRc.KSSTAT...
                        mRc.P mRc.fRMS mRc.fTBigAf];
                else
                    out = nan(1,26);
                end
            end
        end
    end
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'Rate change, p-,c-,k-value map in aftershock sequence (MLE)';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)XYfun.rcvalgrid_a2(zapFcn()),...
                varargin{:});
        end
    end
end

