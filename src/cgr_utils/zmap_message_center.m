classdef zmap_message_center < handle
    % zmap_message_center is the main control window for zmap.
    % it provides feedback on what operations zmap is performing, as well as help for
    % this replaces the existing mess (welcome) window.
    % it is more robust, and is self-contained.
    
    properties
    end
    
    methods
        function obj = zmap_message_center()
            % zmap_message_center provides handle used to access zmap message center functionality
            % the message center will be created if it doesn't exist, otherwise it will be made the
            % active figure
            
            h = findall(0,'tag','zmap_message_window');
            if (isempty(h))
                h = create_message_figure();
                startmen(h);
                dvmen = uimenu('Label','Developer');
                uimenu(dvmen,'Label','Refresh catalog summary','Callback','zmap_message_center.update_catalog()');
                zmap_message_center.set_message('To get started...',...
                    ['Choose an import option from the "Data" menu', newline,...
                    'data can be imported from .MAT files, from  ', newline,...
                    'formatted text files, or from the web       ']);
                obj.end_action( );
            else
                % put it in focus
                figure(h)
            end
        end
        
    end
    methods(Static)
        function create()
            h = findall(0,'tag','zmap_message_title');
            if isempty(h)
                zmap_message_center();
            end
        end
        function set_message(messageTitle, messageText, messageColor)
            % set_message displays a message to the user
            %
            % usage:
            %    msgcenter.set_message(title, text)
            %
            % see also set_warning, set_error, set_info, clear_message
            zmap_message_center.create();
            titleh = findall(0,'tag','zmap_message_title');
            % TODO see if control still exists
            titleh.String = messageTitle;
            texth = findall(0,'tag','zmap_message_text');
            texth.String = messageText;
            if exist('messageColor','var')
                titleh.ForegroundColor = messageColor;
            end
        end
        
        function set_warning(messageTitle, messageText)
            % set_warning displays a message to the user in orange
            zmap_message_center.set_message(messageTitle, messageText, [.8 .2 .2]);
        end
        
        function set_error(messageTitle, messageText)
            % set_error displays a message to the user in red
            zmap_message_center.set_message(messageTitle, messageText, [.8 0 0]);
        end
        
        function set_info(messageTitle, messageText)
            % set_info displays a messaget ot the user in blue
            zmap_message_center.set_message(messageTitle, messageText, [0 0 0.8]);
        end
        
        function clear_message()
            % clear_message will return the message center to neutral state
            %
            %  usage:
            %      msgcenter.clear_message()
            zmap_message_center.create();
            titleh = findall(0,'tag','zmap_message_title');
            % TODO see if control still exists
            if ~isempty(titleh)
                titleh.String = 'Messages';
                titleh.ForegroundColor = 'k';
            end
            texth = findall(0,'tag','zmap_message_text');
            % TODO see if control still exists
            if ~isempty(texth)
                texth.String = '';
            end
            zmap_message_center.update_catalog();
            
        end
        
        function update_catalog()
            %obj = zmap_message_center();
            update_current_catalog_pane();
            update_selected_catalog_pane();
        end
        
        function start_action(action_name)
            % start_action sets the text for the action button, and sets the spinner
            watchon();
        end
        
        function end_action()
            % end_action sets the text button to idling, and unsets the spinner
            watchoff();
        end
    end
end

