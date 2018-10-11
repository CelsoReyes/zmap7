function errordisp(msg,msgTitle)
    if exist('msgTitle','var')
        fprintf(2,'\n---<strong> ZMAP ERROR: %s </strong>---\n',msgTitle);
    else
        fprintf(2,'\n---<strong> ZMAP ERROR: </strong>');
    end
    disp(msg)
end