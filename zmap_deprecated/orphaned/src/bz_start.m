function bz_start(hMap, Catalog)

    size(Catalog)

    report_this_filefun(mfilename('fullpath'));

    % Launch GUI
    fig = bz_grid;

    % Analyze Output
    if ~ishandle(fig)
        answer = 0;
    else
        handles = guidata(fig);
        answer = handles.answer;
        % OK pressed
        if answer == 1
            nNumberEvents = str2double(get(handles.txtNumberOfEvents, 'String'));
            fSpacingLongitude = str2double(get(handles.txtSpacingLongitude, 'String'));
            fSpacingLatitude = str2double(get(handles.txtSpacingLatitude, 'String'));
            fExcludeEvents = str2double(get(handles.txtExcludeEvents, 'String'));
            bExcludeEvents = get(handles.chkExcludeEvents, 'Value');
            delete(fig);
            mCatalog = bz_catalog(hMap, nNumberEvents, fSpacingLongitude, fSpacingLatitude, bExcludeEvents, fExcludeEvents, Catalog);
        else
            delete(fig);
        end
    end

