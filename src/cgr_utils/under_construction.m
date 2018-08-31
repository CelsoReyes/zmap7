function under_construction(varargin)
    % warn user that this feature is under construction/not implemented
    %
    % see also unimplemented_error
    
    beep;
    if ZmapGlobal.Data.Interactive
        warndlg('Under Construction','Not reimplemented yet');
    end
    warning('ZMAP:UNDERCONSTRUCTION','Under Construction : Not implemented / reimplemented yet');
end