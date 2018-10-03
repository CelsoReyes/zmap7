classdef calc_Omoricross < ZmapVGridFunction
    % CALC_OMORICROSS calculate omori parameters (p, c, k) along a cross section
    
    properties
        mc_method       McMethods   = McMethods.FixedMc % this function might only know [' Fixed Mc (Mc = Mmin) | Automatic Mc (max curvature) | EMR-method'];
        bootloops       double      = 50
        learningPeriod  duration    = days(100)
        Nmin            double      = 50
        MainShock       ZMapCatalog
        MainShockSelection char {mustBeMember({'Largest','FirstInGlobal','LargestInXsection'})} = 'Largest'
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
                        
           [~,mcCalculator] = calc_mc([], obj.mc_method, fBinning, fMcFix);
            
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
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='omori parameters (p-, k-,c-) [xsec]';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XZfun.calc_Omoricross(zapFcn()));
        end
        
        function calc_Omoricross_orig()
            % Calculate Omori parameters on cross section using different choices for Mc
            % Data is displayed with view_Omoricross.m
            %
            % J. Woessner
            % updated: 20.10.04
            ZG=ZmapGlobal.Data;
            report_this_filefun();
            wCat='primeCatalog'; % working catalog name
            
            myvalues=table;
            myvalues.Properties.Description='Omori cross-section parameters';
            mygrid = ZG.Grid;
            
            % Set the grid parameter
            % initial values
            dd = 1.00; % Depth spacing in km
            dx = 1.00 ; % X-Spacing in km
            ni = 100;   % Number of events
            bv2 = NaN;
            Nmin = 50;  % Minimum number of events
            bGridEntireArea = false;
            time = days(100); % days
            timef= days(0); % No forecast done, but needed for functions
            bootloops = 50;
            ra = 5;
            fMaxRadius = 5;
            fBinning = 0.1;
            
            % cut catalog at mainshock time:
            
            if ~ensure_mainshock()
                return
            end
            
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
            zdlg.AddDurationEdit('time','Learning Period', time, '', @days);
            
            zdlg.AddCheckbox('useBootstrap',   'Use Bootstrapping',        true,  'nBstSample' ,...
                're takes longer, but provides more accurate results');
            zdlg.AddEdit('nBstSample',         'Number of bootstraps',     bootloops,...
                'Number of bootstraps to determine Mc');
            [res,okPressed] = zdlg.Create('Name','Grid Input Parameter');
            
            if ~okPressed
                % return
            end
            
            l = ZG.(wCat).Date > ZG.maepi.Date(1);
            ZG.(wCat)=ZG.(wCat).subset(l);
            
            %% Create the dialog box
            figure(...
                'Name','Grid Input Parameter',...
                'NumberTitle','off', ...
                'units','points',...
                'Visible','on', ...
                'Position',position_in_current_monitor(550,300), ...
                'Color', [0.8 0.8 0.8]);
            axis off
            
            
            
            % Dropdown list
            labelList2=[' Fixed Mc (Mc = Mmin) | Automatic Mc (max curvature) | EMR-method'];
            % hndl2 pointed to MC list, cbfun 001
            % tgl1 was Constant # events.
            % tgl2 was const radius
            
            function my_calculate() % 'ca'
                
                figure(xsec_fig());
                set(gca,'NextPlot','add')
                
                if bGridEntireArea % Use entire area for grid
                    vXLim = get(gca, 'XLim');
                    vYLim = get(gca, 'YLim');
                    x = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
                    y = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
                    x = [x ; x(1)];
                    y = [y ; y(1)];     %  closes polygon
                    clear vXLim vYLim;
                end % of if bGridEntireArea
                
                % CREATE THE GRID (NEW WAY)
                gridopts = GridOptions(dx, dy, [], 'km',false, false);
                mygrid = ZmapGrid('omoricross',gridopt);
                mygrid = mygrid.MaskWithShape(ShapeGeneral.ShapeStash);
                mygrid.plot();
                ll=mygrid.ActivePoints; % holdover.
                
                %FIXME create EventSelectionChoice and use gridfun (mygrid.associateWithEvents no longer exists)
                if tgl1
                    % get ni closest events
                    gridcats = mygrid.associateWithEvents(ZG.newa,fMaxRadius,ni,min(ZG.maepi.Date),[]);
                else
                    % get events within ra
                    gridcats = mygrid.associateWithEvents(ZG.newa,ra,[],min(ZG.maepi.Date),[]);
                end
                
                % Set itotal for waitbar
                itotal = length(mygrid);
                
                
                % loop over  all points
                mCross = []; % NaN(length(newgri),20);
                allcount = 0.;
                wai = waitbar(0,' Please Wait ...  ');
                set(wai,'NumberTitle','off','Name','Omori grid - percent done');
                drawnow
                
                % if fixed magnitude of completeness, request from user
                if obj.mc_method == McMethods.FixedMc
                    [~,~,fMcFix] = smart_inputdlg('Fixed Mc input',...
                        struct('prompt','Enter Mc:', 'value', 1.5));
                end
                
                mCross=nan(numel(gridcats),20);
                
                
                % decide which calculator to use
                if mc_method == McMethods.FixedMc
                    fMc = fMcFix;
                    mcCalculator=@(~,~)fMcFix;
                elseif mc_method == McMethods.MaxCurvature
                    nMethod = 1;
                    [~,mcCalculator]=calc_Mc([], McMethods.MaxCurvature, fBinning);
                elseif mc_method2 == McMethods.McEMR
                    nMethod = 6;
                    [~,mcCalculator] = calc_Mc([], McMethods.McEMR, fBinning);
                else
                    error('unknown Mc method (in THIS function... which needs to be updated')
                end
                
                
                % Loop over grid nodes
                
                
                
                for i= 1:numel(gridcats)
                    % Grid coordinates
                    allcount = allcount + 1.;
                    
                    b = gridcats(i);  %already subset by date and radius/number events
                    
                    fMc = mcCalculator(b);
                    
                    % for some reason this was only associatdd with radius
                    if ~isnan(fMc)
                        b=b.subset(b.Magnitude >= fMc);
                    end
                    
                    
                    fMaxDist = max(b.epicentralDistanceTo(mygrid.X(i),mygrid.Y(i)));
                    
                    %Set catalog after selection
                    ZG.newt2 = b; %WHY? probably delete this
                    % Number of events per gridnode
                    nY=b.Count;
                    
                    
                    % Calculate the relative rate change, p, c, k, resolution
                    if length(b) >= Nmin  % enough events?
                        nMod = OmoriModel.pck; % Single Omori law
                        [mResult] = calc_Omoriparams(b,time,timef,bootloops,ZG.maepi,nMod);
                        
                        % Result matrix
                        mCross(i,:) = [mResult.pval1 mResult.pmeanStd1 mResult.cval1 mResult.cmeanStd1...
                            mResult.kval1 mResult.kmeanStd1 mResult.nMod nY fMaxDist...
                            mResult.pval2 mResult.pmeanStd2 mResult.cval2 mResult.cmeanStd2 mResult.kval2 mResult.kmeanStd2 mResult.H...
                            mResult.KSSTAT mResult.P mResult.fRMS fMc];
                    else
                        if isempty(fMaxDist)
                            fMaxDist = NaN;
                        end
                        mCross(i,:) = [NaN NaN NaN NaN NaN NaN NaN nY fMaxDist NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN fMc];
                    end
                    waitbar(allcount/itotal)
                end  % for newgr
                
                drawnow
                
                catsave3('calc_Omoricross_orig')
                
                close(wai)
                watchoff
                
                myvalues = array2table(mCross,'VariableNames',...
                    {'p-value',... mPval, p-Value
                    'p-value std',... mPvalstd, p-value standard deviation
                    'c-value',... mCval, c-value
                    'c-value std',...mCvalstd, c-value standard deviation
                    'k-value',... mKval, k-value
                    'k-value std',... mKvalstd, k-value standard deviation
                    'model',... mMod, Chosen fitting model
                    'Number of Events',...mNumevents, Number of events per grid node
                    'Radius [km]',... vRadiusRes,  Radii of chosen events, Resolution
                    'p-value2',... mPval, p-Value2 UNUSED(?)
                    'p-value2 std',... mPvalstd, p-value2 standard deviation UNUSED(?)
                    'c-value2',... mCval, c-value2  UNUSED(?)
                    'c-value2 std',...mCvalstd, c-value2 standard deviation UNUSED(?)
                    'k-value2',... mKval, k-value UNUSED(?)
                    'k-value2 std',... mKvalstd, k-value standard deviation UNUSED(?)
                    'KS-Test H',... mKstestH, KS-Test (H-value) binary rejection criterion at 95% confidence level
                    'KS-Test stat',... mKsstat, KS-Test statistic for goodness of fit
                    'KS-Test P-value', ...  mKsp, KS-Test p-value
                    'RMS', ... mRMS, RMS value for goodness of fit
                    'Mc value' ... mMc, Mc value
                    });
                
                
                % could also add myvalues.Properties.Description
                % and myvalues.Properties.VariableUnits
                
                
                
                %{
        % Prepare plotting
        normlap2=NaN(length(mygrid),1);
        
        %%% p,c,k- values for period before large aftershock or just modified Omori law
        % p-value
        normlap2(ll)= mCross(:,1);
        mPval=reshape(normlap2,length(yvect),length(xvect));
        
            % and so on... and so on...
                %}
                % View the map
                view_Omoricross(myvalues, mygrid, 'p-value');
                
            end
            
            function my_save()
                % save myvalues,mygrid,  maybe the catalog, too.
                
            end
            
            % Load existing cross section
            function my_load() % 'lo'
                [file1,path1] = uigetfile(['*.mat'],'Omori parameter cross section');
                if length(path1) > 1
                    
                    %{
             ... was
            load([path1 file1])
            
            normlap2=NaN(length(tmpgri(:,1)),1);
            %%% p,c,k- values for period before large aftershock or just modified Omori law
            % p-value
            normlap2(ll)= mCross(:,1);
            mPval=reshape(normlap2,length(yvect),length(xvect));
            ... etc
                    %}
                    tmp=load(fullfile(path1, file1));
                    myvalues=tmp.myvalues;
                    mygrid=tmp.mygrid;
                    clear tmp
                    
                    ... old stuff follows again
                        % Initial map set to relative rate change
                    valueMap = mPval;
                    nlammap
                    [xsecx, xsecy inde] =mysect(ZG.(wCat).Latitude',ZG.(wCat).Longitude',ZG.(wCat).Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
                    % Plot all grid points
                    set(gca,'NextPlot','add')
                    
                    % Plot
                    view_Omoricross(myvalues, mygrid, 'p-value');
                else
                    return
                end
            end
            
            
            
            
            function callbackfun_002(mysrc,myevt)
                
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                update_editfield_value(mysrc);
                ni=mysrc.Value;
                tgl2.Value=0;
                tgl1.Value=1;
            end
            
            function callbackfun_003(mysrc,myevt)
                
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                update_editfield_value(mysrc);
                ra=mysrc.Value;
                tgl2.Value=1;
                tgl1.Value=0;
            end
            function callbackfun_009(mysrc,myevt)
                
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                tgl2.Value=0;
            end
            
            function callbackfun_010(mysrc,myevt)
                
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                tgl1.Value=0;
            end
            
            function callback_ok(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                tgl1=tgl1.Value;
                tgl2=tgl2.Value;
                bGridEntireArea = get(chkGridEntireArea, 'Value');
                my_calculate();
            end
        end
    end
end
