function [fP] = callback_GetPercentile(fPercentile, vDistribution, fValue)

% disp(num2str(fPercentile));

% if fPercentile < 0
%   fPercentile = 0;
% end

fP = abs(prctile(vDistribution, fPercentile) - fValue);

return;


[vValues, vDummy, bExitFlag_] = fminbnd('callback_GetPercentile', 0, 100, [], vDistribution, fValue)
