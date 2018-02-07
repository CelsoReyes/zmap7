classdef ZmapMessageCenter < handle
    % ZmapMessageCenter is the main control window for zmap.
    % it provides feedback on what operations zmap is performing, as well as help for
    % this replaces the existing mess (welcome) window.
    % it is more robust, and is self-contained.
    %
    % A single instance is created, and reused where possible. 
    %
    % ZmapMessageCenter methods:
    %
    %  ZmapMessageCenter - get handle to existing ZmapMessageCenter, else create one
    %
    % Messaging methods:
    %   set_message - send a message to the console
    %   set_warning - send a warning to the console & dialog box
    %   set_error -  create error dialog box
    %   set_info - send a message to a dialog box
    %
    %   update_catalog - refresh the catalog information
    
    properties
    end
    
    methods
        function obj = ZmapMessageCenter()
            % ZmapMessageCenter provides handle used to access zmap message center functionality
            % the message center will be created if it doesn't exist, otherwise it will be made the
            % active figure
            
            h = findall(0,'tag','zmap_message_window');
            if (isempty(h))
                h = create_message_figure();
                startmen(h);
                dvmen = uimenu('Label','Developer');
                uimenu(dvmen,'Label','Refresh catalog summary','Callback','ZmapMessageCenter.update_catalog()');
                ZmapMessageCenter.set_message('To get started...',...
                    ['Choose an import option from the "Data" menu', newline,...
                    'data can be imported from .MAT files, from  ', newline,...
                    'formatted text files, or from the web       ']);
            else
                % put it in focus
                figure(h)
            end
        end
        
    end
    methods(Static)

        function set_message(messageTitle, messageText)
            % set_message displays a message to the user
            %
            % usage:
            %    msgcenter.set_message(title, text)
            fprintf('\n---<strong> ZMAP MESSAGE: %s </strong>---\n%s\n\n',messageTitle,messageText);
        end
        
        function set_warning(messageTitle, messageText)
            % set_warning displays a message to the user
            fprintf('\n+++<strong> ZMAP WARNING: %s </strong>+++\n%s\n\n',messageTitle,messageText);
        end
        
        function set_error(messageTitle, messageText)
            % set_error displays a message to the user
            fprintf('\n>>><strong> ZMAP ERROR: %s </strong><<<\n%s\n\n',messageTitle,messageText);
            errordlg(messageText,messageTitle,'modal');
        end
        
        function set_info(messageTitle, messageText)
            % set_info displays a message to the use
            fprintf('\n---<strong> ZMAP INFO: %s </strong>---\n%s\n\n',messageTitle,messageText);
        end
        
        function clear_message()
            close(findall(0,'Tag','msginfo'));
            % DO NOTHING
        end
        
        function update_catalog()
            %obj = ZmapMessageCenter();
            update_current_catalog_pane();
            update_selected_catalog_pane();
            update_other_catalog_pane();
        end
        
    end
end

