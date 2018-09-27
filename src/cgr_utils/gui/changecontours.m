function changecontours(ax)
    % interactively change contour interval
    dlgtitle='Contour interval';
    s.prompt='Enter interval';
    contr= findobj(ax,'Type','Contour');
    s.value=get(contr,'LevelList');
    if all(abs(diff(s.value)-diff(s.value(1:2))<=eps)) % eps is floating-point number spacing
        s.toChar = @(x)sprintf('%g:%g:%g',x(1),diff(x(1:2)),x(end));
    end
    s.toValue = @str2num;
    answer = smart_inputdlg(dlgtitle,s);
    set(contr,'LevelList',answer.value);
end