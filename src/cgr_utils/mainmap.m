function h = mainmap(target)
    % MAINMAP - access zmap's main interactive map
    %
    % only one instance of the MainInteractiveMap exists,
    % and this method ensures that.
    % 
    % whenever accessing the MainInteractiveMap class,
    % get the pointer from here.
    % If the map already exists, then we'll provide it.
    % if not, and the primeCatalog is not empty, one is created.
    %
    % h = MAINMAP() get MainInteractiveMap handle
    % h = MAINMAP('figure') get the figure handle
    % h = MAINMAP('axes') get the plotting axes handle (the map itself)
    
   
    persistent main_interactive_map_instance
    
    if exist('target','var')
        switch target
            case 'axes'
                h=findobj(gcf,'Tag','mainmap_ax');
                if isempty(h)
                    h = fill_instance;
                    h = h.mainAxes;
                end
        end
    end
    
end