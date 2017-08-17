function LC_map(lat,lon,maxlat,minlat,maxlon,minlon)
    
    %LC_PLOT_MAP
    %
    %    LC_plot_map(lat,lon,maxlat,minlat,maxlon,minlon)
    %
    %    Function to plot a map using a Lambert Conformal projection
    %    with two standard parallels which are chosen to be 1/4 of the
    %    vertical span of the map from the top (phi1) and bottom (phi2).
    %    The standard meridian is chosen to be the center meridian of
    %    the map.
    %
    %    where * lat & lon: array of latitudes and longitudes of map feature
    %	   * maxlat & minlat: maximum and minimum latitude of map
    %	   * maxlon & minlon: maximum and minimum longitude of map
    %	                      (remember: South & West are negative!)
    %
    %	The line type and line width can be set using the following
    %	global variables: "line_type" & "line_width".
    %	If these global variables are not set, it will use the
    %	following defaults: line_type = '-' & line_width = [0.5]
    
    report_this_filefun(mfilename('fullpath'));
    
    global torad Re scale
    global phi0 lambda0 phi1 phi2
    global maxlatg minlatg maxlong minlong
    global line_type line_width
    
    maxlatg = maxlat; minlatg = minlat;
    maxlong = maxlon; minlong = minlon;
    
    % set some constants
    scale = 1;
    
    % get the Standard Parallels and Center Coordinates
    phi1 = (minlat + ((maxlat - minlat) / 4)) * torad;
    phi2 = (maxlat - ((maxlat - minlat) / 4)) * torad;
    phi0 = (phi1 + phi2) / 2;
    lambda0 = ((minlon + maxlon) / 2) * torad;
    
    % find index of all points which are valid for this map & that are
    % not seperator points (ie: NaN)
    index = find(minlat < lat & lat < maxlat & minlon < lon & lon < maxlon &...
        isfinite(lat) & isfinite(lon));
    
    % convert all valid points to cartesian coordinates
    if index > 0
        [x(index) y(index)] = lc_tocar(lat(index),lon(index));
    end
    
    % reinsert the segment seperator points (ie: NaN)
    idxzero = find(x == 0 & y == 0);
    
    if idxzero > 0
        x(idxzero) = ones(size(x(idxzero))) * NaN;
        y(idxzero) = ones(size(y(idxzero))) * NaN;
    end
    
    % keep in memory if HOLD was on or off to put it back the way it was
    % after the plot
    if ishold
        hold_flag = 1;
    else
        hold_flag = 0;
    end
    
    lc_borde('-k',2)
    hold on
    
    lc_grid(':',0.20)
    
    if isempty(line_type), line_type = '-k'; end
    if isempty(line_width), line_width = [0.5]; end
    plot(x,y,'-k','LineWidth',line_width)
    
    axis('equal')
    set(gca,'Visible','off')
    set(gcf,'PaperPosition',[1 .5 9 6.9545])
    
    % put HOLD back the way it was before this function was called
    if hold_flag
        hold on
    else
        hold off
    end
    
end