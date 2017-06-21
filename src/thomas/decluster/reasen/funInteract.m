function [rmain,r1]= funInteract(var1,newcat,rfact,xmeff)
%interact.m                                        A.Allmann
% calculates the interaction zones of the earthquakes
% in [km]
%Last modification 6/95

%global newcat rfact xmeff

if var1==1
rmain = 0.011*10.^(0.4*newcat.Magnitude); %interaction zone for mainshock
%rmain = 10.^(-2.44+(.59*newcat.Magnitude));

%tm1=find(rmain==0.011);             %these eqs got no magnitude in the catalog
%tm2= 0.011*10^(0.4*xmeff);          %assume that for eqs with magnitude 0
%rmain(tm1)=tm2*ones(1,length(tm1)); %the real magnitude is around xmeff

r1    =rfact*rmain;                  %interaction zone if included in a cluster

end
