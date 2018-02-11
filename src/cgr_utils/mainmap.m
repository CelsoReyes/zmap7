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
    % h = MAINMAP('legend') get the legend handle
    % h = MAINMAP('reset') 
    
   
    persistent main_interactive_map_instance
    if exist('target','var')
        switch target
            case 'axes'
                h=findobj(gcf,'Tag','mainmap_ax');
                if isempty(h)
                    h = fill_instance;
                    h = h.mainAxes;
                end
            case 'figure'
                h = fill_instance;
                h = h.mainAxes;
                h = h.Parent;
                assert(isa(h,'matlab.ui.Figure') || isempty(h))
            case 'legend'
                h = fill_instance;
                h=h.mainAxes;
                h=h.Legend;
            case 'reset'
                main_interactive_map_instance=[];
                h=mainmap();
        end
    end
    function h=fill_instance()
        if isempty(main_interactive_map_instance)
            if ~isempty(ZmapGlobal.Data.primeCatalog)
                disp('creating an instance of MainInteractiveMap');
                main_interactive_map_instance = MainInteractiveMap();
            else
                h=[];
                return
            end
        end
    end
        
end