function c=filtered_catalog(obj)
    % FILTERED_CATALOG apply range and area subsets to the catalog, returning result
    c=obj.rawcatalog;
    c=c.subset(c.Date>=obj.daterange(1) & c.Date<=obj.daterange(2));
    if ~isempty(obj.shape)
        c=c.subset(obj.shape.isInside(c.Longitude,c.Latitude));
    end
end