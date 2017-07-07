function gui_StartOmori(mCatalog, hFigure, bMap, rContainer,vCoastline,vFaults)
    % function gui_StartOmori(mCatalog, hFigure, bMap, rContainer,vCoastline,vFaults)
    % -------------------------------------------------------------------------
    % Start Omori law mapping by setting the parameters
    %
    % Input parameters:
    %   mCatalog      Earthquake catalog to be analyzed
    %   hFigure       Handle of figure where the user should select the grid (i.e. the seismicity map)
    %   bMap          Map/cross-section switch. If the testing is carried out on a map set bMap = 1,
    %                 on a cross-section set bMap = 0
    %   rContainer    Just a container (structure proposed) to store any variables
    %   vCoastline    Vector with Coastline
    %   vFaults       Vector with faults
    %
    % J. Woessner; j.woessner@sed.ethz.ch
    % last update: 04.07.2005

    global bDebug;
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end

    % Launch GUI
    hMenuFig = gui_gridOmori(bMap);

    % Set up parameter struct and store input parameters
    params.mCatalog = mCatalog;
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
            % Get the values from figure
            %params.bNumber = get(handles.radNumber, 'Value');   % deprecated
            if get(handles.radNumber, 'Value') == 1
                params.nGriddingMode = 0;   % Constant number
            elseif get(handles.radRadius, 'Value') == 1
                params.nGriddingMode = 1;   % Constant radius
            else
                params.nGriddingMode = 2;   % Rectangle mode
            end
            % Setting up the params struct array with variables
            params.nNumberEvents = str2double(get(handles.txtNumber, 'String'));
            params.fMaxRadius = str2double(get(handles.txtMaxRadius, 'String'));
            params.fRadius = str2double(get(handles.txtRadius, 'String'));
            params.bGridEntireArea = get(handles.chkGridEntireArea, 'Value');
            params.fSpacingHorizontal = str2double(get(handles.txtSpacingHorizontal, 'String')); % Grid spacing variable
            params.fSpacingDepth = str2double(get(handles.txtSpacingDepth, 'String'));           % Grid spacing variable
            params.fSizeRectHorizontal = str2double(get(handles.txtSizeRectHorizontal, 'String')); % Rectangular selection instead radius params.fRadius
            params.fSizeRectDepth = str2double(get(handles.txtSizeRectDepth, 'String'));           % Rectangular selection instead radius params.fRadius
            params.nMinimumNumber = str2double(get(handles.txtMinimumNumber, 'String'));
            params.bTimePeriod = get(handles.chkTimePeriod,'Value');
            params.fTimePeriod = str2double(get(handles.txtTimePeriod,'String')); % Period lengths to be compared in days
            params.bTimeBgr = get(handles.chkTimeBgr,'Value');
            params.fTimeBgr = str2double(get(handles.txtTimeBgr,'String')); % Period for background rate [years]
            params.bTstart = get(handles.chkTstart,'Value'); % Check for starting time of temporal mapping
            params.fTstart = str2double(get(handles.txtTstart,'String')); % Starting time for temporal mapping
            params.bBstnum = get(handles.chkBstnum,'Value'); % Check for boostrap sampling
            params.fBstnum = str2double(get(handles.txtBstnum,'String')); % Number of bootstrap samples
            params.fBgrate = str2double(get(handles.txtBgrate,'String')); % Background seismicity rate [per year]
            params.fBinning = str2double(get(handles.txtBinsize,'String')); % Bin size for magnitude binning
            params.sComment = get(handles.txtComment, 'String'); % Comment on calculation

            % Add coastline
            if exist('vCoastline','var')
                params.vCoastline = vCoastline;
            end
            % Add faults
            if exist('vFaults','var')
                params.vFaults = vFaults;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%% Check variable settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            % Define Mainshock
            vSel = (params.mCatalog(:,6) == max(params.mCatalog(:,6)));
            params.mMainshock = mCatalog(vSel,:);
            % Normalization of gridding mode
            if params.nGriddingMode == 1 % constant radius
                params.fBgrate = params.fBgrate/(pi*params.fRadius^2);
            elseif params.nGriddingMode == 2
                params.fBgrate = params.fBgrate/(params.fSizeRectDepth*params.fSizeRectHorizontal);
            else
                params.fBgrate = params.fBgrate;
            end
            % Save parameters
            bSaveParameter = get(handles.chkSaveParameter, 'Value');
            if bSaveParameter
                sSaveParameter = get(handles.lblSaveParameter, 'String');
            end

            % Remove figure from memory
            delete(hMenuFig);

            % Select grid
            [params.mPolygon, params.vX, params.vY, params.vUsedNodes] = ex_selectgrid(hFigure, params.fSpacingHorizontal, params.fSpacingDepth, params.bGridEntireArea);

            % Validate polygonsize
            if length(params.vX) < 4 || length(params.vY) < 4
                errordlg('Selection is too small. Please select a larger polygon.');
                return;
            end

            % Add parameter to params.sComment
            params.sComment = [params.sComment ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.'...
                ', Time period ' num2str(params.fTimePeriod) ' d'];
            if bSaveParameter
                % Save paramters
                save(sSaveParameter, 'params');
            else
                % Perform the calculation
                [mResults] = gui_CalcOmori(params);
                % Create output
                sv_result(mResults);
            end
        else
            delete(hMenuFig);
        end
    end
