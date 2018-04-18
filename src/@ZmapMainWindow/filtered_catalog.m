function [c, mdate, mshape, mall]=filtered_catalog(obj)
    % FILTERED_CATALOG apply range and area subsets to the catalog
    % [mdate, mshape, mall]=filtered_catalog(obj)
    mdate=obj.rawcatalog.Date>=obj.daterange(1) & obj.rawcatalog.Date<=obj.daterange(2);
    if ~isempty(obj.shape)
        mshape = obj.shape.isInside(obj.rawcatalog.Longitude,obj.rawcatalog.Latitude);
    else
        mshape=true(size(mdate));
    end
    mall = mdate & mshape;
    c=obj.rawcatalog.subset(mall);
end