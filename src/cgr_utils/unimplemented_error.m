function unimplemented_error(varargin)
    % provide error dialog (if interactive) and error message for unimplemented features
    %
    % see also under_construction
    
    beep;
    if ZmapDialog.Data.Interactive
        errordlg('Under Construction','Not reimplemented yet');
    end
    error('ZMAP:UNIMPLEMENTED','Under Construction : Not yet implemented / reimplemented');
end