function stackorder_menu(parent)
    % stackorder_menu context menu for sort order
    
    %FIXME doesn't seem to attach to all items
    c=uicontextmenu('Tag','StackOrderContext');
    set(parent,'UIContextMenu',c);
    uimenu(c,'Label','top',MenuSelectedField(),{@setstack,'top'});
    uimenu(c,'Label','up',MenuSelectedField(),{@setstack,'up'});
    uimenu(c,'Label','down',MenuSelectedField(),{@setstack,'down'});
    uimenu(c,'Label','bottom',MenuSelectedField(),{@setstack,'bottom'});
    
    function setstack(source,~,val)
        uistack(source.Parent,val);
    end
end
        