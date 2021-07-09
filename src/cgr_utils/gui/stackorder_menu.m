function stackorder_menu(parent)
    % stackorder_menu context menu for sort order
    
    %FIXME doesn't seem to attach to all items
    c=uicontextmenu('Tag','StackOrderContext');
    set(parent,'UIContextMenu',c);
    uimenu(c,'Label','top'    , 'MenuSelectedFcn',@(s,~)setstack(s,'top'));
    uimenu(c,'Label','up'     , 'MenuSelectedFcn',@(s,~)setstack(s,'up'));
    uimenu(c,'Label','down'   , 'MenuSelectedFcn',@(s,~)setstack(s,'down'));
    uimenu(c,'Label','bottom' , 'MenuSelectedFcn',@(s,~)setstack(s,'bottom'));
    
    function setstack(source,val)
        uistack(source.Parent,val);
    end
end
        