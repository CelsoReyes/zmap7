function h = mainmap()
    % mainmap - access zmap's main interactive map
    %
    % only one instance of the MainInteractiveMap exists,
    % and this method ensures that.
    % 
    % whenever accessing the MainInteractiveMap class,
    % get the pointer from here.
    % If the map already exists, then we'll provide it.
    % if not, and the primeCatalog is not empty, one is created.
   
    persistent main_interactive_map_instance
    if isempty(main_interactive_map_instance) 
        if ~isempty(ZmapGlobal.Data.primeCatalog)
            disp('creating an instance of MainInteractiveMap');
            main_interactive_map_instance = MainInteractiveMap();
        else
            h=[];
            return
        end
    end
    h = main_interactive_map_instance;
end