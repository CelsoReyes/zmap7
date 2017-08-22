function LC_event(lat,lon,symb,symb_size,symb_thick)
    
    %LC_PLOT_EVENTS plot earthquakes on a Lambert Conformal map (via LC_plot_map)
    %
    %	LC_plot_events(lat,lon,symb,symb_size,symb_thick)
    %
    %	Function to plot earthquakes on a Lambert Conformal map plotted
    %	with LC_plot_map.
    %
    %	where * lat & lon: array of latitudes and longitudes of earthquakes
    %	      * symb: symbol to be used for earthquakes (use single quotes!)
    %	      * symb_size: symbol size in points (1 point = 1/72 inch)
    %	      * symb_thick: symbol line thickness in points (min = [0.01])
    %
    %	SYMB, SYMB_SIZE, SYMB_THICK don't need to be set, but if you set
    %	one of them, you have to give a value for the other ones as well.
    %
    %	NOTE: The LC_plot_map function has to have been called before
    %	      you can use this function as it needs to have some global
    %	      variables to be set.
    
    global bDebug
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end
    
    global torad Re scale
    global phi0 lambda0 phi1 phi2
    global maxlatg minlatg maxlong minlong
    
    % set some constants
    scale = 1;
    
    % set the symbols defaults
    if nargin < 5
        symb_thick = 0.5;
        if nargin < 4
            symb_size = 6;
            if nargin < 3
                symb = '+';
                if nargin < 2
                    disp('ERROR: insufficient number of arguments')
                    help lc_plot_events
                    return
                end
            end
        end
    end
    
    % get the Standard Parallels and Center Coordinates
    phi1 = (minlatg + ((maxlatg - minlatg) / 4)) * torad;
    phi2 = (maxlatg - ((maxlatg - minlatg) / 4)) * torad;
    phi0 = (phi1 + phi2) / 2;
    lambda0 = ((minlong + maxlong) / 2) * torad;
    
    % convert all valid points to cartesian coordinates
    idx_in = find(minlatg < lat & lat < maxlatg & minlong < lon & lon < maxlong);
    [x, y] = lc_tocart(lat(idx_in),lon(idx_in));
    
    % keep in memory if HOLD was on or off to put it back the way it was
    % after the plot
    if ishold
        hold_flag = 1;
        hold on
    else
        hold_flag = 0;
        hold off
    end
    
    plot(x,y,symb,'MarkerSize',symb_size,'LineWidth',symb_thick)
    
    % put HOLD back the way it was before this function was called
    if hold_flag
        hold on
    else
        hold off
    end
    
end