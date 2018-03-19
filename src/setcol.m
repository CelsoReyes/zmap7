function setcol(fig)
    report_this_filefun(mfilename('fullpath'));
    
    % load setcol %todo delete setcol data.
    resp=questdlg('Set Background Color','Which background do you wish to set?','Axes','Figure','neither','neither');
    switch resp
        case 'Axes'
            C = uisetcolor;
            ZmapGlobal.Data.color_bg =[C(1) C(2) C(3)];
            zmap_update_displays();
        case 'Figure'
            C = uisetcolor;
            ZmapGlobal.Data.color_fbg=[C(1) C(2) C(3)];
            try
                whitebg(fig,ZmapGlobal.Data.color_fbg);
            catch
                warning('unable to change color. maybe map doesn''t exist');
            end
            update(fig);
        otherwise
            
            % do nothing
    end
end