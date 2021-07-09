function addLegendToggleContextMenuItem(cm, position, separator)
    % ADDLEGENDTOGGLECONTEXTMENUITEM adds a menu item to a context menu at
    % desired position 'top' or 'bottom' alternately with a separator
    %
    % addLegendToggleContextMenuItem(cm, position, addseparator)
    % CM: UIContextMenu into which we will insert the menu item
    % POSITION: dictate where in menu to insert {'top' or 'bottom'} Default: bottom
    % SEPARATOR: add a separator to the menu item {'off', 'above','below'} Default: off
    if ~exist('separator','var')
        separator='off';
    end
    
    if ~exist('position','var') || isempty(position)
        position='bottom';
    end
    
    % validate inputs
    assert(isa(cm,'matlab.ui.container.ContextMenu'), 'CM must be a valid uicontextmenu item');
    assert(ismember(position,{'top','bottom'}), "POSITION must be 'top' or 'bottom'");
    assert(ismember(separator,{'above','below','off'}), "SEPARATOR must be 'above','below', or 'off'");
    
    
    label = 'Toggle Legend';
    h = findobj(cm,'Label',label);
    
    % if this context menu item already exists, remove it 
    if isempty(h)
        h=uimenu(cm,'Label', label);
    end
    h.Separator = tf2onoff(separator == "above");
    h.('MenuSelectedFcn') = @legend_cb;
    
    % by default add item to the bottom of the menu, which is actually
    % the first item in the context menu's children
    
    mypos = h==cm.Children;
    switch position
        case 'top'
            cm.Children = [cm.Children(~mypos); cm.Children(mypos)];
        case 'bottom'
            cm.Children = [cm.Children(mypos); cm.Children(~mypos)];
    end
    mypos = h==cm.Children;
    
    switch separator
        case 'above'
            h.Separator='on';
        case 'below'
            p=find(mypos);
            if p > 1
                cm.Children(p).Separator='on';
            end
        case 'off'
            h.Separator='off';
    end
    
    function legend_cb(~,~)
        l=legend(gca,'toggle');
        clear_empty_legend_entries(gca)
    end
    
end