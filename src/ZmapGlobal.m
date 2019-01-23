classdef ZmapGlobal
    % class used to access ZMap's global data
    % 
    % to READ a global is straight-forward (in this case, "abc"):
    %    value = ZmapGlobal.Data.abc
    %
    % to WRITE a global is somewhat more complicated:
    % 
    %   h = ZmapGlobal.Data; % first, get handle to data
    %   h.abc = value ;      % THEN, set the variable of interest
    %
    % Advantages of using this class:
    % - more explicit, no confusing with local variables
    % - ability to control/modify/verify values at set-time
    % - one-stop shopping
    %
    % see also ZmapData
    
    properties (Constant)
        Data = ZmapData(getappdata(groot,'zmapdataconstructoroptions')) % handle-based class containing global variables & constants
    end
    
end