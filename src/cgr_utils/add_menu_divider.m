function add_menu_divider(tag)
    % add_menu_divider add inactive item "|" to the menu bar, to right of existing menus
    %
    % ex, excerpt from typical menu, adding divider, and 'Ztools' menu
    %   fig=figure;
    %   add_menu_divider()
    %   uimenu('Label','Ztools');
    %
    % makes a menu that looks like...
    % File Edit ... Window Help | Ztools
    %
    %                           ^
    %    this function creates this
    
    if nargin==0
        tag = 'menu_divider';
    end
    uimenu('Label','|',...
                    'Enable','off',...
                    'Tag',tag); % simple divider
end