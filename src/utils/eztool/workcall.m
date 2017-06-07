%  This callback routine has to be an m-file, not a function
%  because it modifies the workspace.  We know which function to
%  execute by examining the label of the current menu item.
%
%  Keith Rogers 11/30/93

SavedFile = get(get(gcm2,'Parent'),'UserData');

if (strcmp(get(gcm2,'Label'),'Load'))
    [filename,pathname] = uigetfile('*.mat',...
        'Choose a MATLAB Data file',50,50);
    if (filename ~= 0)
        SavedFile = [pathname filename];
        clear filename pathname;
        eval(['load ' SavedFile ';']);
        set(get(gcm2,'Parent'),'UserData',SavedFile);
    end
elseif (strcmp(get(gcm2,'Label'),'Save'))
    if (strcmp(SavedFile,''))
        [filename,pathname] = uiputfile('*.mat','Data Filename',...
            50,50);
        if (filename ~= 0)
            SavedFile = [pathname filename];
            clear filename pathname;
            eval(['save ' SavedFile ';']);
            set(get(gcm2,'Parent'),'UserData',SavedFile);
        end
    else
        eval(['save ' SavedFile ';']);
    end
elseif (strcmp(get(gcm2,'Label'),'Save As'))
    if (strcmp(SavedFile,''))
        [filename,pathname] = uiputfile('*.mat','Data Filename',...
            50,50);
    else
        [filename,pathname] = uiputfile(SavedFile,'Data Filename',...
            50,50);
    end
    if (filename ~= 0)
        SavedFile = [pathname filename];
        clear filename pathname;
        eval(['save ' SavedFile ';']);
        set(get(gcm2,'Parent'),'UserData',SavedFile);
    end
elseif (strcmp(get(gcm2,'Label'),'New Figure'))
    figure;
    makemenus;
end
