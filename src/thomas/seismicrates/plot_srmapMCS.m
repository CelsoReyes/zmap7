function plot_srmapMCS(params,bEpicenter,bFaults,bLim)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: plot_srmaps(params, 2,200,[],100)
%
% This function plots mean-maps of z, beta, and the "probability of them".
%
% Input
% sFileName       filename with the params-matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author:
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
%
% Created on 31.08.2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check how many runs were made
nMaxLayer=size(params.mResult1,3);
sString=sprintf('Result matrix has %3.0f layer/s. Which one would you like to display?\r',nMaxLayer);
% reply = input(sString,'s');
% if isempty(reply)
%     reply = '1';
%     disp('Warning: No entry, Value is set to 1')
% end
% jj=str2double(reply);

if bFaults
    load ~/data/faults/mCA-faults.mat
end



% create matrix with mean values
params.mResult1_mean=mean(double(params.mResult1),3);
params.mResult2_mean=mean(double(params.mResult2),3);
params.mResult3_mean=mean(double(params.mResult3),3);
params.mResult4_mean=mean(double(params.mResult4),3);

% create matrix with std values
params.mResult1_std=std(double(params.mResult1),[],3);
params.mResult2_std=std(double(params.mResult2),[],3);
params.mResult3_std=std(double(params.mResult3),[],3);
params.mResult4_std=std(double(params.mResult4),[],3);

% copy resolution from mean-matrix to std-matrix
params.mResult1_std(:,2)=params.mResult1_mean(:,2);
params.mResult2_std(:,2)=params.mResult2_mean(:,2);
params.mResult3_std(:,2)=params.mResult3_mean(:,2);
params.mResult4_std(:,2)=params.mResult4_mean(:,2);


if bEpicenter
    vSelEpi=((params.mCatalog(:,3)>params.fTstart) & (params.mCatalog(:,3)<params.fT)  );
%     sum(vSel)
end

sString=sprintf('Radius or No.of Event - Gridding (r/n) [default = n]?\r');
sGrid = input(sString,'s');
if isempty(sGrid)  sGrid = 'n'; disp('Warning: No entry, default no.of event - gridding') ; end
switch sGrid
    case 'n'
        sString=sprintf('Max resolution to be plotted (km) [default=50km]?\r');
        reply = input(sString,'s');
        if isempty(reply)  reply = '50';  disp('Warning: default max. resolution is set to 50km') ; end
    case 'r'
        sString=sprintf('Minimum Number of Events per grid node [default=50]?\r');
        reply = input(sString,'s');
        if isempty(reply)  reply = '50';  disp('Warning: default min no. of events is set to 50') ; end
    otherwise
        reply = '50';  disp('Warning: default min no. of events is set to 50') ;
end
nResolution=str2double(reply);



% determin min max for seismic rate change values z, beta
mPlot1=params.mResult1(:,:,1);
mPlot2=params.mResult3(:,:,1);
if sGrid=='n'
    vSel1=find(mPlot1(:,2)>25);
else
    vSel1=find(mPlot1(:,2)<nResolution);
end
if sGrid=='n'
    vSel2=find(mPlot2(:,2)>nResolution);
else
    vSel2=find(mPlot2(:,2)<nResolution);
end
c_1=ceil(max(abs(mPlot1(vSel1))));
c_2=ceil(max(abs(mPlot2(vSel2))));
cmaxabs=max([c_1 c_2]);
cmin=-cmaxabs;
cmax=cmaxabs;
clear vSel1 vSel2 c_1 c_2 cmaxabs mPlot1 mPlot2
pmin=0;pmax=4

% mean figure
figure_w_normalized_uicontrolunits('Position',[000 25 450 750]);
subplot(2,1,1) % plot prob(z(lta))
mPlot=params.mResult2_mean;
if sGrid=='n' vSel=find(mPlot(:,2)>nResolution); else vSel=find(mPlot(:,2)<nResolution); end
mPlot(vSel,:)=NaN;
pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
    reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
    reshape(-log10(1-mPlot(:,1)),size(params.vY,1),size(params.vX,1)));
plot_ProbColorbar(pmin, pmax);
title('mean of Z-probability value','FontSize',12);
xlabel('Longitude','FontSize',14);
ylabel('Latitude','FontSize',14);
set(gca,'FontSize',12)
if bEpicenter
    hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',2);
end
if bFaults
    hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',2);
end

if bLim
    xlim(params.vLonLim);
    ylim([33.75 params.vLatLim(2)]);
%     ylim(params.vLatLim);
end
shading interp;

