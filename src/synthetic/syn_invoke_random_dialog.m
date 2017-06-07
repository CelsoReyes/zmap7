function [mRandomCatalog] = syn_invoke_random_dialog(mCatalog)

    global bDebug
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end

    % Open figure
    hDialog = syn_random_dialog;

    % Analyze Output
    if ~ishandle(hDialog)
        answer = 0;
    else
        handles = guidata(hDialog);
        answer = handles.answer;
        % OK pressed
        if answer == 1
            % Get the values from figure
            nMagnitudes = get(handles.cboMagnitudes, 'Value');
            if nMagnitudes == 2
                fBValue = str2double(get(handles.txtBValue, 'String'));
                fMc = str2double(get(handles.txtMC, 'String'));
                fInc = str2double(get(handles.txtInc, 'String'));
            else
                fBValue = 1;
                fMc = 1;
                fInc = 0.1;
            end
            bLon = get(handles.chkLon, 'Value');
            bLat = get(handles.chkLat, 'Value');
            bDepth = get(handles.chkDepth, 'Value');
            bTimes = get(handles.chkTimes, 'Value');

            % Remove figure from memory
            delete(hDialog);

            % Create the new catalog
            [mRandomCatalog] = syn_randomize_catalog(mCatalog, bLon, bLat, bDepth, bTimes, nMagnitudes, fBValue, fMc, fInc);
        else
            delete(hDialog);
            mRandomCatalog = nan;
        end
    end