function h = create_message_figure()
    % creates figure with following uicontrols
    %   TAG                 FUNCTION
    %   quit_button         leave matlab(?)
    %   welcome_text        welcome to zmap v whatever
    ZG = ZmapGlobal.Data;
    hilighted_color = [0.8 0 0];
    
    h = figure();
    welcome_text = 'Welcome to ZMAP v 7.0';
    
    messtext = '  ';
    titStr ='Messages';
    rng('shuffle');
    
    set(h,'NumberTitle','off',...
        'Name','Zmap Info Center',...
        'Units','pixel',...
        'Menu','none',...
        'backingstore','off',...
        'tag','zmap_message_window',...
        'Resize','off',...
        'pos',position_in_current_monitor(390,665,'left',25));
    %h.Units = 'normalized';
    ax = axes('units','normalized','Position',[0 0 1 1]);
    ax.Units = 'pixel';
    %ax.Units = 'normalized';
    ax.Visible = 'off';
    uicontrol('Style','text',...
        'Units','pixel',...
        'Position',[0 430 350 35]+ [0 180 0 0],...
        'FontSize',ZmapGlobal.Data.fontsz.l,...
        'FontWeight','bold',...
        'String', welcome_text,...
        'Tag','welcome_text');
    
    % quit button
    uicontrol('Style','Pushbutton',...
        'Position', [235 15 85 30],...
        'Callback',@(~,~)restartZmap,...
        'String','Quit', ...
        'Visible','on',...
        'Tag', 'quit_button');
    
    %%  add catalog details
    
    
    % create panel to hold catalog details
    cat1panel = uipanel(h,'Title','Main Catalog Summary [primeCatalog]',...
        'Units','pixels',...
        'Position',[15 240 365 170]+ [0 180 0 0],...
        'Tag', 'zmap_curr_cat_pane');
    
    
    uicontrol('Parent',cat1panel,'Style','text', ...
        'String','No Catalog Loaded!',...
        'Units','normalized',...
        'Position',[0.05 0.4 .9 .55],...
        'HorizontalAlignment','left',...
        'FontName','FixedWidth',...
        'FontSize',ZG.fontsz.s,...
        ...'FontSize',10,...
        'FontWeight','bold',...
        'Tag','cat_summary');
    
    %% BUTTONS
    % edit catalog
    uicontrol('Parent',cat1panel,'Style','Pushbutton', ...
        'String','Edit Ranges',...
        'Units','normalized',...
        'Position',[0.05 0.05 .3 .25],...
        'Callback',@do_catalog_overview,...
        'Tag','editbutton');
    
    % show map for this catalog
    uicontrol('Parent',cat1panel,'Style','Pushbutton', ...
        'String','Map',...
        'Units','normalized',...
        'Position',[0.65 0.05 .3 .25],...
        'Callback',@(s,e) zmap_update_displays('showmap'),...
        'Tag','useandmapbutton');
    
    % show cum timeplot for this catalog
    uicontrol('Parent',cat1panel,'Style','Pushbutton', ...
        'String','Cum. Timeplot',...
        'Units','normalized',...
        'Position',[0.35 0.05 .3 .25],...
        'Callback',{@do_timeplot,'primeCatalog'},... change to bring up cum timeplot
        'Tag','tsbutton');
    
    
    
    
    %% create panel to hold catalog details
    cat3panel = uipanel(h,'Title','Catalog Summary [newt2]',...
        'Units','pixels',...
        'Position',[15 240 365 170],...
        'Tag', 'zmap_other_cat_pane');
    
    
    uicontrol('Parent',cat3panel,'Style','text', ...
        'String','No Catalog Loaded!',...
        'Units','normalized',...
        'Position',[0.05 0.4 .9 .55],...
        'HorizontalAlignment','left',...
        'FontName','FixedWidth',...
        'FontSize',ZG.fontsz.s,...
        ...'FontSize',10,...
        'FontWeight','bold',...
        'Tag','cat_summary');
    
    %% BUTTONS
    % edit catalog
    uicontrol('Parent',cat3panel,'Style','Pushbutton', ...
        'String','Edit Ranges',...
        'Units','normalized',...
        'Position',[0.05 0.05 .3 .25],...
        'Callback',@do_other_catalog_overview,...
        'Tag','editbutton');
    
   % use this catalog, and show map
    uicontrol('Parent',cat3panel,'Style','Pushbutton', ...
        'String','USE (and map)',...
        'Units','normalized',...
        'Position',[0.65 0.05 .3 .25],...
        'Callback','ZG=ZmapGlobal.Data; replaceMainCatalog(ZG.newt2);zmap_update_displays(''showmap'');',...
        'TooltipString','Makes this catalog the active catalog',...
        'Tag','useandmapbutton');
    
    % show cum timeplot for this catalog
    uicontrol('Parent',cat3panel,'Style','Pushbutton', ...
        'String','Cum. Timeplot',...
        'Units','normalized',...
        'Position',[0.35 0.05 .3 .25],...
        'Callback',{@do_timeplot,'newt2'}',... change to bring up cum timeplot
        'Tag','tsbutton');
    
    
    
    %% selected catalog panel
    % create panel to hold details for selected part of catalog
    cat2panel = uipanel(h,'Title','Catalog Summary [newcat]',...
        'Units','pixels',...
        'Position',[15, 60, 365, 170],...
        'Tag', 'zmap_sel_cat_pane');
    
    
    uicontrol('Parent',cat2panel,'Style','text', ...
        'String','No sub-selection of catalog!',...
        'Units','normalized',...
        'Position',[0.05 0.1 .9 .85],...
        'HorizontalAlignment','left',...
        'FontName','FixedWidth',...
        'FontSize',ZG.fontsz.s,...
        'FontWeight','bold',...
        'Tag','cat_summary');
    %% BUTTONS
    % update catalog
    uicontrol('Parent',cat2panel,'Style','Pushbutton', ...
        'String','Edit Ranges',...
        'Units','normalized',...
        'Position',[0.05 0.05 .3 .25],...
        'Callback',@do_selected_catalog_overview,...
        'Tag','editbutton');
    
    % use this catalog, and show map
    uicontrol('Parent',cat2panel,'Style','Pushbutton', ...
        'String','USE (and map)',...
        'Units','normalized',...
        'Position',[0.65 0.05 .3 .25],...
        'Callback','ZG=ZmapGlobal.Data; replaceMainCatalog(ZG.newcat);zmap_update_displays(''showmap'');',...
        'TooltipString','Makes this catalog the active catalog',...
        'Tag','useandmapbutton');
    
    % show cum timeplot for this catalog
    uicontrol('Parent',cat2panel,'Style','Pushbutton', ...
        'String','Cum. Timeplot',...
        'Units','normalized',...
        'Position',[0.35 0.05 .3 .25],...
        'Callback',{@do_timeplot,'newcat'},... change to bring up cum timeplot
        'Tag','tsbutton');
    
    update_current_catalog_pane();
    update_other_catalog_pane();
    update_selected_catalog_pane();
    