subplot(2,1,2) % plot prob(z(lta))
mPlot=params.mResult4_mean;
if sGrid=='n' vSel=find(mPlot(:,2)>nResolution); else vSel=find(mPlot(:,2)<nResolution); end
mPlot(vSel,:)=NaN;
pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
    reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
    reshape(-log10(1-mPlot(:,1)),size(params.vY,1),size(params.vX,1)));
plot_ProbColorbar(pmin, pmax);
title('mean of \beta-probability value','FontSize',12);
xlabel('Longitude','FontSize',14);
ylabel('Latitude','FontSize',14);
set(gca,'FontSize',12)

if bEpicenter
    hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',1);
end
if bFaults
    hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',2);
end

if bLim
    xlim(params.vLonLim);
    ylim([33.75 params.vLatLim(2)]);
%     ylim(params.vLatLim);
end
shading interp;

%
% % std figure
% figure_w_normalized_uicontrolunits('Position',[600 25 600 900]);
% subplot(2,1,1) % plot prob(z(lta))
% mPlot=params.mResult1_std;
% if sGrid=='n' vSel=find(mPlot(:,2)>nResolution); else vSel=find(mPlot(:,2)<nResolution); end
% mPlot(vSel,:)=NaN;
% pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
%     reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
%     reshape(mPlot(:,1),size(params.vY,1),size(params.vX,1)));
% plot_srcColorbar(cmin, cmax);
% title('std of Z-probability value');xlabel('Longitude');ylabel('Latitude');
%
% if bEpicenter
%     hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',2);
% end
% if bFaults
%     hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',2);
% end
%
% subplot(2,1,2) % plot prob(z(lta))
% mPlot=params.mResult3_std;
% if sGrid=='n' vSel=find(mPlot(:,2)>nResolution); else vSel=find(mPlot(:,2)<nResolution); end
% mPlot(vSel,:)=NaN;
% pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
%     reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
%     reshape(mPlot(:,1),size(params.vY,1),size(params.vX,1)));
% plot_srcColorbar(cmin, cmax);
% title('std of beta-probability value');xlabel('Longitude');ylabel('Latitude');
%
% if bEpicenter
%     hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',1);
% end
% if bFaults
%     hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',2);
% end
%
% %
% % % std figure
% % figure_w_normalized_uicontrolunits('Position',[600 25 600 900]);
% % subplot(2,1,1) % plot prob(z(lta))
% % mPlot=params.mResult2_std;
% % if sGrid=='n' vSel=find(mPlot(:,2)>nResolution); else vSel=find(mPlot(:,2)<nResolution); end
% % mPlot(vSel,:)=NaN;
% % pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
% %     reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
% %     reshape(-log10(1-mPlot(:,1)),size(params.vY,1),size(params.vX,1)));
% % colormap(abs((gui_Colormap_ReadPovRay('ProbabilitySRC0-4sigma.pov'))))
% % set(gca,'CLim',[pmin pmax]);
% % colorbar('Location','EastOutside',...
% %     'YLim',[pmin pmax],...
% %     'YTick',      [0, 0.3010, 0.7995,  1.3010, 1.6430, 2.8697, 3.5229, 4],...
% %     'YTickLabel',{'0', '0.5', '1s', '0.95', '2s', '3s', '4s', '0.9999'});
% % title('std of Z-probability value');xlabel('Longitude');ylabel('Latitude');
% %
% % if bEpicenter
% %     hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',2);
% % end
% % if bFaults
% %     hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',2);
% % end
% %
% % subplot(2,1,2) % plot prob(z(lta))
% % mPlot=params.mResult4_std;
% % if sGrid=='n' vSel=find(mPlot(:,2)>nResolution); else vSel=find(mPlot(:,2)<nResolution); end
% % mPlot(vSel,:)=NaN;
% % pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
% %     reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
% %     reshape(-log10(1-mPlot(:,1)),size(params.vY,1),size(params.vX,1)));
% % colormap(abs((gui_Colormap_ReadPovRay('ProbabilitySRC0-4sigma.pov'))))
% % set(gca,'CLim',[pmin pmax]);
% % colorbar('Location','EastOutside',...
% %     'YLim',[pmin pmax],...
% %     'YTick',      [0, 0.3010, 0.7995,  1.3010, 1.6430, 2.8697, 3.5229, 4],...
% %     'YTickLabel',{'0', '0.5', '1s', '0.95', '2s', '3s', '4s', '0.9999'});
% % title('std of \beta-probability value');xlabel('Longitude');ylabel('Latitude');
% %
% % if bEpicenter
% %     hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',1);
% % end
% % if bFaults
% %     hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',2);
% % end
