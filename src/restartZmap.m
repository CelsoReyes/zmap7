function restartZmap(choice)
    %restartZmap restart Zmap
    if ~exist('choice','var')
        choice = questdlg('Restart Zmap, close all figures,  and clear all variables?','Quit Zmap',...
            'Quit','Restart','Cancel','Cancel');
    end
    switch lower(choice)
        case 'quit'
            close all
            remove_appdata();
            evalin('base','clear all');
        case 'restart'
            close all
            remove_appdata();
            evalin('base','clear all;zmap');
    end
end

function remove_appdata()
    rmappdata(groot,'ZmapCoordinateSystem');
    rmappdata(groot,'ZmapDefaultReferenceEllipsoid');
end