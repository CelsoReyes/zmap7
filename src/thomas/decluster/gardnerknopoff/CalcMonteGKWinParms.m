function [fSpace, fTime] = CalcMonteGKWinParms(fMagnitude)
% Example:  [fSpace, fTime] = CalcMonteGKWinParms([1,2,3,4,5,6,7]')
%
% Function to calculate window lengths in space and time for
% the windowing declustering technique
%
% Incoming variables:
% fMagnitude : magnitude
%
% Outgoing variables:
% fSpace : Window length in space [km]
% fTime  : Window length in time [dec. years]
%
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
% updated: 25.01.2008
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%disp('Using Gardner & Knopoff, 1974')
fSpace = 10.^(0.1238*fMagnitude+0.983);
if fMagnitude >= 6.5
    fTime = (10.^(0.032*fMagnitude+2.7389))/365;
else
    fTime = (10.^(0.5409*fMagnitude-0.547))/365;
end

% adding variation
rng('shuffle');
mRndFactors_=randn(2,length(fMagnitude)).*0.1+1;
mTmp=[fSpace fTime].*mRndFactors_';
fSpace=mTmp(:,1);
fTime=mTmp(:,2);




%
% %disp('Using Gruenthal, pers. communication')
% fSpace2 = exp(1.77+sqrt(0.037+1.02*fMagnitude));
% if fMagnitude < 6.5
%     fTime2 = abs((exp(-3.95+sqrt(0.62+17.32*fMagnitude)))/365);
% else
%     fTime2 = (10.^(2.8+0.024*fMagnitude))/365;
% end
% %disp('Urhammer, 1976');
% fSpace3 = exp(-1.024+0.804*fMagnitude);
% fTime3 = (exp(-2.87+1.235*fMagnitude))/365;
%
% fSpaceMin = min([fSpace1,fSpace2,fSpace3]);
% fSpaceMax = max([fSpace1,fSpace2,fSpace3]);
% fSpaceRange = [min(fSpaceMin) max(fSpaceMax)];
% % chose randomly value out of fSpaceRange
% fSpace=mRndFactors_(1)*(max(fSpaceRange)-min(fSpaceRange))+min(fSpaceRange);
%
% fTimeMin = min([fTime1,fTime2,fTime3]);
% fTimeMax = max([fTime1,fTime2,fTime3]);
%
% fTimeRange = [min(fTimeMin) max(fTimeMax)];
% % chose randomly value out of fTimeRange
% fTime=mRndFactors_(2)*(max(fTimeRange)-min(fTimeRange))+min(fTimeRange);
%
%
%
