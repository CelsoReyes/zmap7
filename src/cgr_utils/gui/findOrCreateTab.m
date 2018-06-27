function myTab = findOrCreateTab(fig, container, title, varargin)
    % FINDORCREATETAB return handle to a specified tab. if the tab doesn't exist, it is created
    %
    % tabH = FINDORCREATETAB( FIG, CONTAINER_TAG, TITLE, OPTS)
    %    FIG is a figure handle. The uitab with the Title "TITLE" will be returned only tabs
    %    belonging to this figure are returned. If the tab doesn't already exist, it will be
    %    created with the title TITLE within the container identified by the CONTAINER_TAG.
    %
    %    OPTS can be 'deleteable'
    %    CONTAINER_TAG can be the handle to a container, too.
    %
    %
    import callbacks.copytab

    deleteable= ismember('deleteable',varargin);
    if deleteable
        myTag='CopytabToFigDeleteable';
    else
        myTag='CopyTabToFig';
    end
    if ischar(container) || isstring(container)
        myContainer=findobj(fig,'Type','uitabgroup','-and','Tag',container);
    elseif isgraphics(container) && isvalid(container)
        myContainer=container;
        assert(ancestor(myContainer,'figure')==fig);
    else
        error('unspecified container');
    end
        
    myTab=findobj(myContainer.Children,'flat','Title',title,'-and','Type','uitab');
    if isempty(myTab)
        myTab=uitab(myContainer, 'Title',title);

        contextMenus = findobj(fig.Children,'flat','Tag',myTag,'-and','Type','uicontextmenu');
        
        if isempty(contextMenus)
            contextMenus=uicontextmenu(fig,'Tag',myTag);
            uimenu(contextMenus,'Label','Copy Contents to new figure (static)','Callback',@copytab)
            if deleteable
                uimenu(contextMenus,'Label','Close Tab','Callback',@(src,ev)delete(gco));
            end
        end
        myTab.UIContextMenu=contextMenus;
    end
end