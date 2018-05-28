function tf = istype(obj,  typeName)
    % ISTYPE Determine if input object is of a particular type
    %   ISTYPE(obj, 'TypeName') returns true if obj contains a property named 'Type', and
    %   the contents match.  This is designed for use with graphical objects.
    %
    %   also, will work with structs that have fields named 'Type' 
    %
    % SEE ALSO isa
    
    tf = (isobject(obj) & isprop(obj,'Type')) | ...% object with a Type property OR
        (isstruct(obj) & isfield(obj,'Type') ); % struct with a Type field
    tf(tf)= arrayfun(@(x)ischar(x.Type)||isstring(x.Type)&&strcmp(x.Type,typeName),obj(tf));
end