function [X,Y] = click_to_datetime(ax)
    %CLICK_TO_DATETIME converts the axes' current point into x,y coords
    %  works with datetime axes, too
    %
    % [X,Y] = CLICK_TO_DATETIME(ax)
    %
    % see also num2ruler
    selector='';
    xyz=get(ax,'CurrentPoint');
    X=xyz(1);
    Y=xyz(2);
    X = num2ruler(X, ax.XAxis);
    Y = num2ruler(Y, ax.YAxis);
    if isa(X,'datetime')
        X = round_time(X,selector);
    end
    if isa(Y,'datetime')
        Y = round_time(Y,selector);
    end
end