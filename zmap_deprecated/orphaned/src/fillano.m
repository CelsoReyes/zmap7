report_this_filefun(mfilename('fullpath'));

[s,lc] = contour(gx2,gy2,sl0,[-3 -3]);


for j = 1:length(lc)
    xp = get(lc(j),'Xdata');
    yp = get(lc(j),'Ydata');
    if length(xp) > 4
        le = length(xp);
        xp(le) = xp(1);
        yp(le) = yp(1);
        N = length(xp);
        
        
        XI = reshape(X2,100*100,1);          % this substitution just to make equation below simple
        YI = reshape(Y2,100*100,1);
        x = xp;
        y = yp;
        l2 = polygon_filter(x,y, XI, YI, 'inside');
    end
    
    sl0(l2) = min(sl0(l2));
    
end



