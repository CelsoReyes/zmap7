function toThing = copyfields(toThing, fromThing, varargin)
    % copy fields (or properties) from one structure (or object) to another. Types may be different
    %
    % toThing = copyfields(toThing, fromThing) copies fields/properties from fromThing into toThing, 
    % returning toThing.  if THISONE is a handle object, the return can be ignored.
    %
    % Options:
    % copyfields(... , "safe") will copy all fields.  A warning will be displayed for any field that
    % doesn't exist.
    % copyfields(... , "safe", "quietfail") will not warn or error when a field doesn't exist. 
    
   
    failQuietly =  any(varargin == "quietfail");
    
    if isstruct(fromThing)
        fn = fieldnames(fromThing);
    elseif isobject(fromThing)
        fn = properties(fromThing);
    elseif failQuietly
        return
    else
        error('cannot copy fields/properties from ["%s"], since it is neither an object nor a struct', inputname(2));
    end
    
    if any(varargin=="safe")
        for i = 1 : numel(fn)
            try
                toThing.(fn{i}) = fromThing.(fn{i});
            catch ME
                if failQuietly
                    do_nothing(); % do not copy
                else
                    warning(ME.identifier, 'Error copying property/field: %s',fn{i})
                end
            end
        end
    else
        for i = 1 : numel(fn)
            toThing.(fn{i}) = fromThing.(fn{i});
        end
        
    end
end