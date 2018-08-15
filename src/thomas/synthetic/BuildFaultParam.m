function [FaultParam]=BuildFaultParam(vMagnitude,mLocations,mLambda1, mLambda2)
% Imigation for BuildFaultParam
%
%
% Mainshock location?
FaultParam=mLocations;
% calculate fault length and fault width according to Wells & Coppersmith
% 1994
[FaultParam(:,4) FaultParam(:,5) ] = WellsCopper(vMagnitude,1);
% strike and dip (fixed to characteristics in region)
FaultParam(:,6:7)=repmat([332 90],size(FaultParam,1),1);
