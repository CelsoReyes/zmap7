function pt_start(mCatalog, hFigure, bMap, rContainer, sName)
    % Starts the probabilistic forecast testing.
    %
    % pt_start(mCatalog, hFigure, bMap, rContainer)
    %
    % The function invokes the parameter dialog, calls the
    %   calculation function and invokes the dialog for displaying the results
    %
    % Input parameters:
    %   mCatalog      Earthquake catalog to use for the testing
    %   hFigure       Handle of figure where the user should select the grid (i.e. the seismicity map)
    %   bMap          Map/cross-section switch. If the testing is carried out on a map set bMap = true,
    %                 on a cross-section set bMap = false
    %   rContainer    Just a container (structure proposed) to store any variables that should be available in the
    %                 probabilistic forecast testing code
    %
    % Danijel Schorlemmer
    % June 4, 2002
    
    report_this_filefun();
    
    % Launch GUI
    hMenuFig = pt_options(bMap);
    
    % Set up parameter struct and store input parameters
    params.mCatalog = mCatalog;
    params.sCatalogName = sName;
    params.bMap = bMap;
    params.rContainer = rContainer;
    
    % Analyze Output
    if ~ishandle(hMenuFig)
        answer = 0;
    else
        handles = guidata(hMenuFig);
        answer = handles.answer;
        % OK pressed
        if answer == 1
            % Get parameter values from the gui
            % ---------------------------------
            % Hypothesis
            if get(handles.radHNumber, 'Value') == 1
                rOptionsH.nGriddingMode = 0;
                rOptionsH.nNumberEvents = str2double(get(handles.txtHNumber, 'String'));
                rOptionsH.fRadius = 0;
                rOptionsH.fSizeRectX = 0;
                rOptionsH.fSizeRectY = 0;
                rOptionsH.nMinimumNumber = 0;
                rOptionsH.fMaximumRadius = str2double(get(handles.txtHMaximumRadius, 'String'));
            elseif get(handles.radHRadius, 'Value') == 1
                rOptionsH.nGriddingMode = 1;
                rOptionsH.nNumberEvents = 0;
                rOptionsH.fRadius = str2double(get(handles.txtHRadius, 'String'));
                rOptionsH.fSizeRectX = 0;
                rOptionsH.fSizeRectY = 0;
                rOptionsH.nMinimumNumber = str2double(get(handles.txtHMinimumNumber, 'String'));
                rOptionsH.fMaximumRadius = 0;
            else % rectangle
                rOptionsH.nGriddingMode = 2;
                rOptionsH.nNumberEvents = 0;
                rOptionsH.fRadius = 0;
                rOptionsH.fSizeRectX = str2double(get(handles.txtHSizeRectX, 'String'));
                rOptionsH.fSizeRectY = str2double(get(handles.txtHSizeRectY, 'String'));
                rOptionsH.nMinimumNumber = str2double(get(handles.txtHMinimumNumber, 'String'));
                rOptionsH.fMaximumRadius = 0;
            end
            rOptionsH.nCalculateMC = get(handles.cboHCalculateMC, 'Value');
            if get(handles.radHSpatialB, 'Value') == 1
                rOptionsH.nCalcMode = 0;  % Spatial b-values
            else
                rOptionsH.nCalcMode = 1;  % Overall b-values
            end
            rOptionsH.bCalcBothPeriods = get(handles.chkHCalcBothPeriods, 'Value');
            
            % Null hypothesis
            if get(handles.radNNumber, 'Value') == 1
                rOptionsN.nGriddingMode = 0;  % Constant number
                rOptionsN.nNumberEvents = str2double(get(handles.txtNNumber, 'String'));
                rOptionsN.fRadius = 0;
                rOptionsN.fSizeRectX = 0;
                rOptionsN.fSizeRectY = 0;
                rOptionsN.nMinimumNumber = 0;
                rOptionsN.fMaximumRadius = str2double(get(handles.txtNMaximumRadius, 'String'));
            elseif get(handles.radNRadius, 'Value') == 1
                rOptionsN.nGriddingMode = 1;  % Constant Radius
                rOptionsN.nNumberEvents = 0;
                rOptionsN.fRadius = str2double(get(handles.txtNRadius, 'String'));
                rOptionsN.fSizeRectX = 0;
                rOptionsN.fSizeRectY = 0;
                rOptionsN.nMinimumNumber = str2double(get(handles.txtNMinimumNumber, 'String'));
                rOptionsN.fMaximumRadius = 0;
            else % rectangle
                rOptionsN.nGriddingMode = 2;  % Rectangles
                rOptionsN.nNumberEvents = 0;
                rOptionsN.fRadius = 0;
                rOptionsN.fSizeRectX = str2double(get(handles.txtNSizeRectX, 'String'));
                rOptionsN.fSizeRectY = str2double(get(handles.txtNSizeRectY, 'String'));
                rOptionsN.nMinimumNumber = str2double(get(handles.txtNMinimumNumber, 'String'));
                rOptionsN.fMaximumRadius = 0;
            end
            rOptionsN.nCalculateMC = get(handles.cboNCalculateMC, 'Value');
            if get(handles.radNSpatialB, 'Value') == 1
                rOptionsN.nCalcMode = 0;  % Spatial b-values
            else
                rOptionsN.nCalcMode = 1;  % Overall b-values
            end
            rOptionsN.bCalcBothPeriods = get(handles.chkNCalcBothPeriods, 'Value');
            
            % Testing
            if get(handles.radTNumber, 'Value') == 1
                rOptionsT.nGriddingMode = 0;  % Constant number
                rOptionsT.nNumberEvents = str2double(get(handles.txtTNumber, 'String'));
                rOptionsT.fRadius = 0;
                rOptionsT.fSizeRectX = 0;
                rOptionsT.fSizeRectY = 0;
                rOptionsT.nMinimumNumber = 0;
                rOptionsT.fMaximumRadius = str2double(get(handles.txtTMaximumRadius, 'String'));
            elseif get(handles.radTRadius, 'Value') == 1
                rOptionsT.nGriddingMode = 1;  % Constant Radius
                rOptionsT.nNumberEvents = 0;
                rOptionsT.fRadius = str2double(get(handles.txtTRadius, 'String'));
                rOptionsT.fSizeRectX = 0;
                rOptionsT.fSizeRectY = 0;
                rOptionsT.nMinimumNumber = str2double(get(handles.txtTMinimumNumber, 'String'));
                rOptionsT.fMaximumRadius = 0;
            else % rectangle
                rOptionsT.nGriddingMode = 2;  % Rectangles
                rOptionsT.nNumberEvents = 0;
                rOptionsT.fRadius = 0;
                rOptionsT.fSizeRectX = str2double(get(handles.txtTSizeRectX, 'String'));
                rOptionsT.fSizeRectY = str2double(get(handles.txtTSizeRectY, 'String'));
                rOptionsT.nMinimumNumber = str2double(get(handles.txtTMinimumNumber, 'String'));
                rOptionsT.fMaximumRadius = 0;
            end
            rOptionsT.nCalculateMC = [];      % Fill the unused fields
            rOptionsT.nCalcMode = [];         % Fill the unused fields
            rOptionsT.bCalcBothPeriods = false;   % Fill the unused fields
            bSaveParameter = get(handles.chkSaveParameter, 'Value');
            if bSaveParameter
                sSaveParameter = get(handles.lblSaveParameter, 'String');
            end
            
            % Set up the options array
            params.rOptions = [rOptionsH; rOptionsN; rOptionsT];
            
            % Options section
            params.bGridEntireArea = get(handles.chkGridEntireArea, 'Value');
            params.fSpacingX = str2double(get(handles.txtSpacingX, 'String'));
            params.fSpacingY = str2double(get(handles.txtSpacingY, 'String'));
            params.fSplitTime = str2double(get(handles.txtSplitTime, 'String'));
            params.bForecastPeriod = get(handles.chkForecastPeriod, 'Value');
            if params.bForecastPeriod
                params.fForecastPeriod = str2double(get(handles.txtForecastPeriod, 'String'));
            else
                params.fForecastPeriod = 0;
            end
            params.bLearningPeriod = get(handles.chkLearningPeriod, 'Value');
            if params.bLearningPeriod
                params.fLearningPeriod = str2double(get(handles.txtLearningPeriod, 'String'));
            else
                params.fLearningPeriod = 0;
            end
            params.bRandomNode = get(handles.chkRandomNode, 'Value');
            if params.bRandomNode
                params.nNumberCalculationNode = str2double(get(handles.txtNumberCalculationNode, 'String'));
            end
            params.bMinMagMc = get(handles.chkMinMag, 'Value');
            if ~params.bMinMagMc
                params.fMinMag = str2double(get(handles.txtMinMag, 'String'));
            else
                params.fMinMag = [];
            end
            params.fMaxMag = str2double(get(handles.txtMaxMag, 'String'));
            
            % Additional stuff
            params.nTestMethod = get(handles.cboTestMethod, 'Value');
            params.bForceRandomCalculation = false;
            params.sComment = 'First test';
            
            % Dave Jackson
            params.bSaveRates = true;
            params.sSaveRatesAsciiFilenameH = '/home/danijel/pro/parkfield/Runs/ratesH.txt';
            params.sSaveRatesAsciiFilenameN = '/home/danijel/pro/parkfield/Runs/ratesN.txt';
            params.sSaveRatesMatFilenameH = '/home/danijel/pro/parkfield/Runs/ratesH.mat';
            params.sSaveRatesMatFilenameN = '/home/danijel/pro/parkfield/Runs/ratesN.mat';
            %     delete(params.sSaveRatesAsciiFilenameH);
            %     delete(params.sSaveRatesAsciiFilenameN);
            %     delete(params.sSaveRatesMatFilenameH);
            %     delete(params.sSaveRatesMatFilenameN);
            params.vRatesH = [];
            params.vRatesN = [];
            
            % Remove figure from memory
            delete(hMenuFig);
            
            % Select grid
            [params.mPolygon, params.vX, params.vY, params.vUsedNodes] = ex_selectgrid(hFigure, params.fSpacingX, params.fSpacingY, params.bGridEntireArea);
            
            % Validate polygonsize
            if length(params.vX) < 2  ||  length(params.vY) < 2
                errordlg('Selection is too small. Please select a larger polygon.');
                return;
            end
            
            % General calculations
            % --------------------
            
            % Split the catalog
            [params.mLearningCatalog, params.mObservedCatalog, ~, ~, params.fLearningPeriodUsed, params.fObservedPeriodUsed] ...
                = ex_SplitCatalog(params.mCatalog, params.fSplitTime, ...
                params.bLearningPeriod, params.fLearningPeriod, params.bForecastPeriod, params.fForecastPeriod);
            % Create Indices to catalogs
            for nCnt_ = 1:3
                % Create Indices to learning catalogs
                params.rOptions(nCnt_).caLearningNodeIndices = ex_CreateIndexCatalog(params.mLearningCatalog, params.mPolygon, params.bMap, ...
                    params.rOptions(nCnt_).nGriddingMode, params.rOptions(nCnt_).nNumberEvents, params.rOptions(nCnt_).fRadius, ...
                    params.rOptions(nCnt_).fSizeRectX, params.rOptions(nCnt_).fSizeRectY);
                % Create Indices to learning catalogs
                params.rOptions(nCnt_).caObservedNodeIndices = ex_CreateIndexCatalog(params.mObservedCatalog, params.mPolygon, params.bMap, ...
                    params.rOptions(nCnt_).nGriddingMode, params.rOptions(nCnt_).nNumberEvents, params.rOptions(nCnt_).fRadius, ...
                    params.rOptions(nCnt_).fSizeRectX, params.rOptions(nCnt_).fSizeRectY);
            end
            
            if bSaveParameter
                % Save parameters
                save(sSaveParameter, 'params');
            else
                %       % Determine the overall magnitude of completeness and overall b-value
                %       params.fMcOverall = calc_Mc(params.mCatalog, params.nCalculateMC);
                %       vSel = params.mCatalog.Magnitude >= params.fMcOverall;
                %       [params.fBValueOverall params.fStdDevOverall] = calc_bmemag(params.mCatalog.Magnitude(vSel), 0.1);
                
                %       % Determine the overall standard deviation of the b-value for the bayesian approach (if used)
                %       if params.nTestMethod == 3
                %         disp(['Calculating overall mean standard deviation']);
                %         params.fStdDevOverall = kj_CalcOverallStdDev(params);
                %         disp(['Standard deviation calculated']);
                %       end
                
                % Perform the calculation
                [params] = pt_calc(params);
                
                if params.bSaveRates
                    vRatesH = params.vRatesH;
                    vRatesN = params.vRatesN;
                    save(params.sSaveRatesAsciiFilenameH, 'vRatesH', '-ascii');
                    save(params.sSaveRatesAsciiFilenameN, 'vRatesN', '-ascii');
                    save(params.sSaveRatesMatFilenameH, 'vRatesH');
                    save(params.sSaveRatesMatFilenameN, 'vRatesN');
                end
                
                % Display the results
                gui_result(params);
            end
        else
            delete(hMenuFig);
        end
    end
end
