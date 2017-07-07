function [vMags, vClusTime]=cluslengthcomp(vmain, vcluster, mCatalog)
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
%     if isempty(mTmpCat2)
%         disp('oo');
%     end
    mTmpCat3 = mTmpCat(vSelMain,:);
    vMinClusTime(nCevent) = min(mTmpCat2(:,5));
    vMaxClusTime(nCevent) = max(mTmpCat2(:,5));
    vMainTime(nCevent) = mTmpCat3(:,5); % If this does not work, then there is more than one mainshock, which doesn't make sense
    if vMainTime(nCevent) < vMinClusTime(nCevent)
        vMinClusTime(nCevent) = vMainTime(nCevent);
    end % END of if-check for minimum date of cluster
    if vMainTime(nCevent) > vMaxClusTime(nCevent)  % This should actually not happen
        vMaxClusTime(nCevent) = vMainTime(nCevent);
    end % END of if-check for maximum date of cluster
    vClusTime(nCevent) = (vMaxClusTime(nCevent)-vMinClusTime(nCevent))*365;
    vMags(nCevent) = mTmpCat3(:,8);
end % End of FOR over nCevent
figure;
%[i]=find(vClusTime > 10.^(0.5409*vMags-0.547)) % Gardner & Knopoff
%[i]=find(vClusTime > 10.^(0.5055*vMags-0.1329)) % Gruenthal, 1985
%[i]=find(vClusTime > exp(-3.95+sqrt(0.62+17.32*vMags))) % Gruenthal, pers

%vMags(i) = NaN ;
semilogy(vMags,vClusTime,'*');
hold on;
vMagnitude = (0:0.1:10);
vMagnitudea = (0:0.1:6.5);
vMagnitudeb = (6.5:0.1:10);

% Gardner & Knopoff
vTimeGaKn74 = 10.^(0.5409*vMagnitudea-0.547);
vTimeGaKn74b = 10.^(0.032*vMagnitudeb+2.7389); % M>=6.5
semilogy(vMagnitudea,vTimeGaKn74,'Color',[1 0 0],'Linewidth', 2);
semilogy(vMagnitudeb,vTimeGaKn74b,'Color',[1 0 0],'Linewidth', 2);

% % Gruenthal, 1985
% vSpaceGr85 = 10.^(0.1060*vMagnitude+1.0982);
% vTimeGr85 = 10.^(0.5055*vMagnitude-0.1329);
% semilogy(vMagnitude,vTimeGr85,'Color',[1 0 0],'Linewidth', 2);

% Gruenthal, pers. communication
% vSpaceGr = exp(1.77+sqrt(0.037+1.02*vMagnitude));
% vTimeGra = exp(-3.95+sqrt(0.62+17.32*vMagnitudea));
% vTimeGrb = 10.^(2.8+0.024*vMagnitudeb); % M >= 6.5
% semilogy(vMagnitudea,vTimeGra,'Color',[0 0.8 0],'Linewidth', 2);
% semilogy(vMagnitudeb,vTimeGrb,'Color',[0 0.8 0],'Linewidth', 2);


set(gca,'Xlim', [0 8]);
xlabel('Magnitude');
ylabel('Time / [days]');

