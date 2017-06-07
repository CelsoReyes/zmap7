function [vForeshock, vAftershock]=calc_affoshock(vmain, vcluster)
% [vForeshock, vAftershock]=calc_affoshock(vmain, vcluster)
% ------------------------------------------------------------------------------
% Determine foreshocks and aftershocks
%
% Incoming variables:
% vmain    : Vector with mainshocks of clusters
% vcluster : Vector with events in cluster without mainshocks
%
% Outgoing variable:
% vForeshock   : Vector of foreshocks in cluster
% vAftershock  : Vector of aftershocks in cluster
% J. Woessner
% last update: 02.09.02

vForeshock = zeros(1,length(vmain));
vAftershock = zeros(1,length(vmain));

% Selection loop
for nCevent = 1: max(vmain(:,1))
    vSelMain = (vmain == nCevent);
    vSelCluster = (vcluster == nCevent);
    [vIndiceM] = find(vSelMain);
    [vIndiceC] = find(vSelCluster);
    for nI = 1:length(vIndiceC)
        if vIndiceC(nI) < vIndiceM
            vForeshock(vIndiceC(nI)) = nCevent;
        elseif vIndiceC(nI) > vIndiceM
            vAftershock(vIndiceC(nI)) = nCevent;
        else
            sErrorstring = ['Shock ' num2str(max(vIndiceM)) ' is identified as mainshock and foreshock/aftershock ???',...
                    'Check declustering method! Procedure aborted!'];
            errordlg(sErrorstring,'Clustering error');
            break;
        end % END of IF
    end % END of FOR nI
end % End of FOR over nCevent
vAftershock = vAftershock';
vForeshock = vForeshock';

