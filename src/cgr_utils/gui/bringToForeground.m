function bringToForeground(ax)
    % brings an axis into the foreground of the figure, traversing tabs as necessary
    TB = ancestor(ax,'uitab');
    while ~isempty(TB)
        TG=ancestor(TB,'uitabgroup');
        TG.SelectedTab = TB;
        TB=ancestor(TG,'uitab');
    end
end