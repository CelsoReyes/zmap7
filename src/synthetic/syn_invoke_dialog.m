function [mNewCatalog] = syn_invoke_dialog(mCatalog)

    global bDebug
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end

    % Open figure
    hDialog = syn_dialog(mCatalog);

    % Analyze Output
    if ~ishandle(hDialog)
        answer = 0;
        mNewCatalog = nan;
    else
        handles = guidata(hDialog);
        answer = handles.answer;
        % OK pressed
        if answer == 1
            % Get the values from figure
            nNumberEvents = str2double(get(handles.txtNumber, 'String'));
            fBValue = str2double(get(handles.txtBValue, 'String'));
            fMc = str2double(get(handles.txtMC, 'String'));
            fInc = str2double(get(handles.txtInc, 'String'));
            fMinLat = str2double(get(handles.txtMinLat, 'String'));
            fMaxLat = str2double(get(handles.txtMaxLat, 'String'));
            fMinLon = str2double(get(handles.txtMinLon, 'String'));
            fMaxLon = str2double(get(handles.txtMaxLon, 'String'));
            fMinDepth = str2double(get(handles.txtMinDepth, 'String'));
            fMaxDepth = str2double(get(handles.txtMaxDepth, 'String'));
            fMinTime = str2double(get(handles.txtMinTime, 'String'));
            fMaxTime = str2double(get(handles.txtMaxTime, 'String'));

            % Remove figure from memory
            delete(hDialog);

            % Create the new catalog
            [mNewCatalog] = syn_catalog(nNumberEvents, fBValue, fMc, fInc, fMinLat, fMaxLat, fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime);
        else
            delete(hDialog);
            mNewCatalog = nan;
        end
    end
