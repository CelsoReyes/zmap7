function [fSpace, fTime] = CalcMonteGKWinParms(fMagnitude)
% calculate window lengths in space and time for the windowing declustering technique
% Example:  [fSpace, fTime] = CalcMonteGKWinParms([1,2,3,4,5,6,7]')
%
%
% Incoming variables:
% fMagnitude : magnitude
%
% Outgoing variables:
% fSpace : Window length in space [km]
% fTime  : Window length in time (duration)
%
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
% updated: 25.01.2008
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[fSpace, fTime] = calc_windows(fMagnitude(:), DeclusterWindowingMethods.GardinerKnopoff1974);

% adding variation
rng('shuffle');
mRndFactors_= randn(2,length(fMagnitude)) .* 0.1 + 1;
fSpace  = fSpace .* mRndfactors_(1);
fTime   = fTime .* mRndfactors_(2);

%% alternate version of this had:
%{

    [spaceGK, timeGK] = calc_windows(fMagnitude, DeclusterWindowingMethods.GardinerKnopoff1974);
    [fSpace2, dur2] = calc_windows(fMagnitude, DeclusterWindowingMethods.GruenthalPersCom);
    [spaceU, timeU] = calc_windows(fMagnitude, DeclusterWindowingMethods.Urhammer1986);
    
    
    
    %% now get the ranges for these
    fSpaceMin = min([spaceGK, fSpace2, spaceU],[],2);
    fSpaceMax = max([spaceGK, fSpace2, spaceU],[],2);
    fSpaceRange = [min(fSpaceMin,[],2) max(fSpaceMax,[],2)]; %[min max]
    
    rng('shuffle');
    
    % chose randomly value within fSpaceRange
    fSpace = rand(length(fMagnitude),1) .* (fSpaceRange(:,2) - fSpaceRange(:,1)) + fSpaceRange(:,1);
    
    durMin = min([timeGK, dur2, timeU],[],2);
    durMax = max([timeGK, dur2, timeU],[],2);
    
    durRange = [min(durMin,[],2) max(durMax,[],2)];
    
    % chose randomly value within fTimeRange
    fTime=rand(length(fMagnitude),1)  .* (durRange(:,2) - durRange(:,1)) + durRange(:,1);
%}