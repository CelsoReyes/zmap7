function mustBeZmapGrid(x)
    % error unless provided value is a ZmapGrid
    if ~isa(x,'ZmapGrid')
        error('value must be a ZmapGrid')
    end
end