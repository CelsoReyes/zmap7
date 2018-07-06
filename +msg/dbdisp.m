function dbdisp(msg,msgTitle)
    if ~ZmapGlobal.Data.debug
        return
    end
    if exist('msgTitle','var')
        fprintf('\n---<strong> ZMAP DB: %s </strong>---\n',msgTitle);
    else
        fprintf('\n---<strong> ZMAP DB: </strong>');
    end
    disp(msg)
    fprintf('\n');
end
    