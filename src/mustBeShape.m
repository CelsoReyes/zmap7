function mustBeShape(x)
    if ~isa(x,'ShapeGeneral') || ~isvalid(x)
        error('value must be a Shape')
    end
end