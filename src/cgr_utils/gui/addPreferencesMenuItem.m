function addPreferencesMenuItem()
    % add quit menu to main file menu
    hQuit=findall(gcf,'Label','ZMAP Preferences...');
    if isempty(hQuit)
        mainfile=findall(gcf,'Tag','figMenuFile');
        uimenu(mainfile,'Label','ZMAP Preferences...','Separator','on','MenuSelectedFcn',@(~,~)ZmapSettings);
    end
end