function mycat=cpara(option, mycat)
    % cpara select params in cluster environment
    %    Alexander Allmann
    % mycat=cpara(option, mycat)
    %
    
    persistent tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 tmp8 tmp9 tmp10
    
    report_this_filefun();
    
    if option==1
        
        % default values
        tmp1=min(mycat.Longitude);       %longitude
        tmp2=max(mycat.Longitude);
        tmp3=min(mycat.Latitude);       %latitude
        tmp4=max(mycat.Latitude);
        tmp5=min(mycat.Date);       %time
        tmp6=max(mycat.Date);
        tmp7=min(mycat.Magnitude);       %magnitude
        tmp8=max(mycat.Magnitude);
        tmp9=min(mycat.Depth);       %depth
        tmp10=max(mycat.Depth);
        
        %make the interface
        figure_w_normalized_uicontrolunits(...
            'units','pixel','pos',[300 200 400 500],...
            'name','Select Parameters',...
            'NumberTitle','off',...
            'visible','off',...
            'NextPlot','new');
        axis off
        
        
        inp1=uicontrol('Style','edit','Position',[.47 .80 .22 .06],...
            'Units','normalized','String',num2str(tmp7),...
            'callback',@callbackfun_001);
        
        inp2=uicontrol('Style','edit','Position',[.72 .80 .22 .06],...
            'Units','normalized','String',num2str(tmp8),...
            'callback',@callbackfun_002);
        
        inp3=uicontrol('Style','edit','Position',[.47 .65 .22 .06],...
            'Units','normalized','String',num2str(tmp5),...
            'callback',@callbackfun_003);
        
        inp4=uicontrol('Style','edit','Position',[.72 .65 .22 .06],...
            'Units','normalized','String',num2str(tmp6),...
            'callback',@callbackfun_004);
        
        inp5=uicontrol('Style','edit','Position',[.47 .50 .22 .06],...
            'Units','normalized','String',num2str(tmp9),...
            'callback',@callbackfun_005);
        
        inp6=uicontrol('Style','edit','Position',[.72 .50 .22 .06],...
            'Units','normalized','String',num2str(tmp10),...
            'callback',@callbackfun_006);
        
        inp7=uicontrol('Style','edit','Position',[.47 .35 .22 .06],...
            'Units','normalized','String',num2str(tmp1),...
            'callback',@callbackfun_007);
        
        inp8=uicontrol('Style','edit','Position',[.72 .35 .22 .06],...
            'Units','normalized','String',num2str(tmp2),...
            'callback',@callbackfun_008);
        
        inp9=uicontrol('Style','edit','Position',[.47 .20 .22 .06],...
            'Units','normalized','String',num2str(tmp3),...
            'callback',@callbackfun_009);
        
        inp10=uicontrol('Style','edit','Position',[.72 .2 .22 .06],...
            'Units','normalized','String',num2str(tmp4),...
            'callback',@callbackfun_010);
        
        
        txt1= text(...
            'Color',[1 0 0 ],...
            'Position',[0.45 .99 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold' ,...
            'String',' Minimum');
        
        
        txt2 = text(...
            'Position',[0.75 .99 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold' ,...
            'String',' Maximum ');
        
        txt3 = text(...
            'Position',[0.0 0.88 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Magnitude: ');
        
        txt4 = text(...
            'Position',[0.0 0.70 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Time: ');
        txt5 = text(...
            'Position',[0.0 0.51 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Depth: ');
        txt6 = text(...
            'Position',[0.0 0.33 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Longitude: ');
        txt7 = text(...
            'Position',[0.0 0.15 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Latitude: ');
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.75 .02 .20 .10 ],...
            'Units','normalized','callback',@callbackfun_011,'String','Cancel');
        
        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.45 .02 .20 .10 ],...
            'Units','normalized',...
            'callback',@callbackfun_012,...
            'String','Go');
        
        info_button=uicontrol('Style','Pushbutton',...
            'Position',[.15 .02 .20 .10 ],...
            'Units','normalized',...
            'callback',@callbackfun_013,...
            'String','Info');
        
        
        set(gcf,'visible','on');
        
        
    elseif option=='use_existing'
        
        tmp11=mycat.Longitude>=tmp1 & mycat.Longitude<=tmp2 &...
            mycat.Latitude>=tmp3 & mycat.Latitude<=tmp4 &...
            mycat.Date>=tmp5 & mycat.Date<=tmp6 &...
            mycat.Magnitude>=tmp7 & mycat.Magnitude<=tmp8 &...
            mycat.Depth>=tmp9 & mycat.Depth<=tmp10;
        mycat=mycat.subset(tmp11);
        
    end
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp7=str2double(inp1.String);
        inp1.String=num2str(tmp7);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp8=str2double(inp2.String);
        inp2.String=num2str(tmp8);
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp5=str2double(inp3.String);
        inp3.String=num2str(tmp5);
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp6=str2double(inp4.String);
        inp4.String=num2str(tmp6);
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp9=str2double(inp5.String);
        inp5.String=num2str(tmp9);
    end
    
    function callbackfun_006(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp10=str2double(inp6.String);
        inp6.String=num2str(tmp10);
    end
    
    function callbackfun_007(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp1=str2double(inp7.String);
        inp7.String=num2str(tmp1);
    end
    
    function callbackfun_008(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp2=str2double(inp8.String);
        inp8.String=num2str(tmp2);
    end
    
    function callbackfun_009(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp3=str2double(inp9.String);
        inp9.String=num2str(tmp3);
    end
    
    function callbackfun_010(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp4=str2double(inp10.String);
        inp10.String=num2str(tmp4);
    end
    
    function callbackfun_011(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        ZmapMessageCenter.set_info(' ',' ');
        
    end
    
    function callbackfun_012(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
        ZG.newccat=cpara('use_existing',ZG.newccat);
        csubcat;
    end
    
    function callbackfun_013(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(15);
    end
end
