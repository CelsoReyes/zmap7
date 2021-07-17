function myTab = findOrCreateTab(fig, look_here_containers, create_here_tabgroup, title, varargin)
    % FINDORCREATETAB return handle to a specified tab. if the tab doesn't exist, it is created
    %
    % tabH = FINDORCREATETAB( FIG, CONTAINER_TAG, TITLE, OPTS)
    %    FIG is a figure handle. The uitab with the Title "TITLE" will be returned only tabs
    %    belonging to this figure are returned. If the tab doesn't already exist, it will be
    %    created with the title TITLE within the container identified by the CONTAINER_TAG.
    %
    %    OPTS can be 'deleteable',
    %    CONTAINER_TAG can be the handle to a container, too.
    %
    
    import callbacks.copytab

    assert(isgraphics(look_here_containers) && isvalid(look_here_containers), 'expected valid container');
    
    deleteable= ismember('deleteable',varargin);
    if deleteable
        myTag='CopytabToFigDeleteable';
    else
        myTag='CopyTabToFig';
    end
    
    if ischarlike(create_here_tabgroup)
        myContainer=findobj(fig,'Type','uitabgroup','-and','Tag',create_here_tabgroup);
    elseif isgraphics(create_here_tabgroup) && isvalid(create_here_tabgroup)
        myContainer=create_here_tabgroup;
        assert(ancestor(myContainer,'figure')==fig);
    else
        error('unspecified container');
    end
        
    myTab=findobj(look_here_containers, 'Type', 'uitab', '-and', 'Title', title);
    
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