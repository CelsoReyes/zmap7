function [rmain_km,r1]= funInteract(mycat,rfact)
% calculates the interaction zones of the earthquakes in [km]
% A.Allmann

rmain_km = 0.011*10.^(0.4*mycat.Magnitude); %interaction zone for mainshock

r1    =rfact*rmain_km;                  %interaction zone if included in a cluster