function h = create_message_figure()
    % creates figure with following uicontrols
    %   TAG                 FUNCTION
    %   quit_button         leave matlab(?)
    %   welcome_text        welcome to zmap v whatever
    %   zmap_message_title  title of message
    %   zmap_message_text   text of message
    
    hilighted_color = [0.8 0 0];
    
    h = figure();
    welcome_text = 'Welcome to ZMAP v 7.0';
    
    messtext = '  ';
    titStr ='Messages';
    rng('shuffle');
    
    set(h,'NumberTitle','off',...
        'Name','Message Window',...
        'Units','pixel',...
        'Menu','none',...
        'backingstore','off',...
        'tag','zmap_message_window',...
        'Resize','off',...
        'pos',[23 212 340 585]);
    %h.Units = 'normalized';
    ax = axes('units','normalized','Position',[0 0 1 1]);;
    ax.Units = 'pixel';
    %ax.Units = 'normalized';
    ax.Visible = 'off';
    te1 = text(.05,.975, welcome_text);
    set(te1,'FontSize',ZmapGlobal.Data.fontsz.l,'Color','k','FontWeight','bold','Tag','welcome_text');
    
    te2 = text(0.05,0.94,'   ') ;
    set(te2,'FontSize',ZmapGlobal.Data.fontsz.s,'Color','k','FontWeight','bold','Tag','te2');
    
    % quit button
    uicontrol('Style','Pushbutton',...
        'Position', [235 555 85 30],...
        'Callback','qui', ...
        'String','Quit', ...
        'Visible','on',...
        'Tag', 'quit_button');
    
    
    % Display the message text
    %
    top=0.55;
    left=0.05;
    right=0.95;
    bottom=0.05;
    labelHt=0.050;
    spacing=0.05;
    
    % First, the Text Window frame
    frmBorder=0.02;
    frmPos=[left-frmBorder bottom-frmBorder ...
        (right-left)+2*frmBorder (top-bottom)+2*frmBorder];
    uicontrol( ...
        'Style','frame', ...
        'Position',[10 360 320 180], ...
        'BackgroundColor',[0.6 0.6 0.6]);
    
    % Then the text label
    labelPos=[left top-labelHt (right-left) labelHt];
    
    uicontrol( ...
        'Style','text', ...
        'Position',[20 500 300 30], ...
        'ForegroundColor',hilighted_color, ...
        'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.l,...
        'Tag', 'zmap_message_title', ...
        'String',titStr);
    
    txtPos=[left bottom (right-left) top-bottom-labelHt-spacing];
    txtHndlList=uicontrol( ...
        'Style','edit', ...
        'Max',20, ...
        'String',messtext, ...
        'BackgroundColor',[1 1 1], ...
        'Visible','off', ...
        'Tag', 'zmap_message_text', ...
        'Position',[20 373 300 125]);
    set(txtHndlList,'Visible','on');
    
    %%  add catalog details
    
    
    % create panel to hold catalog details
    cat1panel = uipanel(h,'Title','Main Catalog Summary',...
        'Units','pixels',...
        'Position',[15 190 315 160],...
        'Tag', 'zmap_curr_cat_pane');
    
    
    uicontrol('Parent',cat1panel,'Style','text', ...
        'String','No Catalog Loaded!',...
        'Units','normalized',...
        'Position',[0.05 0.4 .9 .55],...
        'HorizontalAlignment','left',...
        'FontName','FixedWidth',...
        'FontSize',10,...
        'FontWeight','bold',...
        'Tag','zmap_curr_cat_summary');
    
    %% BUTTONS
    % edit catalog
    uicontrol('Parent',cat1panel,'Style','Pushbutton', ...
        'String','Edit Ranges',...
        'Units','normalized',...
        'Position',[0.05 0.05 .3 .3],...
        'Callback',@do_catalog_overview,...
        'Tag','zmap_curr_cat_editbutton');
    
    % show map for this catalog
    uicontrol('Parent',cat1panel,'Style','Pushbutton', ...
        'String','Map',...
        'Units','normalized',...
        'Position',[0.65 0.05 .3 .3],...
        'Callback',@(s,e) update(mainmap()),...
        'Tag','zmap_curr_cat_mapbutton');
    
    % show timeseries for this catalog
    uicontrol('Parent',cat1panel,'Style','Pushbutton', ...
        'String','Timeseries',...
        'Units','normalized',...
        'Position',[0.35 0.05 .3 .3],...
        'Callback','timeplot(ZG.a)',... change to bring up timeseries
        'Tag','zmap_curr_cat_tsbutton');
    
    %% selected catalog panel
    % create panel to hold details for selected part of catalog
    cat2panel = uipanel(h,'Title','Selected Catalog Summary',...
        'Units','pixels',...
        'Position',[15,10, 315, 160],...
        'Tag', 'zmap_sel_cat_pane');
    
    
    uicontrol('Parent',cat2panel,'Style','text', ...
        'String','No sub-selection of catalog!',...
        'Units','normalized',...
        'Position',[0.05 0.1 .9 .85],...
        'HorizontalAlignment','left',...
        'FontName','FixedWidth',...
        'FontSize',10,...
        'FontWeight','bold',...
        'Tag','zmap_sel_cat_summary');
    %% BUTTONS
    % update catalog
    uicontrol('Parent',cat2panel,'Style','Pushbutton', ...
        'String','Edit Ranges',...
        'Units','normalized',...
        'Position',[0.05 0.05 .3 .3],...
        'Callback',@do_selected_catalog_overview,...
        'Tag','zmap_sel_cat_editbutton');
    
    % use this catalog, and show map
    uicontrol('Parent',cat2panel,'Style','Pushbutton', ...
        'String','USE (and map)',...
        'Units','normalized',...
        'Position',[0.65 0.05 .3 .3],...
        'Callback','ZG=ZmapGlobal.Data; replaceMainCatalog(ZG.newcat);zmap_message_center.update_catalog();update(mainmap())',...
        'TooltipString','Makes this catalog the active catalog',...
        'Tag','zmap_sel_cat_usebutton');
    
    % show timeseries for this catalog
    uicontrol('Parent',cat2panel,'Style','Pushbutton', ...
        'String','Timeseries',...
        'Units','normalized',...
        'Position',[0.35 0.05 .3 .3],...
        'Callback','timeplot(ZG.newcat)',... change to bring up timeseries
        'Tag','zmap_sel_cat_tsbutton');
    
    update_current_catalog_pane();
    update_selected_catalog_pane();
    
