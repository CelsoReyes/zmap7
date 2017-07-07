function plot_srmapMovie(params,bEpicenter,bFaults,bLim)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: plot_srmaps(params, 2,200,[],100)
%
% This function plots z, beta, and the "probability of them"-maps.
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

if bFaults
    load ~/data/faults/mCA-faults.mat
end

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

mkdir movie
pmin=-4;pmax=4;

for jj=1:nMaxLayer
    if jj==1 figure; else hold on; end
    jj
% subplot(2,1,1) % plot prob(z(lta))
mPlot=params.mResult2(:,:,jj);
if sGrid=='n'
    vSel=find(mPlot(:,2)>nResolution);
else
    vSel=find(mPlot(:,2)<nResolution);
end
mPlot(vSel,:)=NaN;
pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
    reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
    reshape(calc_ProbColorbar2Value(mPlot(:,1)),size(params.vY,1),size(params.vX,1)));
plot_ProbColorbar2(pmin, pmax);
set(colorbar,'Visible','off');
title( 'Probability of Z - value','FontSize',12);
plotshape
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

eval(sprintf('print -dpng movie/%s.png',num2str(jj)));


end


    function plotshape
        xlabel('Longitude','FontSize',14);
        ylabel('Latitude','FontSize',14);
        set(gca,'FontSize',12);
        set(gcf,'Renderer','zbuffer');
        shading interp;