end

function do_timeplot(s,~, catName)
    disp(['ZmapMessageCenter.do_timeplot ', catName])
    ZG=ZmapGlobal.Data;
    ZG.newt2=ZmapCatalog(ZG.(catName));
    timeplot();
end

function do_catalog_overview(s,~)
    ZG=ZmapGlobal.Data; % get zmap globals
    [ZG.Views.primary,ZG.maepi,ZG.big_eq_minmag] = catalog_overview(ZG.Views.primary, ZG.big_eq_minmag);
    %zmap_update_displays();
    ZmapMessageCenter.update_catalog();
end

function do_selected_catalog_overview(s,~)
    
    ZG=ZmapGlobal.Data; % get zmap globals
    cf=@()ZG.newcat;
    [tmpcat,ZG.maepi,ZG.big_eq_minmag] = catalog_overview(ZmapCatalogView(cf), ZG.big_eq_minmag);
    ZG.newcat=tmpcat.Catalog();
     ZmapMessageCenter.update_catalog();
end

function do_other_catalog_overview(s,~)
    
    ZG=ZmapGlobal.Data; % get zmap globals
    cf=@()ZG.newt2;
    [tmpcat,ZG.maepi,ZG.big_eq_minmag] = catalog_overview(ZmapCatalogView(cf), ZG.big_eq_minmag);
    ZG.newt2=tmpcat.Catalog();
    ZmapMessageCenter.update_catalog();
end

function update_other_catalog_pane(~,~)
    
    ZG=ZmapGlobal.Data; % get zmap globals
    
    % TODO (maybe) make sure it is a catalog, if not convert.
    nocat_message='No catalog loaded';
    summary_depth='simple';
    update_catalog_pane('zmap_other_cat_pane',ZG.newt2,summary_depth, nocat_message);
end

function update_current_catalog_pane(~,~)
    
    ZG=ZmapGlobal.Data; % get zmap globals
    
    % TODO (maybe) make sure it is a catalog, if not convert.
    nocat_message='No catalog loaded';
    summary_depth='simple';
    update_catalog_pane('zmap_curr_cat_pane',ZG.primeCatalog,summary_depth, nocat_message);
end

function update_selected_catalog_pane(~,~)

    ZG=ZmapGlobal.Data; % get zmap globals
    
    % TODO (maybe) make sure it is a catalog, if not convert.
    nocat_message='No subset selected';
    summary_depth='simple';
    update_catalog_pane('zmap_sel_cat_pane',ZG.newcat,summary_depth, nocat_message);
    
end

function update_catalog_pane(pane, mycat, summary_depth, nocat_message)
    %update_catalog_pane updates the ui controls in the summary panes
    %
    % update_catalog_pane(pane, mycat, summary_depth, nocat_message)
    %  pane : either handle or tag for the uipanel containing controls
    % mycat: catalog of interest
    % nocat_message: message to show when catalog is empty
    
    if ishandle(pane)
        src=pane;
    else
        src=findobj('Tag',pane); 
    end
    
    state=tf2onoff(~isempty(mycat));
    affected={'tsbutton','useandmapbutton','editbutton'};
    for i=1:numel(affected)
        set(findobj(src,'Tag',affected{i}),'Enable',state);
    end
    if ~isempty(mycat)
        s = mycat.summary(summary_depth);
    else
        s= nocat_message;
    end
    set(findobj(src,'Tag','cat_summary'), 'String', s);
    % drawnow
end
    
    
