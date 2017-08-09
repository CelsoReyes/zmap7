%   To display mean Z values resulted from the genascumu at a selected
%   time
%                                                          R.Z. 5/94

report_this_filefun(mfilename('fullpath'));

if ic == 0

    it = t0b + 1;
    zmap_message_center();
    mess = gcf;
    clf
    set(gca,'visible','off')
    set(gcf,'pos',[ 0.02  0.9 0.3 0.35])
    set(gcf,'Name','GenAS-Grid Time Selection');

    inp5=uicontrol('Style','edit','Position',[.70 .50 .22 .06],...
        'Units','normalized','String',num2str(it),...
        'Callback','it=str2double(inp5.String); inp5.String=num2str(it);');

    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.02 0.52 0 ],...
        'Rotation',0 ,...
        'String','Time to display (e.g. 84.537): ');

    close_button = uicontrol('Units','normal','Position',...
        [.1 .7 .2 .12],'String','Close ', 'Callback',@(~,~)zmap_Message_center());

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.35 .22 .20 .10 ],...
        'Units','normalized',...
        'Callback','ic = 1; timgenas',...
        'String','Display');

else

    stri = 'Map of mean Z at time T';
    it = (it -t0b)/days(ZG.bin_days);
    stri2 = ['ti=' num2str(it*days(ZG.bin_days) + t0b)  ];
    meanZ_it = Zsumall(it,:);                         % pick meanZ at time it

    re3 = reshape(meanZ_it,length(gy),length(gx));

    view_max
    clear meanZ_it;

end   % if ic




