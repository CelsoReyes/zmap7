function plot_Maps4(sFilename)
%
%
%
load(sFilename)

%% plot results mean z values
cmin=-4;cmax=4;
figure_w_normalized_uicontrolunits('Name','Z-Value','Position',[100 25 400 400]);
mData=nan(size(nanmedian(params.mZ,1)));
mData=nanmedian(params.mZ,1);
% mData=params.mZ;
pcolor(params.vX,params.vY,...
    reshape(mData,...
    size(params.vY,1),size(params.vX,1)));
h=colorbar;
% set(h,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'median(z)')
colormap(jet);
xlabel('longitude');
ylabel('latitude');
shading interp;
hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
plot_WiemerWyss1994
xlim([-117.1 -115.6]);
ylim([33 35.2]);

% figure_w_normalized_uicontrolunits('Name','Std Z-Value');
% mData=nan(size(nanmean(params.mZ)));
% mData=nanstd(params.mZ);
% pcolor(params.vX,params.vY,...
%     reshape(mData,...
%     size(params.vY,1),size(params.vX,1)));
% h=colorbar;
% % set(h,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'std(z)')
% colormap(jet);
% xlabel('longitude');
% ylabel('latitude');
% shading interp;
% hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);

%
% figure_w_normalized_uicontrolunits('Name','Z-probability by cross-comparison');
% pcolor(params.vX,params.vY,...
%     reshape(calc_ProbColorbar2Value(1-params.vPcrZ),...
%     size(params.vY,1),size(params.vX,1)));
% plot_ProbColorbar2(cmin, cmax);
% % set(gca,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'P(z)')
%
% xlabel('longitude');
% ylabel('latitude');
% shading interp;
% hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
% % colorbar


figure_w_normalized_uicontrolunits('Name','Z-probability by overlap','Position',[100 25 400 400]);
pcolor(params.vX,params.vY,...
    reshape(calc_ProbColorbar2Value(1-params.vPolZ),...
    size(params.vY,1),size(params.vX,1)));
xlabel('longitude');
ylabel('latitude');
plot_ProbColorbar2(cmin, cmax);
% set(gca,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'P(z)')
shading interp;
hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
plot_WiemerWyss1994
xlim([-117.1 -115.6]);
ylim([33 35.2]);

%% plot results mean B-values
cmin=-4;cmax=4;
% figure_w_normalized_uicontrolunits('Name','Median Beta-Value');
% mData=nan(size(nanmedian(-params.mB)));
% mData=nanmedian(params.mB);
% pcolor(params.vX,params.vY,...
%     reshape(mData,...
%     size(params.vY,1),size(params.vX,1)));
% h=colorbar;
% % set(h,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'median(1-B)')
% colormap(jet);
% xlabel('longitude');
% ylabel('latitude');
% shading interp;
% hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
%
% figure_w_normalized_uicontrolunits('Name','Std Beta-Value');
% mData=nan(size(nanstd(params.mB)));
% mData=nanstd(params.mB);
% pcolor(params.vX,params.vY,...
%     reshape(mData,...
%     size(params.vY,1),size(params.vX,1)));
% h=colorbar;
% % set(h,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'std(1-B)')
% colormap(jet);
% xlabel('longitude');
% ylabel('latitude');
% shading interp;
% hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);

%
% figure_w_normalized_uicontrolunits('Name','Beta-probability by cross-comparison');
% pcolor(params.vX,params.vY,...
%     reshape(calc_ProbColorbar2Value(params.vPcrB),...
%     size(params.vY,1),size(params.vX,1)));
% plot_ProbColorbar2(cmin, cmax);
% % set(gca,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'P(B)')
% xlabel('longitude');
% ylabel('latitude');
% shading interp;
% hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
% % colorbar


figure_w_normalized_uicontrolunits('Name','Beta-probability by overlap','Position',[100 25 400 400]);
pcolor(params.vX,params.vY,...
    reshape(calc_ProbColorbar2Value(params.vPolB),...
    size(params.vY,1),size(params.vX,1)));
plot_ProbColorbar2(cmin, cmax);
% set(gca,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'P(B)')
xlabel('longitude');
ylabel('latitude');
shading interp;
hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
plot_WiemerWyss1994
xlim([-117.1 -115.6]);
ylim([33 35.2]);

figure_w_normalized_uicontrolunits('Name','Resolution','Position',[100 25 400 400]);
pcolor(params.vX,params.vY,...
    reshape(params.mSamples_,...
    size(params.vY,1),size(params.vX,1)));
h=colorbar;
% set(h,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'N')
xlabel('longitude');
ylabel('latitude');
shading interp;
hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.5);
plot_WiemerWyss1994
xlim([-117.1 -115.6]);
ylim([33 35.2]);

end

function plot_WiemerWyss1994
mLatLon=[[-117.1 33];
    [-115.6 33];
    [-115.6 35.2];
    [-117.1 35.2];
    [-117.1 33]];
hold on;plot(mLatLon(:,1),mLatLon(:,2),'k--');
mLanders=[-116.4 34.3];
hold on;plot(mLanders(1),mLanders(2),'ko','MarkerSize',20)
end

