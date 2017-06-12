classdef zmap_message_center < handle
    % this replaces the existing mess (welcome) window.
    % it is more robust, and is self-contained.
    
    methods
        function obj = zmap_message_center()
            h = findall(0,'tag','zmap_message_window');
            if (isempty(h))
                h = create_message_figure();
                startmen(h);
                obj.set_message('To get started...',...
                    ['Choose an import option from the "Data" menu', newline,...
                    'data can be imported from .MAT files, from  ', newline,...
                    'formatted text files, or from the web       ']);
                obj.end_action( );
            else
                % put it in focus
                figure(h)
            end
        end
        
        function set_message(obj, messageTitle, messageText, messageColor)
            titleh = findall(0,'tag','zmap_message_title');
            % TODO see if control still exists
            titleh.String = messageTitle;
            texth = findall(0,'tag','zmap_message_text');
            texth.String = messageText;
            if exist('messageColor','var')
                texth.ForegroundColor = messageColor;
            end
        end
        
        function clear_message(obj)
            titleh = findall(0,'tag','zmap_message_title');
            % TODO see if control still exists
            if ~isempty(titleh)
                titleh.String = 'Messages';
            end
            texth = findall(0,'tag','zmap_message_text');
            % TODO see if control still exists
            if ~isempty(texth)
                texth.String = '';
                texth.ForegroundColor = 'k';
            end
        end
        
        function start_action(obj, action_name)
            buth = findall(0,'tag','zmap_action_button');
            if ~isempty(buth)
                buth.String = action_name;
            end
            watchon();
        end
        
        function end_action(obj)
            buth = findall(0,'tag','zmap_action_button');
            if ~isempty(buth)
                buth.String = 'Ready, now idling';
            end
            watchoff();
        end
    end
end

function h = create_message_figure()
    % creates figure with following uicontrols
    %   TAG                 FUNCTION
    %   quit_button         leave matlab(?) 
    %   zmap_action_button  display current ation that is happening
    %   zmap_action_text    provide context for action button(?)
    %   welcome_text        welcome to zmap v whatever
    %   zmap_message_title  title of message
    %   zmap_message_text   text of message
    global wex wey welx wely fontsz
    hilighted_color = [0.8 0 0];
    
        h = figure();
        welcome_text = 'Welcome to ZMAP v 7.0';
        
        messtext = '  ';
        titStr ='Messages';
        rng('shuffle');
        
        set(h,'NumberTitle','off',...
            'Name','Message Window',...
            'MenuBar','none',...
            'Units','pixel',...
            'backingstore','off',...
            'tag','zmap_message_window',...
            'pos',[ wex wey welx wely]);
        h.Units = 'normalized';
        ax = gca;
        ax.Units = 'normalized';
        ax.Visible = 'off';
        te1 = text(0.02,0.9,welcome_text);
        set(te1,'FontSize',12,'Color','k','FontWeight','bold','Tag','welcome_text');
        
        te2 = text(0.11,0.90,'   ') ;
        set(te2,'FontSize',fontsz.s,'Color','k','FontWeight','bold','Tag','te2');
        
        % quit button
        uicontrol('Style','Pushbutton',...
            'Units', 'normalized',...
            'Position', [.80 .60 .15 .12 ],...
            'Callback','qui', ...
            'String','Quit', ...
            'Visible','on',...
            'Tag', 'quit_button');
            
        uicontrol(...
            'Units','normalized',...
            'BackgroundColor',[0.7 0.7 0.7 ],...
            'ForegroundColor',[0 0 0 ],...
            'Position',[0.26 0.60 0.50 0.12 ],...
            'String','   ',...
            'Style','pushbutton',...
            'Visible','on',...
            'Tag', 'zmap_action_button',...
            'UserData','frame1');
        
        text(0.40, 0.80,'Action:','Units','Norm','FontSize',fontsz.l,...
            'Color', hilighted_color,'FontWeight','bold','Tag','zmap_action_text');
        
        
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
            'Units','normalized', ...
            'Position',frmPos, ...
            'BackgroundColor',[0.6 0.6 0.6]);
        
        % Then the text label
        labelPos=[left top-labelHt (right-left) labelHt];
        
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',labelPos, ...
            'ForegroundColor',hilighted_color, ...
            'FontWeight','bold',...
            'Tag', 'zmap_message_title', ...
            'String',titStr);
        
        txtPos=[left bottom (right-left) top-bottom-labelHt-spacing];
        txtHndlList=uicontrol( ...
            'Style','edit', ...
            'Units','normalized', ...
            'Max',20, ...
            'String',messtext, ...
            'BackgroundColor',[1 1 1], ...
            'Visible','off', ...
            'Tag', 'zmap_message_text', ...
            'Position',txtPos);
        set(txtHndlList,'Visible','on');
end
