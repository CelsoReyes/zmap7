function toggle_aspectratio(src, ~, ax, options)
    % TOGGLE_ASPECTRATIO toggles axes aspect ratio and sets checked property
    % uses the checked state to determine currentstate.
    % aspect ratio is based on current latitude (Y)
    % 
    % TOGGLE_ASPECTRATIO(source, event, axesHandle, option)
    % options can be:
    %    "SetGlobal",in which case it affects ZmapGlobal
    %    "UpdateOnly",in which case it does not toggle values, but fixes daspect.
    %
    % to set multiple options, use either cell of chars, or array of strings
    
    
    if ~exist('options','var')
        options = "";
    end
    assert(all(ismember(options,["", "UpdateOnly","SetGlobal","on","off"]) ),...
        'options must be member of ["UpdateOnly", "SetGlobal","on","off"]');
   
    if ~any(options == "UpdateOnly")
        if any(options=="on")
            src.Checked="on";
        elseif any(options =="off")
            src.Checked ="off";
        else
            src.Checked=toggleOnOff(src.Checked);
        end
    end
    
    switch src.Checked
        case 'on'
            daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
        case 'off'
            daspect(ax,'auto');
    end
    
    if any(options == "SetGlobal")
        ZG = ZmapGlobal.Data;
        ZG.lock_aspect = matlab.lang.OnOffSwitchState(src.Checked);
    end
end