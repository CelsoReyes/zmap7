function [c, mdate, mshape, mall]=filtered_catalog(obj)
    % FILTERED_CATALOG apply range and area subsets to the catalog
    % [c, mdate, mshape, mall]=filtered_catalog(obj) where
    %   C : filtered catalog (filtered by both shape and date)
    %   MDATE : logical mask where each event is within the date range (inclusive)
    %   MSHAPE: logial mask where each event is within the existing shape
    %   MALL: logical mask where both MDATE and MSHAPE are true.
    
    if isempty(obj.rawcatalog)
        c = ZmapCatalog();
        mdate = false(0);
        mshape=false(0);
        mall = false(0);
        return
    end
    mdate=obj.rawcatalog.Date>=obj.daterange(1) & obj.rawcatalog.Date<=obj.daterange(2);
    if  length(obj.shape.Outline) < 4
        obj.shape = ShapeGeneral; % it was invalid
    end
    if ~isempty(obj.shape)
        mshape = obj.shape.isInside(obj.rawcatalog.Longitude,obj.rawcatalog.Latitude);
    else
        mshape=true(size(mdate));
    end
    mall = mdate & mshape;
    c=obj.rawcatalog.subset(mall);
end