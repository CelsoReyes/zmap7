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
    
    if ~exist('label','var') || isempty(label)
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
        Futures.MenuSelectedFcn,@(~,~)symboledit_dlg(target,'MarkerSize'));
    uimenu(symbolmenu,'Label','Symbol Type ...',...
        Futures.MenuSelectedFcn,@(~,~)symboledit_dlg(target,'Marker'));
    uimenu(symbolmenu,'Label','Line Width ...',...
        Futures.MenuSelectedFcn,@(~,~)symboledit_dlg(target,'LineWidth'));
    uimenu(symbolmenu,'Label','Line Style ...',...
        Futures.MenuSelectedFcn,@(~,~)symboledit_dlg(target,'LineStyle'));
    uimenu(symbolmenu,'Label','Change Symbol Color ...',...
        Futures.MenuSelectedFcn, @(~,~)change_color);

    function change_color()
        lines = findobj('-regexp','Tag','\<mapax_part[0-9].*\>');
        if isempty(lines);disp('nothing to change');return;end
        n =listdlg('PromptString','Change color for which item?',...
            'SelectionMode','multiple',...
            'ListString',{lines.DisplayName});
        if ~isempty(n)
            c = uisetcolor(lines(n(1)));
            set(lines(n),'Color',c,'Visible','on');
        end
    end
end