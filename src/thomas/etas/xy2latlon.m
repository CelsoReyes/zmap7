function cat = xy2latlon(cat,midpoint)
    % convert x,y list into lat,lon given a lat-lon centerpoint
    %
    %This function takes a list of x,y and converts them to lat, lon given a
    %lat lon centerpoint (given in midpoint).  cat is two columns, x and y.
    %The new cat is the same thing in terms of lat and lon.
    
    %NOTE: THIS PROGRAM IS ONLY MEANT TO BE USED FOR RELATIVELY SMALL AREAS
    %(SAY 100 KM ACROSS!)
    
    cat(:,2) = km2deg(cat(:,2));
    
    cat(:,2) = cat(:,2) + midpoint(1);
    
    cat(:,1) = km2deg(cat(:,1));
    
    cat(:,1) = cat(:,1).*(1./cos(deg2rad(cat(:,2))));
    
    cat(:,1) = cat(:,1) + midpoint(2);
    
    temp = cat(:,1);
    
    cat(:,1)= cat(:,2);
    
    cat(:,2)= temp;
end