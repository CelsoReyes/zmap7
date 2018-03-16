function mustBeShape(x)
    if ~isa(x,'ShapeGeneral')
        error('value must be a Shape')
    end
end