function logtoggle(src, scale)
    % LOGTOGGLE toggle an axis between log and linear
    % SRC is the uimenu item
    % scale is 'X' , 'Y', or 'Z'
    ax=get(gcf,'CurrentAxes');
    switch scale
        case 'X'
            fld = 'XScale';
        case 'Y'
            fld = 'YScale';
        case 'Z'
            fld = 'ZScale';
    end
    try
    switch src.Label
        case 'Use Log Scale'
            ax.(fld)='log';
            src.Label='Use Linear Scale';
        otherwise
            ax.(fld)='linear';
            src.Label='Use Log Scale';
    end
    catch ME
        warning(ME.message)
    end
end