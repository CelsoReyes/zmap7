function fixaxmo() 
    % make dialog interface for the fixing of colomap
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    
    %
    report_this_filefun();
    ZG.freeze_colorbar = false;
    
    
    %initial values
    f = figure_w_normalized_uicontrolunits();
    clf
    set(gca,'visible','off')
    set(f,'Units','pixel','NumberTitle','off','Name','Input Parameters');
    
    set(f,'pos',[ ZG.welcome_pos, ZG.welcome_len + [200, -50]]);
    
    
    % creates a dialog box to input some parameters
    %
    
    inp2_field  = uicontrol('Style','edit',...
        'Position',[.80 .775 .18 .15],...
        'Units','normalized',...
        'String',num2str(-5),...
        'Value',-5,...
        'callback',@callbackfun_001);
    
    txt2 = text(...
        'Position',[0. 0.9 0 ],...
        'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'String','Please input minimum of z-axis:');
    
    
    txt3 = text(...
        'Position',[0. 0.65 0 ],...
        'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'String','Please input maximum of z(or b)-values:');
    
    inp3_field=uicontrol('Style','edit',...
        'Position',[.80 .575 .18 .15],...
        'Units','normalized',...
        'String',num2str(5),...
        'Value',5,...
        'callback',@callbackfun_002);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position', [.60 .05 .15 .15 ],...
        'Units','normalized','Callback',@(~,~)ZmapMessageCenter(),'String','Cancel');
    
    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.25 .05 .15 .15 ],...
        'Units','normalized',...
        'callback',@callbackfun_003,...
        'String','Go');
    
    
    set(f,'visible','on');watchoff
    
    
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fix1=str2double(inp2_field.String);
        inp2_field.String=num2str(fix1);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fix2=str2double(inp3_field.String);
        inp3_field.String=num2str(fix2);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.maxc=str2num(inp3_field.String);
        ZG.minc=str2num(inp2_field.String);
        close;
        show_mov;
    end
    
end
