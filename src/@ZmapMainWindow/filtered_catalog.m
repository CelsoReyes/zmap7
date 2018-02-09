function [c,m]=filtered_catalog(obj)
    % FILTERED_CATALOG apply range and area subsets to the catalog, returning result
    m=obj.rawcatalog.Date>=obj.daterange(1) & obj.rawcatalog.Date<=obj.daterange(2);
    if ~isempty(obj.shape)
        m=m & obj.shape.isInside(obj.rawcatalog.Longitude,obj.rawcatalog.Latitude);
    end
    c=obj.rawcatalog.subset(m);
    %c=c.subset(c.Date>=obj.daterange(1) & c.Date<=obj.daterange(2));
    %if ~isempty(obj.shape)
    %    c=c.subset(obj.shape.isInside(c.Longitude,c.Latitude));
    %end
    disp('updated catalog');
    
end