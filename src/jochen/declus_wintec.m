% declus_wintec.m
% ---------------------------------------------------------------
% Script to execute declustering by windowing technique
%
% Incoming variables:
% mCatalog : EQ catalog in ZMAP format
% nMethod  : Number describing the window used for declustering
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% Last update: 14.08.02
report_this_filefun(mfilename('fullpath'));

%%% Decluster catalog using window technique
[mCatDecluster, mCatAfter, vCluster, vCl, vMain] = calc_decluster(mCatalog,nMethod);
vSel = (vMain(:,1) > 0); % Selects mainshocks of clusters
mCluster = mCatalog(vSel,:);

%%% Plot comparison to window length
[vMags, vClusTime, vDist]= plot_cluscomp(vMain, vCluster, mCatalog, nMethod);

%%% Plot seismicity map, clusters and mainshocks
a = mCatDecluster;
update(mainmap());
plot(mCluster(:,1),mCluster(:,2),'m+');

%%% Calculate moment release
[fMomentCluster, vMomentCluster] = calc_moment(mCatAfter);
[fMomentorg, vMomentorg] = calc_moment(mCatalog);
fMomentpercentage = 100*fMomentCluster/fMomentorg;
fEventpercentage = 100*length(mCatAfter(:,1))/length(mCatalog(:,1)); % Percentage of events in clusters

%% Setup message box
sInfost1 = [' The declustering found ' num2str(max(vMain)) ' clusters of earthquakes, a total of '...
        ' ' num2str(length(mCatAfter(:,1))) ' (' num2str(fEventpercentage) '%)'...
        ' events out of ' num2str(length(mCatalog(:,1))) '. '...
        ' The map window now displays the declustered catalog containing ' num2str(length(mCatDecluster(:,1))) ' events as blue dots.' ....
        ' The individual clusters are displayed as magenta pluses. The seismic moment released by the clusters'...
        ' is ' num2str(fMomentCluster) ' Nm which is about ' num2str(fMomentpercentage) '% of the total seismic moment ('...
        ' ' num2str(fMomentorg) 'Nm) of the catalog.'  ];

msgbox(sInfost1,'Declustering Information')

%%% Plotting magnitude histogram
if exist('hd1_declus_wintec','var') & ishandle(hd1_declus_wintec)
    set(0,'Currentfigure',hd1_declus_wintec);
    disp('Figure exists');
else
    hd1_win_fig=figure_w_normalized_uicontrolunits('tag','fig_declus_wintec','Name','Histogram','Units','normalized','Nextplot','add',...
        'Numbertitle','off','Position',[0.4 0.2 .4 .6],'Menubar','none');
end

set(gca,'tag','ax_declus_wintec_mag','Nextplot','replace','box','on','Xticklabel', [0 10 100]);
axs1=findobj('tag','ax_declus_wintec_mag');
axes(axs1(1));
[vFreqMag] = hist(mCatAfter(:,6),(0:0.1:max(mCatalog(:,6))));
histogram(mCatAfter(:,6),(0:0.1:max(mCatalog(:,6))));
set(gca,'Xlim',[0 ceil(max(mCatalog(:,6)))],'Ylim',[0 ceil(max(vFreqMag))]);
xlabel('Magnitude (events of all clusters)');
