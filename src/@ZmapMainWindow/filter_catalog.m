function [mdate, mshape, mall]=filter_catalog(obj)
    % filter_catalog apply range and area subsets to the object's catalog
    % [mdate, mshape, mall]=filter_catalog(obj) where
    %   MDATE : logical mask where each event is within the date range (inclusive)
    %   MSHAPE: logial mask where each event is within the existing shape
    %   MALL: logical mask where both MDATE and MSHAPE are true.
    
    % modiying to reduce unecessary copies
    if isempty(obj.rawcatalog)
        mdate = false(0);
        mshape=false(0);
        mall = false(0);
        return
    end
    mdate = obj.daterange(1) <= obj.rawcatalog.Date & obj.rawcatalog.Date <= obj.daterange(2);
    if  ~(class(obj.shape)=="ShapeGeneral") && (~isvalid(obj.shape) || length(obj.shape.Outline) < 4)
        obj.shape = ShapeGeneral(); % it was invalid
    end
    if ~isempty(obj.shape)
        mshape = obj.shape.isinterior(obj.rawcatalog.X,obj.rawcatalog.Y);
    else
        mshape=true(size(mdate));
    end
    mall = mdate & mshape;
    
    % only copy it over if it has changed
    prevcatstats=obj.catalog.summary('stats');
    tmpcat=obj.rawcatalog.subset(mall);
    if ~strcmp(prevcatstats,tmpcat.summary('stats'))
        obj.catalog=obj.rawcatalog.subset(mall);
    end
end