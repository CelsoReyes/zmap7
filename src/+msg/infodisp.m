function infodisp(msg,msgTitle)
    if exist('msgTitle','var')
        fprintf('\n---<strong> ZMAP info: %s </strong>---\n',msgTitle);
    else
        fprintf('\n---<strong> ZMAP info: </strong>');
    end
    disp(msg)
end
    