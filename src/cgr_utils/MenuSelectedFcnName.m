function name=MenuSelectedFcnName()
    % MENUSELECTEDFCNNAME ensures uimenu compatibiility for callback functions
    % in R2017a uimenu callbacks are assigned as:
    %   ...'Callback',@callbackfcn
    % but in R2017b, uimenu callbacks changed to:
    %   ...'MenuSelectedFcn',@callbackfcn
    % 
    % the old version is going to go away in the future. This function is here to ensure
    % that zmap doesn't break when that happens.
    %  This use:
    %  ...MENUSELECTEDFCNNAME(),@callbackfunction
    %
    % see uimenu
    
    persistent thisVerName
    if ~isempty(thisVerName)
        name=thisVerName;
        return
    end
    
    if verLessThan('matlab','9.3')
        thisVerName='Callback';
    else
        thisVerName='MenuSelectedFcn';
    end
    name=thisVerName;
end