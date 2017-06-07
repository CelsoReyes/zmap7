function add_symbol_menu(target_tag, parent)
    % add a symbol_menu
    % target_tag : if a string, then tag name (combined with findoj)
    %              if a handle, then use the handle.
    % parent is an optional parameter that allows you to specify a specific menu item
    % leave blank to have this created as a child of the menu bar
    % symbolmenu - attach submenus directly to this existing menu instead of cre
    
    % cgr 2017
    if exist('parent','var') && ~isempty(parent)
        symbolmenu = uimenu(parent, 'Label', ' Symbol ');
    else
        symbolmenu = uimenu('Label',' Symbol ');
    end
    
    
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
    
    
end