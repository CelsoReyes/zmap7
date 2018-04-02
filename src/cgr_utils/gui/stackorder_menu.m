function stackorder_menu(parent)
    % stackorder_menu context menu for sort order
    
    %FIXME doesn't seem to attach to all items
    c=uicontextmenu('Tag','StackOrderContext');
    set(parent,'UIContextMenu',c);
    uimenu(c,'Label','top','MenuSelectedFcn',{@setstack,'top'});
    uimenu(c,'Label','up','MenuSelectedFcn',{@setstack,'up'});
    uimenu(c,'Label','down','MenuSelectedFcn',{@setstack,'down'});
    uimenu(c,'Label','bottom','MenuSelectedFcn',{@setstack,'bottom'});
    
    function setstack(source,~,val)
        uistack(source.Parent,val);
    end
end
        