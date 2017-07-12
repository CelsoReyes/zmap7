% selects 4 times to define begining and end of two segments in
% cumulative number curve and calls bvalfit
%
report_this_filefun(mfilename('fullpath'));
if ic == 1 | ic == 0
    % Input times t1p t2p t3p and t4p by editing or use cursor if desired
    %
    t1p = t0b;
    t2p = t0b + (teb-t0b)/3;
    t3p = t0b + (teb-t0b)*2/3;
    t4p = teb;
    figure_w_normalized_uicontrolunits(mess)
    clf;
    cla;
    set(gcf,'Name','Time selection ');
    set(gca,'visible','off');
    set(gcf,'Units','points','pos',[ wex wey  390 250 ]);

    freq_field1=uicontrol('Style','edit',...
        'Position',[.70 .75 .15 .10],...
        'Units','normalized','String',num2str(t1p(1)),...
        'Callback','t1p(1)=str2double(freq_field1.String); freq_field1.String=num2str(t1p(1));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.70 .60 .15 .10],...
        'Units','normalized','String',num2str(t2p(1)),...
        'Callback','t2p(1)=str2double(freq_field2.String); freq_field2.String=num2str(t2p(1));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.70 .45 .15 .10],...
        'Units','normalized','String',num2str(t3p(1)),...
        'Callback','t3p(1)=str2double(freq_field3.String); freq_field3.String=num2str(t3p(1));');

    freq_field4=uicontrol('Style','edit',...
        'Position',[.70 .30 .15 .10],...
        'Units','normalized','String',num2str(t4p(1)),...
        'Callback','t4p(1)=str2double(freq_field4.String); freq_field4.String=num2str(t4p(1));');

    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.01 0.99 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Please select begining and end of two segments');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.35 0.84 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time 1 (T1):');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.35 0.66 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time 2 (T2):');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.35 0.48 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time 3 (T3):');
    txt4 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.35 0.31 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time 4 (T4):');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .15 ],...
        'Units','normalized','Callback','welcome','String','Cancel');

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .15 ],...
        'Units','normalized',...
        'Callback','deprat',...
        'String','Go');
    figure_w_normalized_uicontrolunits(depfg)
    par2 = 0.1 * max(cumu2);

elseif ic == 2
    figure_w_normalized_uicontrolunits(depfg)

    seti = uicontrol('Units','normal','Position',[.4 .01 .2 .05],'String','Select T1  ')

    pause(0.5)

    par2 = 0.1 * max(cumu2);
    par3 = 0.12 * max(cumu2);
    t1 = [];
    t1 = ginput(1);
    t1p = [  t1 ; t1(1) t1(2)-par2; t1(1)   t1(2)+par2 ];
    plot(t1p(:,1),t1p(:,2),'r','EraseMode','xor')
    text( t1(1),t1(2)+par3,['t1: ', num2str(t1p(1))] )
    set(seti','String','Select T2')

    pause(0.5)

    t2 = [];
    t2 = ginput(1);
    t2p = [  t2 ; t2(1) t2(2)-par2; t2(1)   t2(2)+par2 ];
    plot(t2p(:,1),t2p(:,2),'r','EraseMode','xor')
    text( t2(1),t2(2)+par3,['t2: ', num2str(t2p(1))] )
    set(seti','String','Select T3')

    pause(0.5)

    t3 = [];
    t3 = ginput(1);
    t3p = [  t3 ; t3(1) t3(2)-par2; t3(1)   t3(2)+par2 ];
    plot(t3p(:,1),t3p(:,2),'r','EraseMode','xor')
    text( t3(1),t3(2)+par3,['t3: ', num2str(t3p(1))] )
    set(seti','String','Select T4')

    pause(0.5)

    t4 = [];
    t4 = ginput(1);
    t4p = [  t4 ; t4(1) t4(2)-par2; t4(1)   t4(2)+par2 ];
    plot(t4p(:,1),t4p(:,2),'r','EraseMode','xor')
    text( t4(1),t4(2)+par3,['t4: ', num2str(t4p(1))] )

    delete(seti)

    ic = 0; dispma3
    pause(0.1)

end          % if ic
