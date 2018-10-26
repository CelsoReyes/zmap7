function warndisp(msg,msgTitle)
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
    