function scalhand(H,scale)
    %
    %    scalhand(Handle,scalefactor)
    %
    %    Scale object Handle by amount scalefactor
    %
    %    See also ROTATE, TRNSLATE
    %
    %    Richard G. Cobb    3/96
    %
    origin=findcntr(H);
    %
    xold=get(H,'Xdata');
    xnew=scale*(xold-origin(1))+origin(1);
    yold=get(H,'Ydata');
    ynew=scale*(yold-origin(2))+origin(2);

    zold=get(H,'Zdata');
    znew=scale*(zold-origin(3))+origin(3);

    set(H,'Xdata',xnew,'Ydata',ynew,'Zdata',znew)
