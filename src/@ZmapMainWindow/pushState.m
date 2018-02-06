function pushState(obj)
    % PUSHSTATE store the catalog and subsetting information to the stack
    obj.prev_states.push({obj.catalog, copy(obj.shape), obj.daterange});
    obj.undohandle.Enable='on';
end