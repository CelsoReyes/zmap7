function plot_srmapMultiples(params,bEpicenter,bFaults,bLim)
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

PP=1;

% check how many runs were made
nMaxLayer=size(params.mResult1,3);
vJJ=zeros(nMaxLayer,1);
vJJ(1:4)=1;
vIdx=randperm(nMaxLayer);
vJJ=vJJ(vIdx);
vJJ=find(vJJ==1)

if bFaults
    load ~/data/faults/mCA_faults.all.mat
end

 load ~/data/coastlines/coastlines.mat

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



if bEpicenter
    vSelEpi=((params.mCatalog(:,3)>params.fTstart) & (params.mCatalog(:,3)<params.fT)  );
    %     sum(vSel)
end

pmin=-4;pmax=4;


figure;

for ii=1:4
    jj=vJJ(ii);
    % determin min max for seismic rate change values z, beta
    mPlot1=params.mResult1(:,:,jj);
    mPlot2=params.mResult3(:,:,jj);
    if sGrid=='n'
        vSel1=find(mPlot1(:,2)<nResolution);
    else
        vSel1=find(mPlot1(:,2)>nResolution);
    end
    if sGrid=='n'
        vSel2=find(mPlot2(:,2)<nResolution);
    else
        vSel2=find(mPlot2(:,2)>nResolution);
    end
    c_1=ceil(max(abs(mPlot1(vSel1))));
    c_2=ceil(max(abs(mPlot2(vSel2))));
    cmaxabs=max([c_1 c_2]);
    cmin=-cmaxabs;cmin=-6;
    cmax=cmaxabs;cmax=6;
    clear vSel1 vSel2 c_1 c_2 cmaxabs mPlot1 mPlot2



    if PP==1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(2,2,ii) % plot z(lta)
        mPlot=params.mResult2(:,:,jj);
        if sGrid=='n'
            vSel=find(mPlot(:,2)>nResolution);
        else
            vSel=find(mPlot(:,2)<nResolution);
        end
        mPlot(vSel,:)=NaN;
        pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
            reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
            reshape(calc_ProbColorbar2Value(double(mPlot(:,1))),size(params.vY,1),size(params.vX,1)));
        plot_ProbColorbar2(pmin, pmax);
        title( 'Probability of Z - value','FontSize',12);
        plotshape
        if bEpicenter
            hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',2);
        end
        if bFaults
            hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',1);
        end

% plot coastlines
    hold on; plot(coastlines(:,1),coastlines(:,2),'k-','LineWidth',1);


        if bLim
            xlim(params.vLonLim);
            ylim([params.vLatLim(1) params.vLatLim(2)]);
            %     ylim(params.vLatLim);
        end
    else

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,2,ii) % plot z(lta)
        mPlot=params.mResult3(:,:,jj);
        if sGrid=='n'
            vSel=find(mPlot(:,2)>nResolution);
        else
            vSel=find(mPlot(:,2)<nResolution);
        end
        mPlot(vSel,:)=NaN;
        pcolor(reshape(params.mPolygon(:,1),size(params.vY,1),size(params.vX,1)),...
            reshape(params.mPolygon(:,2),size(params.vY,1),size(params.vX,1)),...
            reshape(double(mPlot(:,1)),size(params.vY,1),size(params.vX,1)));
        plot_srcColorbar(cmin, cmax);
        title('Z-value','FontSize',12);
        plotshape
        if bEpicenter
            hold on; plot(params.mCatalog(vSelEpi,1),params.mCatalog(vSelEpi,2),'k.','MarkerSize',2);
        end
        if bFaults
            hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',1);
        end

% plot coastlines
    hold on; plot(coastlines(:,1),coastlines(:,2),'k-','LineWidth',1);

        shading interp;
        if bLim
            xlim(params.vLonLim);
            ylim([33.75 params.vLatLim(2)]);
            %     ylim(params.vLatLim);
        end

    end
end




    function plotshape
        xlabel('Longitude','FontSize',14);
        ylabel('Latitude','FontSize',14);
        set(gca,'FontSize',12);
        set(gcf,'Renderer','zbuffer');
        shading interp;
