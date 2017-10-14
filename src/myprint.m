function myprint(command,param1)
    % Symple print_tool to print to the
    % printer or to a ps file
    global  pri figp ptt
    %printdlg
    uiprint
    return
    report_this_filefun(mfilename('fullpath'));
    %
    %
    %  usage:       myprint(command,parameter1)
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
            'units','points');
        set(gca,'visible','off');
        
        %  Uicontrol Object Creation
        h(1) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'callback',@callbackfun_001,...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.25 0.44 0.4 0.05 ],...
            'String','Black and White Image',...
            'Style','checkbox',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(1)');
        h(2) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'callback',@callbackfun_002,...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.25 0.53 0.4 0.05 ],...
            'String','Color Image',...
            'Style','checkbox',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(2)');
        h(3) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'callback',@callbackfun_003,...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.15 0.6 0.60 0.06 ],...
            'String','Post-sript file',...
            'Style','radiobutton',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(3)');
        h(4) = uicontrol(...
            'BackgroundColor',[ 0.7 0.7 0.7 ],...
            'callback',@callbackfun_004,...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.15 0.8 0.6 0.06 ],...
            'String','Printer',...
            'Style','radiobutton',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(4)');
        h(5) = uicontrol(...
            'BackgroundColor',[ 1 1 0 ],...
            'callback',@callbackfun_005,...
            'ForegroundColor',[ 0 0 0 ],...
            'Position',[ 0.1 0.1 0.23 0.07 ],...
            'String','Print',...
            'Style','pushbutton',...
            'Units','normalized',...
            'Visible','on',...
            'UserData','h(5)');
        uicontrol(...
            'BackgroundColor',[ 1 1  0 ],...
            'callback',@callbackfun_006,...
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
            'Position',[ 0.21 0.99 0 ],...
            'FontSize',14,...
            'FontWeight','bold',...
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
        set(h(4),'Value',0)
        set(h(3),'Value',1)
        
    elseif command == 3
        pri = 'print -dpsc  ' ;
        set(h(4),'Value',0)
        set(h(3),'Value',1)
        set(h(2),'Value',1)
        set(h(1),'Value',0)
        
    elseif command == 4
        set(h(3),'Value',0)
        set(h(4),'Value',1)
        set(h(1),'Value',0)
        set(h(2),'Value',0)
        
    elseif command == 5
        
        % Print to printer
        if get(h(4),'Value')== 1
            drawnow('discard')
            figure(figp);
            whitebg(gcf,[1 1 1]);
            cuca = get(gca,'Color');
            set(gca,'Color','none');
            print
            whitebg(gcf,'Color',color_fbg)
            set(gca,'Color',cuca)
        end
        
        %Print to ps file
        if  get(h(3),'Value')== 1
            messtext=...
                ['Please select a filename             '
                'The current window will be printed   '
                'as a postscript file. Buttons etc are'
                'not printed.                         '];
            [file1,path1] = uigetfile(fullfile(ZmapGlobal.Data.data_dir,'out','*.ps'),'PS  Filename');
            
            messtext = ['Thank you! Printing in PS file...'];
            watchon;
            drawnow
            
            % Print the file
            drawnow('discard')
            figure(figp);
            whitebg(gcf,[1 1 1]);
            cuca = get(gca,'Color');
            set(gca,'Color',[1 1 1 ]);
            pri2 = [pri path1 file1];
            eval(pri2)
            whitebg(gcf,'Color',color_fbg)
            set(gca,'Color',cuca)
        end
        close(ptt)
        
    else
        error('Error: myprint.m called with incorrect command.')
        
    end
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint('h(1)');
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint('h(2)');
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint('h(3)');
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint('h(4)');
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint('h(5)');
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
end
