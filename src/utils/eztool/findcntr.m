function [c]=findcntr(H)
    %
    %    [Center]=findcntr(Handle)
    %    Returns the geometric center of Handle
    %
    %    This can be used as the ORIGIN input in ROTATE to rotate
    %    an object about its geometric center.
    %
    %    See also ROTATE, TRNSLATE, SCALHAND
    %
    %    Richard G. Cobb    3/96
    %
    c=[0 0 0];

    tmp=(max(get(H,'Xdata'))+min(get(H,'Xdata')))/2;
    if tmp ~= []
        c(1)=tmp;
    else
        set(H,'Xdata',zeros(size(get(H,'Ydata'))))
    end
    tmp=(max(get(H,'Ydata'))+min(get(H,'Ydata')))/2;
    if tmp ~= []
        c(2)=tmp;
    else
        set(H,'Ydata',zeros(size(get(H,'Xdata'))))
    end

    tmp=(max(get(H,'Zdata'))+min(get(H,'Zdata')))/2;
    if tmp ~= []
        c(3)=tmp;
    else
        set(H,'Zdata',zeros(size(get(H,'Ydata'))))
    end



    %eof
