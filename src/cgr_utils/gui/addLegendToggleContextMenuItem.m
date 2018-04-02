function addLegendToggleContextMenuItem(ax,parent, cm, position, separator)
    % ADDLEGENDTOGGLECONTEXTMENUITEM adds a menu item to a context menu at
    % desired position 'top' or 'bottom' alternately with a separator
    %
    % addLegendToggleContextMenuItem(ax,parent, cm, position, addseparator)
    % AX : axis for which the legend will be toggled
    % CM: UIContextMenu into which we will insert the menu item
    % POSITION: dictate where in menu to insert {'top' or 'bottom'}
    % SEPARATOR: add a separator to the menu item {'off', 'above','below'}
    if ~exist('separator','var')
        separator='off';
    end
    
    % validate inputs
    assert(isa(ax,'matlab.graphics.axis.Axes'),...
        'AX must be a valid matlab axes');
    
    if isempty(cm)
        cm=parent.UIContextMenu;
    end
    
    if isempty(cm) % STILL empty
        parent.UIContextMenu=uicontextmenu;
        cm=parent.UIContextMenu;
    end
    
    assert(isa(cm,'matlab.ui.container.ContextMenu'),...
        'CM must be a valid uicontextmenu item');
    
    assert(ismember(position,{'top','bottom'}),...
        'POSITION must be ''top'' or ''bottom''');
    
    assert(ismember(separator,{'above','below','off'}),...
        'SEPARATOR must be ''above'',''below'', or ''off''');
    
    % get (create) context menu attached to this item
    if isempty(cm)
        disp('empty cm')
        cm=uicontextmenu(parent);
    end
    
    label = 'Toggle Legend';
    h = findobj(cm,'Label',label);
    
    % if this context menu item already exists, remove it 
    if ~isempty(h)
        disp('deleting h')
        delete(h);
    end
    
    % add once again
    uimenu(cm,'Label', label, ...
        'Separator', tf2onoff(strcmp(separator,'above')),...
        'MenuSelectedFcn', @(~,~)legend(ax,'toggle') );
    
    % by default it adds it to the bottom of the menu, which is actually
    % the first item in the context menu's children
    
    %if we want it at the top, then do a circular shift
    if strcmp(position,'top') && ~isempty(cm.Children)
        disp('acting on top')
        cm.Children(end).Separator=tf2onoff(strcmp(separator,'below'));
        cm.Children=circshift(cm.Children,-1);
    end
    
    
end