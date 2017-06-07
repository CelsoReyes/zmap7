function sv_start(mCatalog, hFigure, bMap, rContainer)
% function sv_start(mCatalog, hFigure, bMap, rContainer)
% ------------------------------------------------------
% Starts seismicity variation analysis tool
%
% Input parameters:
%   mCatalog      Earthquake catalog to be analyzed
%   hFigure       Handle of figure where the user should select the grid (i.e. the seismicity map)
%   bMap          Map/cross-section switch. If the testing is carried out on a map set bMap = 1,
%                 on a cross-section set bMap = 0
%   rContainer    Just a container (structure proposed) to store any variables
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% June 27, 2002

global bDebug;
if bDebug
    report_this_filefun(mfilename('fullpath'));
end

% Launch GUI
hMenuFig = sv_grid(1);

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
        params.fRadius = str2double(get(handles.txtRadius, 'String'));
        params.bGridEntireArea = get(handles.chkGridEntireArea, 'Value');
        params.fSpacingHorizontal = str2double(get(handles.txtSpacingHorizontal, 'String')); % Grid spacing variable
        params.fSpacingDepth = str2double(get(handles.txtSpacingDepth, 'String'));           % Grid spacing variable
        params.fSizeRectHorizontal = str2double(get(handles.txtSizeRectHorizontal, 'String')); % Rectangular selection instead radius params.fRadius
        params.fSizeRectDepth = str2double(get(handles.txtSizeRectDepth, 'String'));           % Rectangular selection instead radius params.fRadius
        params.nMinimumNumber = str2double(get(handles.txtMinimumNumber, 'String'));
        params.nCalculateMC = get(handles.cboMagnitude, 'Value');   % Mc calculation method
        params.bBstsample = get(handles.chkBstsample, 'Value');     % Bootstrap Mc
        params.nBstsample = str2double(get(handles.txtBstsample, 'String')); % Amount of bootstrap samples
        params.bDecluster = get(handles.chkDecluster, 'Value'); % Start declustering or not
        params.nDeclMethod = get(handles.cboDeclMethod, 'Value');   % Declustering window
        params.bSeisModel = get(handles.cboSeisModel, 'Value'); % Which method to model seismicity variation (0: grid search, 1: b-value fit)
        params.bSplitTime = get(handles.radSplitTime,'Value');
        params.fSplitTime = str2double(get(handles.txtSplitTime, 'String'));
        params.bTimePeriod = get(handles.chkTimePeriod,'Value');
        params.fTimePeriod = str2double(get(handles.txtTimePeriod,'String')); % Period lengths to be compared in days
        params.sComment = get(handles.txtComment, 'String'); % Comment on calculation
        %   params.fPeriods = str2double(get(handles.txtfPeriods,'String'));       % Number of periods

        %%%%%%%%%%%%%%%%%%%%%%%%%% Check variable settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if params.fSplitTime <= min(mCatalog(:,3)) | params.fSplitTime >= max(mCatalog(:,3))
            params.fSplitTime = mean(mCatalog(:,3));
        end
        %  if ~params.bMinMagMc
        %      params.fMinMag = str2double(get(handles.txtMinMag, 'String'));
        %    else
        %      params.fMinMag = 1;
        %    end
        %    params.fMaxMag = str2double(get(handles.txtMaxMag, 'String'));
        bSaveParameter = get(handles.chkSaveParameter, 'Value');
        if bSaveParameter
            sSaveParameter = get(handles.lblSaveParameter, 'String');
        end

        % Remove figure from memory
        delete(hMenuFig);

        % Select grid
        [params.mPolygon, params.vX, params.vY, params.vUsedNodes] = ex_selectgrid(hFigure, params.fSpacingHorizontal, params.fSpacingDepth, params.bGridEntireArea);

        % Validate polygonsize
        if length(params.vX) < 4  ||  length(params.vY) < 4
            errordlg('Selection is too small. Please select a larger polygon.');
            return;
        end

        % Add parameter to params.sComment
        params.sComment = [params.sComment ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                ' Mc Method ' num2str(params.nCalculateMC) ', Time period '...
                num2str(params.fTimePeriod) ' d'];
        % General calculations

        % Create Indices to catalog
        [params.caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode, ...
            params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);
        if bSaveParameter
            % Save paramters
            save(sSaveParameter, 'params');
        else

            %%%%% Temporarily calculations for %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Perform the calculation
            [params] = sv_calc(params);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %      if params.bBValue
            %        [params] = sv_bval(params);
            %        params.mValueGrid = [params.mValueGrid bparams.mValueGrid];
            %        params.vcsGridNames = [params.vcsGridNames; bparams.vcsGridNames];
            %    end

            sv_result(params);
        end
    else
        delete(hMenuFig);
    end
end
