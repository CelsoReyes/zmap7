function selbpi(command,param1)
    % Symple print_tool to print to the
    % printer or to a ps file
    global sys hodi pri c1 c2 c3 figp ptt
    report_this_filefun(mfilename('fullpath'));
    %
    %
    %  usage:       selbpi(command,parameter1)
    %
    %           where
    %
    %               'command' is used to perform some defined operation
    %               'parameter1' can be used pass extra information
    %                              to a defined operation
    %
    %           If no arguements are used the GUI is initialized.
    %
    %
    %  Created: 19-Dec-94
    %  Using  : guimaker by Patrick Marchand
    %                         (pmarchan@motown.ge.com)
    %  Author :  Stefan Wiemer 12/94
    %  Mods.  :
    %

    %  Copyright (c) 1994 by Patrick Marchand
    %       Permission is granted to modify and re-distribute this
    %	code in any manner as long as this notice is preserved.
    %	All standard disclaimers apply.


    if nargin == 0
        command = 'new';
    end

    if ischar(command)
        if strcmpi(command,'initialize') || strcmpi(command,'new')
            command = 0;
        elseif strcmpi(command,'h(1)')
            command = 1;
        elseif strcmpi(command,'h(2)')
            command = 2;
        elseif strcmpi(command,'h(3)')
            command = 3;
        elseif strcmpi(command,'h(4)')
            command = 4;
        elseif strcmpi(command,'h(5)')
            command = 5;
        end
    end

    if command ~= 0
        handle_list = get(gcf,'userdata');
        if ~isempty(handle_list)
            h(1) = handle_list(1);
            h(2) = handle_list(2);
            h(3) = handle_list(3);
            h(4) = handle_list(4);
            h(5) = handle_list(5);
            txt1 = handle_list(6);
        end
    end


    if command == 0
        figp = gcf;
        ptt = figure_w_normalized_uicontrolunits('position',[200 200 250 350 ],...
            'resize','on',...
            'Name','Print Tool ',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'MenuBar','none',...
            'units','points');
        set(gca,'visible','off');

        %  Uicontrol Object Creation
        h(1) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'Callback','selbpi(''h(1)'');',...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.25 0.44 0.4 0.05 ],...
            'String','fixed ',...
            'Style','checkbox',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(1)');
        h(2) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'Callback','selbpi(''h(2)'');',...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.25 0.53 0.4 0.05 ],...
            'String','automatic',...
            'Style','checkbox',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(2)');
        h(3) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'Callback','selbpi(''h(3)'');',...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.15 0.6 0.60 0.06 ],...
            'String','Weighted LS',...
            'Style','edit',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(3)');
        h(4) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'Callback','selbpi(''h(4)'');',...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.15 0.8 0.6 0.06 ],...
            'String','Max Likelihood',...
            'Style','edit',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(4)');
        h(5) = uicontrol(...
            'BackgroundColor',[ 1 1 0 ],...
            'Callback','selbpi(''h(5)'');',...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.1 0.1 0.23 0.07 ],...
            'String','Go',...
            'Style','pushbutton',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(5)');
        uicontrol(...
            'BackgroundColor',[ 1 1  0 ],...
            'Callback','close;done',...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.7 0.1 0.23 0.07 ],...
            'String','Close',...
            'Style','pushbutton',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(5)');


        handle_ui_list = [h(1) h(2) h(3) h(4) h(5) ];


        %  Text Object Creation
        txt1 = text(...
            'Color',[ 1 0 0 ],...
            'EraseMode','normal',...
            'Position',[ 0.21 0.99 0 ],...
            'FontSize',14,...
            'FontWeight','bold',...
            'Rotation',[ 0 ],...
            'String','ZMAP Print-Tool');

        handle_txt_list = [txt1 ];


        handle_list = [handle_ui_list handle_txt_list];
        set(gcf,'userdata',handle_list);


    elseif command == 1
        pri = 'print -dps  ';
        set(h(1),'Value',1)
        set(h(2),'Value',0)

    elseif command == 2
        pri = 'print -dpsc  ' ;
        set(h(2),'Value',1)
        set(h(1),'Value',0)
        set(h(3),'Value',1)

    elseif command == 3
        pri = 'print -dpsc  ' ;
        set(h(3),'Value',1)
        set(h(2),'Value',1)
        set(h(1),'Value',0)

    elseif command == 4
        set(h(3),'Value',0)
        set(h(1),'Value',0)
        set(h(2),'Value',0)

    elseif command == 5

        % Print to printer
        if get(h(4),'Value')== 1
            drawnow
            % drawnow('discard') % DISCARD option removed form matlab -CGR
            figure_w_normalized_uicontrolunits(figp)
            whitebg(gcf,[1 1 1]);
            cuca = get(gca,'Color');
            set(gca,'Color','none');
            print
            whitebg(gcf,[c1 c2 c3])
            set(gca,'Color',cuca)
        end

        %Print to ps file
        if  get(h(3),'Value')== 1
            messtext=...
                ['Please select a filename             '
                'The current window will be printed   '
                'as a postscript file. Buttons etc are'
                'not printed.                         '];
            welcome('Print',messtext)
            if sys(1:3)=='SUN' || sys(1:3)=='SOL'
                [file1,path1] = uigetfile([hodi  '/out/*.ps'],'PS  Filename');
            end
            if sys(1:2)=='PC'
                [file1,path1] = uiputfile([hodi  '\out\*.ps'],' PS Filename');
            end

            messtext = 'Thank you! Printing in PS file...';
            welcome('  ',messtext)
            watchon;
            drawnow

            % Print the file
            % drawnow('discard'); % DISCARD option removed form matlab -CGR
            figure_w_normalized_uicontrolunits(figp)
            whitebg(gcf,[1 1 1]);
            cuca = get(gca,'Color');
            set(gca,'Color',[1 1 1 ]);
            pri2 = [pri path1 file1];
            eval(pri2)
            whitebg(gcf,[c1 c2 c3])
            set(gca,'Color',cuca)
        end
        close(ptt)
        welcome(' ',' ')
        done
    else
        error('Error: selbpi.m called with incorrect command.')

    end
