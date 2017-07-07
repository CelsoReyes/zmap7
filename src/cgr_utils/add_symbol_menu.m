function add_symbol_menu(target, parent, label)
    % add_symbol_menu add menuitems to change symbol(marker) style, size, and color
    %
    % add_symbol_menu(target) create a default symbol menu, affecting the axes designated by 'target'
    %     where TARGET [required] is either the Tag name (string) or handle to a line/axis object
    %
    %       Note: by providing a Tag name instead of a handle, resolving the target is deferred
    %         until the menu item is chosen.  This way the axes must not necessarily be created
    %         prior to creating the menu
    %
    % add_symbol_menu(target, parent) creates a default symbol menu subordinate to 'parent', where
    %     PARENT is an optional parameter that allows you to specify a specific menu item.  Leave
    %     this blank to have this created as a child of the main menu bar.
    %
    % add_symbol_menu(target, parent, label) will additionally use the provided label instead of the
    %     default.  This is what the user sees as the menu item
    
    % cgr 2017
    
    if ~exist('label','var') || isempty('label')
        label = 'Symbol';
    end
    
    % create a menu, under which the other options (color,type,shape) will be provided
    if exist('parent','var') && ~isempty(parent)
        % create as subordinate to the parent menu item
        symbolmenu = uimenu(parent, 'Label', label);
    else
        % create on main menu bar
        symbolmenu = uimenu('Label', label);
    end
    
    % we do not test the target to see if it is valid, because it might not be valid until the 
    % menu button is pressed.  It SHOULD ideally be either a handle or a Tag.
    
    uimenu(symbolmenu,'Label','Symbol Size ...',...
        'Callback',@(~,~)symboledit_dlg(target,'MarkerSize'));
    uimenu(symbolmenu,'Label','Symbol Type ...',...
        'Callback',@(~,~)symboledit_dlg(target,'Marker'));
    uimenu(symbolmenu,'Label','Change Symbol Color ...',...
        'Callback', @(~,~)change_color);
            
    %{
        %% old version
        % TODO: delete these
    % master lists for the menu options as {'menulabel', value; ...}
    
    avail_sizes={'3',3;'6',6;'9',9;'12',12;'14',14;'18',18;'24',24};
    
    avail_symbols = {
        'dot','.';
        '+','+';
        'o','o';
        'x','x';
        '*','*'};
    
    avail_colors = {
        'black', 'k';
        'white','w';
        'red','r';
        'blue','b';
        'yellow','y'
        };
    
    add_size_menu(symbolmenu);
    add_type_menu(symbolmenu);
    add_color_menu(symbolmenu);
    
    
    function add_size_menu(parentmenu)
        submenu = uimenu(parentmenu,'Label',' Symbol Size ');
        
        for n=1:size(avail_sizes,1)
            uimenu(submenu,'Label',avail_sizes{n,1},...
                'Callback', {@set_symbol_size, target_tag, avail_sizes{n,2}});
        end
        
        function set_symbol_size(~, ~, target_tag, val)
            global ms6 vi
            vi='on';
            ms6=val;
            
            set_this_property(target_tag, 'MarkerSize', val);
        end
    end
    
    function add_type_menu(parentmenu)
        submenu = uimenu(parentmenu,'Label',' Symbol Type ');
        
        for n=1:size(avail_symbols,1)
            uimenu(submenu,'Label',avail_symbols{n,1},...
                'Callback', {@set_symbol_type, target_tag, avail_symbols{n,2}});
        end
        
        
        uimenu(submenu,'Label','none','Callback',{@hide, target_tag});
        
        function hide(~, ~, target_tag)
            global vi
            vi='off';
            set(target_tag,'visible','off');
        end
        
        function set_symbol_type(~, ~, target_tag, val)
            global ty vi
            vi='on';
            ty=val;
            set_this_property(target_tag, 'Marker', val);
        end
        
    end
    function add_color_menu(parentmenu)
        submenu = uimenu(parentmenu,'Label',' Symbol Color ');
        for n=1:size(avail_colors,1)
            uimenu(submenu,'Label',avail_colors{n,1},...
                'Callback', {@set_symbol_color, target_tag, avail_colors{n,2}});
        end
        
        function set_symbol_color(~, ~, target_tag, val)
            global co vi
            vi='on';
            co=val;
            set_this_property(target_tag, 'color', val);
        end
        
        
    end
    function set_this_property(target_tag, field, val)
        % make sure we have a real target, then do the adjustment
        if char(target_tag)
            target = findobj(gcf, 'Tag', target_tag);
        else
            target = target_tag;
        end
        if ~isempty(target)
            set(target, field, val,'visible','on');
        else
            complain('target axis not found');
        end
    end
    
    function complain(msg)
        % centralized messaging function
        disp(msg);
    end
    %}
    
end