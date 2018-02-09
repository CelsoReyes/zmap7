function [axis_x, axis_y] = screenpix2axes(ax, x,y)
    % SCREENPIX2AXES convert a mouse click from screen coordinates to local axes coordinate
    % [axis_x, axis_y] = SCREENPIX2AXES(x,y)
    % [axis_x, axis_y] = SCREENPIX2AXES() use current mouse position
    % works with multiple monitors
    %
    % for use with waitforbuttonpress, since CurrentPointer isn't updated when a key is pressed
    % instead of a mouse button being pressed.
    %
    % see also num2ruler, ruler2num
    
    % TODO: handle logarithmic scales
    
    if ~exist('x','var') || isempty(x) || isempty(y)
        xy=get(groot,'PointerLocation');
        x=xy(1);
        y=xy(2);
    end
    f=-99;
    while  ~isempty(f) && f ~= 0 && ~isa(f,'matlab.ui.Figure')
        f=ax.Parent;
    end
    fx =f.Position(1);
    fy =f.Position(2);
    axx = ax.Position(1);
    axy = ax.Position(2);
    pt_offset_x = x - (fx + axx);
    pt_offset_y = y - (fy + axy);
    x_per_pixel = diff(xlim(ax))/ax.Position(3);
    calc_axx = pt_offset_x  * x_per_pixel + min(xlim(ax));
    y_per_pixel = diff(ylim) / ax.Position(4);
    calc_axy = pt_offset_y * y_per_pixel + min(ylim(ax));
    axis_x = num2ruler(calc_axx,ax.XAxis);
    axis_y = num2ruler(calc_axy,ax.YAxis);
end