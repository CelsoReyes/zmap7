function warndisp(msg,msgTitle)
    % display a warning message to command line
    if ~ZmapGlobal.Data.debug
        return
    end
    if exist('msgTitle','var')
        fprintf('\n[\b---<strong> ZMAP warning: %s  </strong>---]\b\n',msgTitle);
    else
        fprintf('\n---<strong> ZMAP warning: </strong>');
    end
    disp(msg)
end
    