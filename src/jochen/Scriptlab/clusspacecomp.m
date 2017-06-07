function [vMags, vDist]=clusspacecomp(vmain, vcluster, mCatalog)
% function cluslengthcomp(vmain, vcluster, mCatalog);
% -------------------------------------------------------------
% Compare actual cluster length with applied windowing technique
% using the ECOS example
%
% Incoming variables:
% vmain: Vector of mainshocks
% vcluster : Vector with cluster numbers
% mCatalog : EQ catalog in ZMAP format
%
% Outgoing variable:
% vClusTime : Vector of length of Cluster
% E.G. tmp=load('/home/jowoe/PhD/Decluster/Data/ecos_all_cluster');
% J. Woessner
% last update: 30.07.02

mTmpCat = [vmain vcluster mCatalog];
%mTmpCat = mTmpCat(1:1000,:);
% Select cluster
for nCevent = 1: max(mTmpCat(:,1))
    vSelClus = (mTmpCat(:,2) == nCevent);
    vSelMain = (mTmpCat(:,1) == nCevent);
    mTmpCat2 = mTmpCat(vSelClus,:);
    mTmpCat3 = mTmpCat(vSelMain,:);
    vMinClusLat(nCevent) = min(mTmpCat2(:,3));
    vMinClusLon(nCevent) = min(mTmpCat2(:,4));
    vMaxClusLat(nCevent) = max(mTmpCat2(:,3));
    vMaxClusLon(nCevent) = max(mTmpCat2(:,4));
    vMainLat(nCevent) = mTmpCat3(:,3); % If this does not work, then there is more than one mainshock, which doesn't make sense
    vMainLon(nCevent) = mTmpCat3(:,4); % If this does not work, then there is more than one mainshock, which doesn't make sense
    vLatdista(nCevent) = vMainLat(nCevent) - vMinClusLat(nCevent);
    vLatdistb(nCevent) = vMainLat(nCevent) - vMaxClusLat(nCevent);
    vLondista(nCevent) = vMainLon(nCevent) - vMinClusLon(nCevent);
    vLondistb(nCevent) = vMainLon(nCevent) - vMaxClusLon(nCevent);
    if vLatdista(nCevent) >= vLatdistb(nCevent)
        vLatdist(nCevent) = deg2km(vLatdista(nCevent));
    else
        vLatdist(nCevent) = deg2km(vLatdistb(nCevent));
    end
    if vLondista(nCevent) >= vLondistb(nCevent)
        vLondist(nCevent) = deg2km(vLondista(nCevent));
    else
        vLondist(nCevent) = deg2km(vLondistb(nCevent));
    end
    if vLondist(nCevent) >= vLatdist(nCevent)
        vDist(nCevent) = vLondist(nCevent);
    else
        vDist(nCevent) = vLatdist(nCevent);
    end
    vMags(nCevent) = mTmpCat3(:,8);
end % End of FOR over nCevent
figure;
%[i]=find(vDist > exp(1.77+sqrt(0.037+1.02*vMags))) % Gruenthal, pers
%[i]=find(vDist > 10.^(0.1238*vMags+0.983)) % Gardner & Knopoff
%vMags(i) = NaN ;
semilogy(vMags,vDist,'*');
hold on;
vMagnitude = (0:0.1:10);
% vMagnitudea = (0:0.1:6.5);
% vMagnitudeb = (6.5:0.1:10);
%
% % Gardner & Knopoff
vSpaceGaKn74 = 10.^(0.1238*vMagnitude+0.983);
semilogy(vMagnitude,vSpaceGaKn74,'Color',[1 0 0],'Linewidth', 2);
% % vTimeGaKn74 = 10.^(0.5409*vMagnitudea-0.547);
% % vTimeGaKn74b = 10.^(0.032*vMagnitudeb+2.7389); % M>=6.5
% % semilogy(vMagnitudea,vTimeGaKn74,'Color',[1 0 0],'Linewidth', 2);
% % semilogy(vMagnitudeb,vTimeGaKn74b,'Color',[1 0 0],'Linewidth', 2);
%
% % % Gruenthal, 1985
% vSpaceGr85 = 10.^(0.1060*vMagnitude+1.0982);
%
% % Gruenthal, pers. communication
%vSpaceGr = exp(1.77+sqrt(0.037+1.02*vMagnitude));
%semilogy(vMagnitude,vSpaceGr,'Color',[0 0.8 0],'Linewidth', 2);
%
%
 set(gca,'Xlim', [0 8]);
 xlabel('Magnitude');
 ylabel('Distance / [km]');

