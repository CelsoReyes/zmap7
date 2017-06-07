
dx = 0.1;
dy = 0.1;
ra = 30;
Nmin = 150;
selgp

mRes = [];

% Initialize
fMinTime = min(a(:,3));
fMaxTime = max(a(:,3));
fTimePeriod = fMaxTime-fMinTime;

% Minimum bin
fMinBin = roundn(min(a(:,6)),-1);
fMaxBin = roundn(max(a(:,6)),-1);

% Seismicity of catalog normalized to time period
nNumevents = max(length(a(:,1)));
fNum = nNumevents/fTimePeriod;

% Starttime
fTime = fMinTime;

fTimeWindow = 0.3;

nCnt = 1;

vFigpos = [300 400 600 500];
figure_w_normalized_uicontrolunits('visible','off','tag','time','Position', vFigpos);

while fTime < fMaxTime-2*fTimeWindow
    vSel = (a(:,3) >= fTime & a(:,3) < fTime+2*fTimeWindow);
    mCatalog = a(vSel,:);

    for i= 1:length(newgri(:,1))
        i/length(newgri(:,1));
        % Grid node point
        x = newgri(i,1);y = newgri(i,2);


        %        % Select earthquakes in non-overlapping rectangles
        %         vSel3 = (mCatalog(:,1) >= (newgri(i,1)-dx/2)) & (mCatalog(:,1) < (newgri(i,1)+dx/2)) &...
        %             (mCatalog(:,2) >= (newgri(i,2)-dy/2)) & (mCatalog(:,2) < (newgri(i,2)+dy/2));

        % Select earthquakes in overlapping rectangles
        %         vSel3 = (mCatalog(:,1) >= (newgri(i,1)-dx)) & (mCatalog(:,1) < (newgri(i,1)+dx)) &...
        %              (mCatalog(:,2) >= (newgri(i,2)-dy)) & (mCatalog(:,2) < (newgri(i,2)+dy));
        %         mCat = mCatalog(vSel3,:);

        % calculate distance from center point and sort with distance
        l = sqrt(((mCatalog(:,1)-x)*cos(pi/180*y)*111).^2 + ((mCatalog(:,2)-y)*111).^2) ;
        [s,is] = sort(l);

        % Choose between constant radius or constant number of events with maximum radius
        % Use Radius to determine grid node catalogs
        l3 = l <= ra;
        mCat = mCatalog(l3,:);      % new data per grid point (b) is sorted in distance


        % Change in FMD
        vSel1 = (mCat(:,3) >= fTime & mCat(:,3) < fTime+fTimeWindow);
        vSel2 = (mCat(:,3) >= fTime+fTimeWindow & mCat(:,3) < fTime+2*fTimeWindow);

        if (length(mCat(vSel1,6)) >= Nmin & length(mCat(vSel2,6)) >= Nmin)
            [vFMD1, vBin1] = hist(mCat(vSel1,6),fMinBin:0.1:fMaxBin);
            [vFMD2, vBin2] = hist(mCat(vSel2,6),fMinBin:0.1:fMaxBin);
            %plot(mCat(vSel1,1),mCat(vSel1,2),'go')
            fChFMD = max(cumsum(abs(vFMD2./fTimeWindow-vFMD1./fTimeWindow)));
            mRes = [mRes; fTime  fChFMD];
        else
            mRes = [mRes; fTime  nan];
        end
    end
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    % Relative rate change
    normlap2(ll)= mRes(:,2);
    mTimeMaxChange = reshape(normlap2,length(yvect),length(xvect));
    re3 = mTimeMaxChange/nanmean(mRes(:,2));


    % Define colormap
    mColormap = gui_Colormap_Rastafari(256);
    colormap(mColormap);
    % Define axis
    maxc = max(max(re3));
    maxc = fix(maxc)+1;
    minc = min(min(re3));
    minc = fix(minc)-1;
    orient landscape

    rect =[0.2500 0.1800 0.6000 0.7000];
    set(gca,'position',rect)
    hold on
    pco1 = pcolor(gx,gy,re3);
    set(pco1,'Linestyle','none')

    % Plot caostline and faults
    if exist('coastline') >  0
        if isempty(coastline) ==  0
            mapplot = plot(coastline(:,1),coastline(:,2));
            set(mapplot,'LineWidth',1.0,'Color',[0  0      0 ])
        end
    end
    if exist('faults') >0
        if isempty(faults) == 0
            plo3 = plot(faults(:,1),faults(:,2),'k');
            set(plo3,'LineWidth',1.0)
        end  % if exist faults
    end
    axis([ min(gx) max(gx) min(gy) max(gy)])
    %caxis([0 5])
    % Colorbar
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.1 0.4 0.02],...
        'FontWeight','bold','FontSize',fontsz.s,'TickDir','out')
    sTitlestr = ['Splittime : ' num2str(fTime+fTimeWindow)];
    title(sTitlestr);
%     sText = ['\Delta_{FMD}'];
%     text(0.25, 0.2,sText,'FontWeight','bold','FontSize',12);
    drawnow
%     sFigName = ['Scectime_' num2str(fTime+fTimeWindow) '.jpg'];
%     print('-djpeg','-r300','-cmyk','-zbuffer', sFigName);

    % Create movie
    F(nCnt) = getframe(gcf);
    nCnt=nCnt+1;
    mRes = [];
    % Shift time by half window width
    fTime = fTime+0.2;
end

save SCEC_0.1deg0.4twin_0.05stepR40km.mat F vFigpos
% Play movie
hM=figure_w_normalized_uicontrolunits('Position', vFigpos)
%set(gca,'Position',[0.2500 0.18 0.6000 0.7]);
% axis([ min(gx) max(gx) min(gy) max(gy)])
movie(hM,F,4,1,[0 0 1 1])
clear F

