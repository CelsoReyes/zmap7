function add_menu_divider(fig,tag)
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
        fig = gcf;
        tag = 'menu_divider';
    elseif nargin==1
        if ischar(fig) || isstring(fig)
            tag = fig;
            fig = gcf;
        elseif isgraphics(fig) && isprop(fig,'Type') && fig.Type == "figure"
            tag = 'menu_divider';
        else
            error('expected argument to be figure or a tag label');
        end 
    end
    uimenu(fig,'Label','|',...
                    'Enable','off',...
                    'Tag',tag); % simple divider
end