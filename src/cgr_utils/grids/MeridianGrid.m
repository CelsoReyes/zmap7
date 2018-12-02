classdef MeridianGrid < GridBase
    % For use with XY Grids where XY units are in degrees
    % sample distances change with latitude
    
    properties (Constant)
        Type = 'meridiangrid'
        DeltaDescription = "dLat,dLon"
    end
end