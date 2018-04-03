function stackorder_menu(parent)
    % stackorder_menu context menu for sort order
    
    %FIXME doesn't seem to attach to all items
    c=uicontextmenu('Tag','StackOrderContext');
    set(parent,'UIContextMenu',c);
    uimenu(c,'Label','top',MenuSelectedFcnName(),{@setstack,'top'});
    uimenu(c,'Label','up',MenuSelectedFcnName(),{@setstack,'up'});
    uimenu(c,'Label','down',MenuSelectedFcnName(),{@setstack,'down'});
    uimenu(c,'Label','bottom',MenuSelectedFcnName(),{@setstack,'bottom'});
    
    function setstack(source,~,val)
        uistack(source.Parent,val);
    end
end
        