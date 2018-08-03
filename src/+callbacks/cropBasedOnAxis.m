function deets=cropBasedOnAxis(src,evt)
    % CROPBASEDONAXIS crop based on current axes (interactive)
    persistent stored
    if nargin==0
        deets=stored;
        return
    end
    s.source = src;
    s.event = evt;
    s.curObj = gco;
    ax = ancestor(s.curObj,'axes');
    if isempty(ax)
        % not within an axes
        %disp('** did not click in an axes')
        return
    end
    s.fig = ancestor(ax,'figure');
    
    
    % only do the actuall cropping if there was a doubleclick
    
    cp = get(ax,'CurrentPoint');
    x = cp(1,1);
    y = cp(1,2);
    s.X.Value = num2ruler(x,ax.XAxis);
    s.X.Name = ax.XLabel.String;
    s.Y.Value = num2ruler(y,ax.YAxis);
    s.Y.Name = ax.YLabel.String;
    stored=s;
    deets=s;
    if s.fig.SelectionType ~= "open"
        return
    end
    fprintf('Click at:\n  %20s : %s\n  %20s : %s\n', s.X.Name, string(s.X.Value), s.Y.Name, string(s.Y.Value));
    QuickCatalogCrop() %app
end