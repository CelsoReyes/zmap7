function popState(obj)
    % POPSTATE returns the catalog, shape, and grid information to the previous state in the stack
    obj.fig.Pointer='watch';
    pause(0.01);
    items = obj.prev_states.pop();
    obj.shape=copy(items{2});
    if ~isempty(obj.shape)
        obj.shape.plot(findobj(obj.fig,'Tag','mainmap_ax'))
    end
    obj.catalog = items{1};
    if isempty(obj.prev_states)
        obj.undohandle.Enable='off';
    end
    obj.daterange=items{3};
    obj.fig.Pointer='arrow';
    pause(0.01);
end