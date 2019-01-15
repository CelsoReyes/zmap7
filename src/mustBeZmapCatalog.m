function mustBeZmapCatalog(x)
    % error unless provided value is a valid shape
    if ~isa(x,'ZmapCatalog') || ~isvalid(x)
        error('value must be a ZmapCatalog')
    end
end