function stackorder_menu(parent)
    % stackorder_menu context menu for sort order
    
    %FIXME doesn't seem to attach to all items
    c=uicontextmenu('Tag','StackOrderContext');
    set(parent,'UIContextMenu',c);
    uimenu(c,'Label','top'    , MenuSelectedField(),@(s,~)setstack(s,'top'));
    uimenu(c,'Label','up'     , MenuSelectedField(),@(s,~)setstack(s,'up'));
    uimenu(c,'Label','down'   , MenuSelectedField(),@(s,~)setstack(s,'down'));
    uimenu(c,'Label','bottom' , MenuSelectedField(),@(s,~)setstack(s,'bottom'));
    
    function setstack(source,val)
        uistack(source.Parent,val);
    end
end
        