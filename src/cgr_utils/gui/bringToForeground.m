function bringToForeground(ax)
    
    TB = ancestor(ax,'uitab');
    while ~isempty(TB)
        TG=ancestor(TB,'uitabgroup');
        TG.SelectedTab = TB;
        TB=ancestor(TG,'uitab');
    end
end