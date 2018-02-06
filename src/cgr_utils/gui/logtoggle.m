function logtoggle(src,~,ax,scale)
    % LOGTOGGLE toggle an axis between log and linear
    % SRC is the uimenu item
    % AX is the axes to scale
    % scale is 'X' , 'Y', or 'Z'
    
    switch scale
        case 'X'
            fld = 'XScale';
        case 'Y'
            fld = 'YScale';
        case 'Z'
            fld = 'ZScale';
    end
    switch src.Label
        case 'Use Log Scale'
            src.Label='Use Linear Scale';
            ax.(fld)='log';
        otherwise
            src.Label='Use Log Scale';
            ax.(fld)='linear';
    end
end