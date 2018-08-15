function [newCat, ok] = syn_invoke_dialog(mCatalog)
% SYN_INVOKE_DIALOG interactive creation of a synthetic catalog
%
% [newCat, ok] = syn_invoke_dialog(catalog)
%
    report_this_filefun();

    ok=false;
    % Open figure
    hDialog = syn_dialog(mCatalog);

    % Analyze Output
    if ~ishandle(hDialog)
        answer = 0;
        newCat = mCatalog;
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
            [newCat] = syn_catalog(nNumberEvents, fBValue, fMc, fInc, fMinLat, fMaxLat, fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime);
            newCat.sort('Date');
            ok=true;
        else
            delete(hDialog);
            newCat = mCatalog;
        end
    end
end