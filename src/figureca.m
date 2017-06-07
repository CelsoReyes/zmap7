function figureca(command,~)
    % This function is a callback for makemenus.
    % It should not be called from the command line.
    % figureca (previously internally known as FigureCallback)
    %
    % Keith Rogers 11/30/93

    report_this_filefun(mfilename('fullpath'));

    if (command == 1)
        if(strcmp(get(gcm2,'Label'),'Landscape'))
            set(gcf,'PaperOrientation','landscape');
            set(gcm2,'Label','Portrait');
        else
            set(gcf,'PaperOrientation','portrait');
            set(gcm2,'Label','Landscape');
        end
    end
