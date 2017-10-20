function trnslate(H,X)
    %
    %    trnslate(Handle,offset)
    %    translate Handle by amount offset=[x_offset, y_offset, z_offest]
    %
    %    See also ROTATE, SCALHAND
    %
    %    Richard G. Cobb    3/96
    %
    dad=get(H,'Parent');
    xlim=get(dad,'Xlim');
    xm=max(get(H,'Xdata'));
    xn=min(get(H,'Xdata'));
    if xm + X(1) > max(xlim)
        X(1) = max(xlim) - xm ;
    elseif xn + X(1) < min(xlim)
        X(1) = min(xlim) - xn ;
    end
    xlim=get(dad,'Ylim');
    xm=max(get(H,'Ydata'));
    xn=min(get(H,'Ydata'));
    if xm + X(2) > max(xlim)
        X(2) = max(xlim) - xm ;
    elseif xn + X(2) < min(xlim)
        X(2) = min(xlim) - xn ;
    end
    xlim=get(dad,'Zlim');
    xm=max(get(H,'Zdata'));
    xn=min(get(H,'Zdata'));
    if xm + X(3) > max(xlim)
        X(3) = max(xlim) - xm ;
    elseif xn + X(3) < min(xlim)
        X(3) = min(xlim) - xn ;
    end
    nx = (get(H,'Xdata')+X(1));
    ny = (get(H,'Ydata')+X(2));
    nz = (get(H,'Zdata')+X(3));
    set(H,'Xdata',nx)
    set(H,'Ydata',ny)
    set(H,'Zdata',nz)
    ud=get(H,'Userdata');
    ud(1)=nx(6);
    ud(2)=ny(6);
    ud(3)=nz(6);
    ud(4)=nx(1);
    ud(5)=ny(1);
    ud(6)=nz(1);

    set(H,'Userdata',ud);


    %eof
