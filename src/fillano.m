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
        m = length(x)-1;      %  number of coordinates of polygon
        l = 1:length(XI);
        l = (l*0)';
        l2 = l;               %  Algorithm to select points inside a closed
        %  polygon based on Analytic Geometry    R.Z. 4/94
        for i = 1:m

            l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
                (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
                ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
                (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

            if i ~= 1
                l2(l) = 1 - l2(l);
            else
                l2 = l;
            end        % if i

        end        %  for

    end


    sl0(l2) = min(sl0(l2));

end



