function [rmain,r1]= funInteract(mycat,rfact)
% calculates the interaction zones of the earthquakes in [km]
% A.Allmann

rmain = 0.011*10.^(0.4*mycat.Magnitude); %interaction zone for mainshock

r1    =rfact*rmain;                  %interaction zone if included in a cluster
