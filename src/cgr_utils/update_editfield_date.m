function update_editfield_date(src,~)
    %update_editfield_date general function to update x.Value with a datenum when x.String is updated, where x is an editfield
    % use as the callback
    %
    %  initialdate = '2015-01-23 14:31:55.01'
    %  uicontrol('Style','edit','string',initialdate,'Value',datenum(initialdate),'Callback',@update_editfield_date);
    % can interpret as decimal year or full date
    
    isTextdate = contains(src.String,{':',' ','/','-'});
    
    if isTextdate
        src.Value = datenum(datetime(src.String)); %provides extra parsing
    else
        d = str2double(get(src,'String'));
        if d >= 1800 && d < 3000
            %treat as year
            set(src,'String',[get(src,'String'), '-01-01']);
            update_editfield_date(src);
            return
        else
            try
                src.Value=str2double(src.String);
            catch ME
                warning(ME)
            end
        end
    end
end