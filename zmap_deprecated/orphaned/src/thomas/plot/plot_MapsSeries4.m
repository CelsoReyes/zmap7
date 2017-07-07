function plot_MapsSeries4(sFilename)
%
%
%
load(sFilename)

%% plot results mean z values
cmin=-4;cmax=4;

for i=1:size(params.mPolZ,2)

figure_w_normalized_uicontrolunits('Name','Z-probability by overlap','Position',[100 25 400 400]);
pcolor(params.vX,params.vY,...
    reshape(calc_ProbColorbar2Value(1-params.mPolZ(:,i)),...
    size(params.vY,1),size(params.vX,1)));
xlabel('longitude');
ylabel('latitude');
title(sprintf('%6.1f-%6.1f vs. %6.1f-%6.1f',params.fTstart,...
    params.fT-params.mVar(i,1),params.fT-params.mVar(i,1),params.fT));
plot_ProbColorbar2(cmin, cmax);
% set(gca,'XAxisLocation','Top','XTick',0.5,'XTickLabel', 'P(z)')
shading interp;
hold on;plot(params.mCatalog(:,1),params.mCatalog(:,2),'k.','MarkerSize',0.1);
plot_WiemerWyss1994
xlim([-117.1 -115.6]);
ylim([33 35.2]);

end

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

