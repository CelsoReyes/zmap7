function setcol()
    % This is the machine-generated representation of a MATLAB object
    % and its children.  Note that handle values may change when these
    % objects are re-created. This may cause problems with some callbacks.
    % The command syntax may be supported in the future, but is currently
    % incomplete and subject to change.
    %
    % To re-open this system, just type the name of the m-file at the MATLAB
    % prompt. The M-file and its associtated MAT-file must be on your path.

    report_this_filefun(mfilename('fullpath'));

    % load setcol %todo delete setcol data.
    resp=questdlg('Set Background Color','Which background do you wish to set?','Axes','Figure','neither','neither');
    switch resp
        case 'Axes'
            C = uisetcolor;
            ZmapGlobal.Data.color_bg =[C(1) C(2) C(3)];
            close;
            update(mainmap());
        case 'Figure'
            C = uisetcolor;
            ZmapGlobal.Data.color_fbg=[C(1) C(2) C(3)];
            close;
            try
            whitebg(mainmap(),ZmapGlobal.Data.color_fbg);
            catch
                warning('unable to change color. maybe map doesn''t exist');
            end
            update(mainmap);
        otherwise
            
            % do nothing
    end