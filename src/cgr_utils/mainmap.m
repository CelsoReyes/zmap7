function h = mainmap()
    % mainmap - access zmap's main interactive map
    %
    % only one instance of the MainInteractiveMap exists,
    % and this method ensures that.
    % 
    % whenever accessing the MainInteractiveMap class,
    % get the pointer from here.
    % If the map already exists, then we'll provide it, otherwise
    % one is created.
   
    persistent main_interactive_map_instance
    if isempty(main_interactive_map_instance)
        disp('creating an instance of MainInteractiveMap');
        main_interactive_map_instance = MainInteractiveMap();
    end
    h = main_interactive_map_instance;
end