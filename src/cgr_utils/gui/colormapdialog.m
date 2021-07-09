function choice = colormapdialog()
    % allow user to choose colormap
    persistent colormap_choice
    
    if isempty(colormap_choice)
        colormap_choice = 'jet';
    end
    color_maps = {'parula';'jet';'hsv';'hot';'cool';'spring';'summer';'autumn';'winter'};
    % provide a simple dialog allowing the user to choose a colormap
    d = dialog('Position',[300 300 250 150], 'Name', 'Choose Colormap');
    uicontrol('Parent',d, 'Style','Popup','Position',[20 80 210 40],...
        'String',color_maps,...
        'Value',find(strcmp(color_maps,colormap_choice)),...
        'MenuSelectedFcn', @popup_callback);
    uicontrol('Parent',d,...
        'Position',[89 20 70 25],...
        'String','Close',...
        'MenuSelectedFcn',@(~,~)delete(gcf));
    uiwait(d);
    choice = colormap_choice;
    
    function popup_callback(popup, ~)
        idx = popup.Value;
        popup_items = popup.String;
        colormap_choice = char(popup_items(idx,:));
    end
end