end

function do_catalog_overview(s,~)
    ZG=ZmapGlobal.Data; % get zmap globals
    replaceMainCatalog(catalog_overview(ZG.a));
    zmap_message_center.update_catalog();
    %update_current_catalog_pane(s);
end

function do_selected_catalog_overview(s,~)
    
ZG=ZmapGlobal.Data; % get zmap globals
ZG.newcat = catalog_overview(ZG.newcat);
    zmap_message_center.update_catalog();
    %update_current_catalog_pane(s);
    %update_selected_catalog_pane(s);
end

function set_mapbutton_enable(val)
    h = findobj( 'Tag','zmap_curr_cat_mapbutton');
    h.Enable = val;
end
function set_timeseriesbutton_enable(val)
    h = findobj( 'Tag','zmap_curr_cat_tsbutton');
    h.Enable = val;
end

function set_editbutton_enable(val)
    h = findobj( 'Tag','zmap_curr_cat_editbutton');
    h.Enable = val;
end

function update_current_catalog_pane(~,~)
    
ZG=ZmapGlobal.Data; % get zmap globals
    if ~isempty(ZG.a)
        if isa(ZG.a,'ZmapCatalog')
            mycat = ZG.a;
        elseif isnumeric(ZG.a) && size(ZG.a,2)>=9
            % old style zmap array
            mycat=ZmapCatalog(ZG.a,'a');
        else
            % no map loaded, apparently
            warning('current catalog doesn''t seem to contain the right kind of data');
            h = findall(0,'tag','zmap_curr_cat_summary');
            h.String = 'No catalog loaded';
            set_mapbutton_enable('off');
            set_timeseriesbutton_enable('off');
            set_editbutton_enable('off');
            return
        end
        h = findall(0,'tag','zmap_curr_cat_summary');
        h.String = mycat.summary('simple');
        set_mapbutton_enable('on');
        set_timeseriesbutton_enable('on');
        set_editbutton_enable('on');
        return
    else
        h = findall(0,'tag','zmap_curr_cat_summary');
        h.String = 'No catalog loaded';
        set_mapbutton_enable('off');
        set_timeseriesbutton_enable('off');
        set_editbutton_enable('off');
    end
end

function update_selected_catalog_pane(~,~)

ZG=ZmapGlobal.Data; % get zmap globals
    
    if ~isempty(ZG.newcat)
        if ~isa(ZG.newcat,'ZmapCatalog')
            ZG.newcat=ZmapCatalog(ZG.newcat,'ZG.newcat');
        end
        h = findall(0,'tag','zmap_sel_cat_summary');
        h.String = ZG.newcat.summary('simple');
    else
        h = findall(0,'tag','zmap_sel_cat_summary');
        h.String = 'No subset selected';
    end
end


