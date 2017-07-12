%
% Creates the input window for the parameters of the factal dimension calculation.
% Called from circlefd.m.
%
figure_w_normalized_uicontrolunits('Units','pixel','pos',[200 400 550 210 ],'Name','Parameters','visible','off',...
    'NumberTitle','off','MenuBar','none','Color',color_fbg,'NextPlot','new');
axis off;


input1 = uicontrol('Style','popupmenu','Position',[.75 .77 .23 .09],...
    'Units','normalized','String','Automatic Range|Manual Fixed Range',...
    'Value',1,'Callback','range=(get(input1,''Value'')); input1.Value=range;, actrange');

input2 = uicontrol('Style','edit','Position',[.34 .51 .10 .09],...
    'Units','normalized','String',num2str(radm), 'enable', 'off',...
    'Value',1,'Callback','radm=str2double(input2.String); input2.String= num2str(radm);');

input3 = uicontrol('Style','edit','Position',[.75 .51 .10 .09],...
    'Units','normalized','String',num2str(rasm), 'enable', 'off',...
    'Value',1,'Callback','rasm=str2double(input3.String); input3.String= num2str(rasm);');

input4 = uicontrol('Style','edit','Position',[.75 .34 .10 .09],...
    'Units','normalized','String',num2str(ra),'enable', 'off',...
    'Value',1,'Callback','ra=str2double(input4.String); input4.String= num2str(ra);');



tx1 = text('EraseMode','normal', 'Position',[0 .87 0 ], 'Rotation',0 ,...
    'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String',' Distance range within which D is computed: ');

tx2 = text('EraseMode','normal', 'Position',[0 .55 0], 'Rotation',0 ,...
    'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Minimum value: ', 'color', 'w');

tx3 = text('EraseMode','normal', 'Position',[.52 .55 0], 'Rotation',0 ,...
    'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Maximum value: ', 'color', 'w');

tx4 = text('EraseMode','normal', 'Position',[.41 .55 0], 'Rotation',0 ,...
    'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','km', 'color', 'w');

tx5 = text('EraseMode','normal', 'Position',[.94 .55 0], 'Rotation',0 ,...
    'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','km', 'color', 'w');

tx6 = text('EraseMode','normal', 'Position',[0 .34 0], 'Rotation',0 ,...
    'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Radius of the sampling sphere:', 'color', 'w');

actradi;

close_button=uicontrol('Style','Pushbutton',...
    'Position',[.60 .05 .20 .15 ],...
    'Units','normalized','Callback','close;zmap_message_center.set_info('' '','' '');done','String','Cancel');

go_button=uicontrol('Style','Pushbutton',...
    'Position',[.20 .05 .20 .15 ],...
    'Units','normalized',...
    'Callback','close;think; circlefd;',...
    'String','Go');


set(gcf,'visible','on');
watchoff;
