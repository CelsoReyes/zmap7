function stackorder_menu(parent)
    % stackorder_menu context menu for sort order
    
    %TOFIX doesn't seem to attach to all items
    c=uicontextmenu;
    set(parent,'UIContextMen',c);
    uimenu(c,'Label','top','Callback',{@setstack,'top'});
    uimenu(c,'Label','up','Callback',{@setstack,'up'});
    uimenu(c,'Label','down','Callback',{@setstack,'down'});
    uimenu(c,'Label','bottom','Callback',{@setstack,'bottom'});
    
    function setstack(source,~,val)
        uistack(source.Parent,val);
    end
end
        