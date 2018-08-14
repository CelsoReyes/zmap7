function [fSpace, dur] = CalcMonteGKWinParms(fMagnitude)
% provides time and space windows using a random value between lowest and greatest values of Gruenthal and Urhammer
%
%  accepts arrays of magnitudes

    % fMagnitude is in a cloumn
    fMagnitude = fMagnitude(:);
    
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
dur=rand(length(fMagnitude),1)  .* (durRange(:,2) - durRange(:,1)) + durRange(:,1);
