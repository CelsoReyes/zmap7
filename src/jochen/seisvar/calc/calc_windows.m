function [fSpace, fTime] = calc_windows(fMagnitude, nMethod)
% function [fSpace, fTime] = calc_windows(fMagnitude, nMethod);
% -----------------------------------------------------------
%
% Function to calculate window lengths in space and time for
% the windowing declustering technique
%
% Incoming variables:
% fMagnitude : magnitude
% nMethod    : Selection variable for window definition of specific authors
%              1 = Gardener & Knopoff, 1974
%              2 = Gruenthal pers. communication
%              3 = Urhammer, 1986
%
% Outgoing variables:
% fSpace : Window length in space [km]
% fTime  : Window length in time [dec. years]
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% updated: 22.07.02

%%% Further possibilites, but not used %%%%%%%%%%%%%%%
%              4 = Gruenthal, 1985 (from Figure)
%              5 = Mod. Youngs, 1987, Maximum window
%              6 = Mod. Youngs, 1987, Minimum window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch nMethod
case 1
    %disp('Using Gardner & Knopoff, 1974')
    fSpace = 10.^(0.1238*fMagnitude+0.983);
    if fMagnitude >= 6.5
        fTime = (10.^(0.032*fMagnitude+2.7389))/365;
    else
        fTime = (10.^(0.5409*fMagnitude-0.547))/365;
    end
case 2
    %disp('Using Gruenthal, pers. communication')
    fSpace = exp(1.77+sqrt(0.037+1.02*fMagnitude));
    if fMagnitude < 6.5
        fTime = abs((exp(-3.95+sqrt(0.62+17.32*fMagnitude)))/365);
    else
        fTime = (10.^(2.8+0.024*fMagnitude))/365;
    end
case 3
    %disp('Urhammer, 1976');
    fSpace = exp(-1.024+0.804*fMagnitude);
    fTime = (exp(-2.87+1.235*fMagnitude))/365;
% case 4
%     %disp('Using Gruenthal, 1985')
%     fSpace = 10.^(0.1060*fMagnitude+1.0982);
%     fTime = (10.^(0.5055*fMagnitude-0.1329))/365;
% case 5
%     %disp('Using Modified Youngs, 1987 Maximum window')
%     if fMagnitude <= 2.43
%         fSpace=20;
%     elseif (fMagnitude>2.43 & fMagnitude<=5.86)
%         fSpace = 10.^(0.1159*fMagnitude+1.0197);
%     else
%         fSpace = 10.^(0.5281*fMagnitude-1.3937);
%     end
%     if fMagnitude <= 3.89
%         fTime = days(30);
%     else
%         fTime = (10.^(0.4916*fMagnitude-0.4317))/365;
%     end
% case 6
%     %disp('Using Modified Youngs, 1987 Minimum window')
%     if fMagnitude<=4.41
%         fSpace = 10;
%     elseif (fMagnitude>4.41 & fMagnitude<=4.98)
%         fSpace = 10.^(0.5281*fMagnitude-1.329);
%     elseif (fMagnitude>4.98 & fMagnitude<=6.42)
%         fSpace = 10.^(0.3313*fMagnitude-0.349);
%     else
%         fSpace = 10.^(0.1154*fMagnitude+1.0371);
%     end; %End of IF
%     if fMagnitude<=5
%         fTime = days(15);
%     else
%         fTime = (10.^(1.0526*fMagnitude-4.5610))/365;
%     end
otherwise
    disp('Choose a valid method number');
end
