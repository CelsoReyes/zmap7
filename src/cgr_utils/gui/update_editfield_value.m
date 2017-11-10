function update_editfield_value(src,~)
    %update_editfield_value general function to update x.Value when x.String is updated, where x is an editfield
    % use as the callback
    % 
    %  uicontrol('Style','edit','string','123','Value',num2str(123),'Callback',@update_editfield_value);
    %
    %  whenever the string (text) is changed, then the value updates, too.
    %
    %  only works for single values, not arrays, or non-numeric text.
    try
        src.Value = str2double(src.String);
    catch
        warning('unable to convert "%s" to a number',src.String);
        src.Value = nan;
    end
end