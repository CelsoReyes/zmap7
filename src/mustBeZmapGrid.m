function mustBeZmapGrid(x)
    if ~isa(x,'ZmapGrid')
        error('value must be a ZmapGrid')
    end
end