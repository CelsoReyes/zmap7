function add_menu_divider(tag)
    % add a simple divider to the menu bar
    % adds to right of existing menus
    if nargin==0
        tag = 'menu_divider';
    end
    uimenu('Label','|',...
                    'Enable','off',...
                    'Tag',tag); % simple divider
end