function mustBeZmapCatalog(x)
    % error unless provided value is a valid shape
    if ~isa(x,'ZmapBaseCatalog') || ~isvalid(x)
        error('value must be a ZmapCatalog')
    end
end