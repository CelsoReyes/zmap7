function [fFaultType] = calc_FaultStyle2planes(fRake1,fRake2)
% function [fFaultType] = calc_FaultStyle2planes(fRake1,fRake2)
% ------------------------------------------
% Determining the faulting style based on the rakes of the fps solutions
% Ref: Shearer et al., JGR, 2006, Comprehensive analysis of earthquake source spectra in southern California
%
% Incoming:
% fRake1 : rake of first fps
% fRake2 : rake of second fps
%
% Output:
% fFaultType: -1 : Normal faulting
%             0  : Strike slip
%             1  : Thrust faulting
%
% jowoe@gps.caltech.edu

if  abs(fRake1) > 90
    fRake1 = (180-abs(fRake1))*(fRake1/abs(fRake1));
end

if  abs(fRake2) > 90
    fRake2 = (180-abs(fRake2))*(fRake2/abs(fRake2));
end

if abs(fRake1) < abs(fRake2)
    fRake = fRake1;
else
    fRake = fRake2;
end

% Type of faulting
fFaultType = fRake/90;
