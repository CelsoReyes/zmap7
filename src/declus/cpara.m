function cpara(var1)
    % cpara.m               Alexander Allmann
    % function to select parameters in cluster environment
    %

    global newccat
    global inp1 inp2 inp3 inp4 inp5 inp6 inp7 inp8 inp9 inp10
    global tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 tmp8 tmp9 tmp10

report_this_filefun(mfilename('fullpath'));

    if var1==1

        % default values
        tmp1=min(newccat.Longitude);       %longitude
        tmp2=max(newccat.Longitude);
        tmp3=min(newccat.Latitude);       %latitude
        tmp4=max(newccat.Latitude);
        tmp5=min(newccat.Date);       %time
        tmp6=max(newccat.Date);
        tmp7=min(newccat.Magnitude);       %magnitude
        tmp8=max(newccat.Magnitude);
        tmp9=min(newccat.Depth);       %depth
        tmp10=max(newccat.Depth);

        %make the interface
        figure_w_normalized_uicontrolunits(...
            'units','pixel','pos',[300 200 400 500],...
            'name','Select Parameters',...
            'NumberTitle','off',...
            'visible','off',...
            'MenuBar','none',...
            'NextPlot','new');
        axis off


        inp1=uicontrol('Style','edit','Position',[.47 .80 .22 .06],...
            'Units','normalized','String',num2str(tmp7),...
            'Callback','tmp7=str2double(inp1.String); inp1.String=num2str(tmp7))';

        inp2=uicontrol('Style','edit','Position',[.72 .80 .22 .06],...
            'Units','normalized','String',num2str(tmp8),...
            'Callback','tmp8=str2double(inp2.String); inp2.String=num2str(tmp8);');

        inp3=uicontrol('Style','edit','Position',[.47 .65 .22 .06],...
            'Units','normalized','String',num2str(tmp5),...
            'Callback','tmp5=str2double(inp3.String); inp3.String=num2str(tmp5);');

        inp4=uicontrol('Style','edit','Position',[.72 .65 .22 .06],...
            'Units','normalized','String',num2str(tmp6),...
            'Callback','tmp6=str2double(inp4.String); inp4.String=num2str(tmp6);');

        inp5=uicontrol('Style','edit','Position',[.47 .50 .22 .06],...
            'Units','normalized','String',num2str(tmp9),...
            'Callback','tmp9=str2double(inp5.String); inp5.String=num2str(tmp9);');

        inp6=uicontrol('Style','edit','Position',[.72 .50 .22 .06],...
            'Units','normalized','String',num2str(tmp10),...
            'Callback','tmp10=str2double(inp6.String); inp6.String=num2str(tmp10);');

        inp7=uicontrol('Style','edit','Position',[.47 .35 .22 .06],...
            'Units','normalized','String',num2str(tmp1),...
            'Callback','tmp1=str2double(inp7.String); inp7.String=num2str(tmp1);');

        inp8=uicontrol('Style','edit','Position',[.72 .35 .22 .06],...
            'Units','normalized','String',num2str(tmp2),...
            'Callback','tmp2=str2double(inp8.String); inp8.String=num2str(tmp2);');

        inp9=uicontrol('Style','edit','Position',[.47 .20 .22 .06],...
            'Units','normalized','String',num2str(tmp3),...
            'Callback','tmp3=str2double(inp9.String); inp9.String=num2str(tmp3);');

        inp10=uicontrol('Style','edit','Position',[.72 .2 .22 .06],...
            'Units','normalized','String',num2str(tmp4),...
            'Callback','tmp4=str2double(inp10.String); inp10.String=num2str(tmp4);');


        txt1= text(...
            'Color',[1 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.45 .99 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold' ,...
            'String',' Minimum');


        txt2 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.75 .99 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold' ,...
            'String',' Maximum ');

        txt3 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.0 0.88 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Magnitude: ');

        txt4 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.0 0.70 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Time: ');
        txt5 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.0 0.51 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Depth: ');
        txt6 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.0 0.33 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Longitude: ');
        txt7 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.0 0.15 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.xl ,...
            'FontWeight','bold' ,...
            'String','Latitude: ');

        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.75 .02 .20 .10 ],...
            'Units','normalized','Callback','close;zmap_message_center.set_info('' '','' '');done','String','cancel');

        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.45 .02 .20 .10 ],...
            'Units','normalized',...
            'Callback','close,think, cpara(2);csubcat;',...
            'String','Go');

        info_button=uicontrol('Style','Pushbutton',...
            'Position',[.15 .02 .20 .10 ],...
            'Units','normalized',...
            'Callback','clinfo(15);',...
            'String','Info');


        set(gcf,'visible','on');


    elseif var1==2

        tmp11=find(newccat.Longitude>=tmp1 & newccat.Longitude<=tmp2 & newccat.Latitude>=tmp3 & newccat.Latitude<=tmp4 & newccat.Date>=tmp5 & newccat.Date<=tmp6 & newccat.Magnitude>=tmp7 & newccat.Magnitude<=tmp8 & newccat.Depth>=tmp9 & newccat.Depth<=tmp10);
        newccat=newccat.subset(tmp11);

    end
