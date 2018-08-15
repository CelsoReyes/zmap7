function mustBeShape(x)
    % error unless provided value is a valid shape
    if ~isa(x,'ShapeGeneral') || ~isvalid(x)
        error('value must be a Shape')
    end
end