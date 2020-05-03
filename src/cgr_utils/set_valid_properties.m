function [usedfields, unusedfields] = set_valid_properties(obj, s)
    % SET_VALID_PROPERTIES sets properties of an object, using values from an input structure
    % [usedfields, unusedfields] = set_valid_properties(obj, s) for structure s, and object o:
    %    o.* = s.* for each field that is in both o and s.  other fields are ignored.  
    
    f = fieldnames(s);
    p = properties(obj);
    m = ismember(f,p);
    usedfields = f(m);
    unusedfields = f(~m);
    if ismember("ColorBy",p) &&  s.ColorBy ~= "-none-"
        % otherwise, it will undo our colorby
        unusedfields(end+1) = {'MarkerEdgeColor'};
    end
    try
        set(obj, rmfield(s,unusedfields));
    catch ME
        switch ME.identifier
            case 'MATLAB:graphics:SetMethodUnknown'
                idx=find(m);
                for i=1:numel(idx)
                    fn = f{idx(i)};
                    obj.(fn) = s.(fn);
                end
            otherwise
                rethrow(ME)
        end
    end
end