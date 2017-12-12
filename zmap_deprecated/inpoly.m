function l = inpoly(XI,YI,X,Y,N)
    %     x, y  contains the coordinates of the closed polygon.
    %     Closed polygon, i.e. x(n) = x(1), y(n) = y(1)
    %     xi, yi are the coordinates of the point(s) to be tested
    %     n is the number of coordinates of the closed polygon
    %     it returns 0 or 1
    
    report_this_filefun(mfilename('fullpath'));
    
    l = 0;
    m = N - 1;
    for i = 1:m
        
        if Y(i)-YI >= 0 & Y(i+1)-YI < 0
            if (XI-X(i)-(YI-Y(i))*(X(i+1)-X(i))/(Y(i+1)-Y(i))) <= 0, l =1-l; end
        else if Y(i)-YI < 0 & Y(i+1)-YI >= 0
                if (XI-X(i)-(YI-Y(i))*(X(i+1)-X(i))/(Y(i+1)-Y(i))) <= 0,l =1-l; end
            end  % if Y
        end  % for
        
    end   %    needed
    
end