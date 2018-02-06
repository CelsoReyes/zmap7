function restartZmap()
    %restartZmap restart Zmap
    answer = questdlg('Restart Zmap, close all figures,  and clear all variables?','Quit Zmap',...
        'Quit','Restart','Cancel','Cancel')
    switch answer
        case 'Quit'
            close all
            evalin('base','clear all');
        case 'Restart'
            close all
            evalin('base','clear all;zmap');
    end
end