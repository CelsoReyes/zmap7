function c=context_menus(obj, tag, createmode, varargin)
    % manages context menus, which avoids repeatedly creating context menus
    % c=context_menus(obj, tag, createmode, varargin)
    % Contexts are attached to the figure, so deleting
    % objects that they are attached to will not delete the context menus.
    %
    % context menus can be reused.
    existing_contexts = findobj(obj.fig,'Type','uicontextmenu');
    c = findobj(existing_contexts, 'Tag',tag);
    
    switch createmode
        case 'overwrite'
            % delete existing context first, then recreate it and return handle
        case 'reuse'
            % if a context exists, just return a handle to it
    end
    switch tag
        
        
    end
end