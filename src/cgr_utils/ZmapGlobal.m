classdef ZmapGlobal
    % class used to access ZMap's global data
    % h = ZmapGlobal.Data
    % value = h.variable % where variable is the variable of interest
    % h.variable = value ; set the variable of interest
    
    properties (Constant)
        Data = ZmapData
    end
end