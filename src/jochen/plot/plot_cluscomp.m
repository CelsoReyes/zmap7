function [vMags, vClusTime, vDist]=plot_cluscomp(vmain, vcluster, mCatalog, nMethod)
% function [vMags, vClusTime,vDist]=plot_cluscomp(vmain, vcluster, mCatalog, nMethod)
% ------------------------------------------------------------------------------
% Compare actual cluster length with applied windowing technique (Gardner & Knopoff)
%
% Incoming variables:
% vmain    : Vector of mainshocks
% vcluster : Vector with cluster numbers
% mCatalog : EQ catalog in ZMAP format
% nMethod  : Number of window lengths choice (see calc_windows.m)
%
% Outgoing variable:
% vMags     : Vector of magnitudes
% vClusTime : Vector of length of cluster
% vDist     : Vector of cluster distances
% J. Woessner
% updated: 14.08.02

% 28.08.02: Changed distance determination using distance now

mTmpCat = [vmain vcluster mCatalog];
% Select cluster
for nCevent = 1: max(mTmpCat(:,1))
    vSelClus = (mTmpCat(:,2) == nCevent);
    vSelMain = (mTmpCat(:,1) == nCevent);
    mTmpCat2 = mTmpCat(vSelClus,:);
    mTmpCat3 = mTmpCat(vSelMain,:);
    %%%% Calculating time difference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%% End of calculating time difference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%% Calculate spacial extend of cluster %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vMinClusLat(nCevent) = min(mTmpCat2(:,3));
    vMinClusLon(nCevent) = min(mTmpCat2(:,4));
    vMaxClusLat(nCevent) = max(mTmpCat2(:,3));
    vMaxClusLon(nCevent) = max(mTmpCat2(:,4));
    vMainLat(nCevent) = mTmpCat3(:,3); % If this does not work, then there is more than one mainshock, which doesn't make sense
    vMainLon(nCevent) = mTmpCat3(:,4); % If this does not work, then there is more than one mainshock, which doesn't make sense
    vDista(nCevent) = abs(distance(vMainLat(nCevent),vMainLon(nCevent),vMinClusLat(nCevent),vMinClusLon(nCevent)));
    vDistb(nCevent) = abs(distance(vMainLat(nCevent),vMainLon(nCevent),vMaxClusLat(nCevent), vMaxClusLon(nCevent)));
    if vDista(nCevent) >= vDistb(nCevent)
        vDist(nCevent) = deg2km(vDista(nCevent));
    else
        vDist(nCevent) = deg2km(vDistb(nCevent));
    end
    %%% End of calculating spacial extend of cluster %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vMags(nCevent) = mTmpCat3(:,8);
end % End of FOR over nCevent

% Figures
if exist('hd1_clus_fig','var') & ishandle(hd1_clus_fig)
    set(0,'Currentfigure',hd1_clus_fig);
    disp('Figure exists');
else
    hd1_clus_fig=figure_w_normalized_uicontrolunits('tag','fig_clus','Name','Cluster length in time and space','Units','normalized','Nextplot','add',...
        'Numbertitle','off');
end

vMagnitude = (0:0.1:10);
vMagnitudea = (0:0.1:6.5);
vMagnitudeb = (6.5:0.1:10);

subplot(2,1,1);
set(gca,'tag','ax1_clus','Nextplot','replace','box','on','Xlim', [0 8]);
axs1=findobj('tag','ax1_clus');
axes(axs1(1));
semilogy(vMags,vClusTime,'*');
hold on;

switch nMethod
case 1
    % Gardner & Knopoff
    vTimeGaKn74 = 10.^(0.5409*vMagnitudea-0.547);
    vTimeGaKn74b = 10.^(0.032*vMagnitudeb+2.7389); % M>=6.5
    semilogy(vMagnitudea,vTimeGaKn74,'Color',[1 0 0],'Linewidth', 2);
    semilogy(vMagnitudeb,vTimeGaKn74b,'Color',[1 0 0],'Linewidth', 2);
case 2
    % Gruenthal, pers. communication
    vTimeGra = exp(-3.95+sqrt(0.62+17.32*vMagnitudea));
    vTimeGrb = 10.^(2.8+0.024*vMagnitudeb); % M >= 6.5
    semilogy(vMagnitudea,vTimeGra,'Color',[0 0.8 0],'Linewidth', 2);
    semilogy(vMagnitudeb,vTimeGrb,'Color',[0 0.8 0],'Linewidth', 2);
case 3
    % Uhrhammer 1976
    vTimeUr = exp(-2.87+1.235*vMagnitude);
    semilogy(vMagnitude,vTimeUr,'Color',[0.5 0 0],'Linewidth', 2);
otherwise
    disp('Unknown method');
end
set(gca,'Xlim', [0 ceil(max(vMags))]);
xlabel('Magnitude');
ylabel('Time / [days]');
hold off;

subplot(2,1,2);
set(gca,'tag','ax2_clus','Nextplot','replace','box','on','Xlim', [0 8]);
axs2=findobj('tag','ax2_clus');
axes(axs2(1));
semilogy(vMags,vDist,'*');
hold on;
switch nMethod
case 1
    % % Gardner & Knopoff
    vSpaceGaKn74 = 10.^(0.1238*vMagnitude+0.983);
    semilogy(vMagnitude,vSpaceGaKn74,'Color',[1 0 0],'Linewidth', 2);
case 2
    % Gruenthal, pers. communication
    vSpaceGr = exp(1.77+sqrt(0.037+1.02*vMagnitude));
    semilogy(vMagnitude,vSpaceGr,'Color',[0 0.8 0],'Linewidth', 2);
case 3
    % Uhrhammer 1976
    vSpaceUr = exp(-1.024+0.804*vMagnitude);
    semilogy(vMagnitude,vSpaceUr,'Color',[0.5 0 0],'Linewidth', 2);
otherwise
    disp('Unknown method');
end
set(gca,'Xlim', [0 ceil(max(vMags))],'Ylim', [0 ceil(max(vDist))+100]);
xlabel('Magnitude');
ylabel('Distance / [km]');
hold off;

