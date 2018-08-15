function [mRandomCatalog, ok] = syn_invoke_random_dialog(mCatalog)
% permutes/generates a catalog based on interactive choices
%
%  [randCatalog, ok] = SYN_INVOKE_RANDOM_DIALOG(catalog) allows permutation of longitude,
%  latitude, depth, dates, and magnitudes.  randCatalog contains the permutated catalog
%
%  if user cancels, then randCatalog is the incoming catalog, and ok is false
%
    report_this_filefun();

    ok=true;
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
            bLon = logical(get(handles.chkLon, 'Value'));
            bLat = logical(get(handles.chkLat, 'Value'));
            bDepth = logical(get(handles.chkDepth, 'Value'));
            bTimes = logical(get(handles.chkTimes, 'Value'));

            % Remove figure from memory
            delete(hDialog);

            % Create the new catalog
            [mRandomCatalog] = syn_randomize_catalog(mCatalog, bLon, bLat, bDepth, bTimes, nMagnitudes, fBValue, fMc, fInc);
            sort(mRandomCatalog,'Date')
        else
            delete(hDialog);
            disp('catalog is unchanged')
            mRandomCatalog = mCatalog;
            ok=false;
        end
    end
end
