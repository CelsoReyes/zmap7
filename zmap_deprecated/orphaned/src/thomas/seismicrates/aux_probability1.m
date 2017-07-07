function aux_radius(params, hParentFigure)
% function aux_FMD(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% Thomas van Stiphout, thomas@sed.ethz.ch
% last update: 7.9.2005


report_this_filefun(mfilename('fullpath'));

% Get the axes handle of the plotwindow
axes(sr_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
plot(fXGridNode, fYGridNode, '*r');

xx = -pi-0.1:0.1:pi;
if ~params.bMap
    plot(fXGridNode+cos(xx)*params.vResolution(nNodeGridPoint), fYGridNode+sin(xx)*params.vResolution(nNodeGridPoint),'-r')
else
    disp('WARNING: Radiusplot fuer mapview noch pruefen!! aux_radius.m')
    plot((fXGridNode+sin(xx)*params.vResolution(nNodeGridPoint)/(cos(pi/180*fYGridNode)*111))', (fYGridNode+sin(xx)*params.vResolution(nNodeGridPoint)/(cos(pi/180*fYGridNode)*111))','-k')
end
hold off;

% % call
% uiwait(dlboxb2p);               % way is now 'unif' or 'real'
% if cancquest=='yes'; return; end; clear cancquest;
%
% % call
% uiwait(beta2prob_dlbox1);       % NuRep is now defined
% if cancquest=='yes'; return; end; clear cancquest;
% NuRep=str2double(NuRep);



way = 'unif'
NuRep=100

% produce Big Catalog
if way=='unif'
    BigCatalog=sort(rand(100000,1));
else % if way=='real'
    whichs=ceil(length(newcat)*rand(100000,1)); % numbers in whichs from 1 to length(newcat)
    BigCatalog(100000,1)=0;
    for i=1:100000
        BigCatalog(i,1)=newcat(whichs(i),3);    % ith element of BigCatalog is random out of newcat
    end
    BigCatalog=sort(BigCatalog);
    BigCatalog=(BigCatalog-min(BigCatalog))/(max(BigCatalog)-min(BigCatalog));
end

% Transformation of synthetic catalog to probability
[ceil(params.fTminCat):params.fBinning:floor(params.fTmaxCat)-params.fBinning]';
NuBins=(floor(params.fTmaxCat)-ceil(params.fTminCat))/params.fBinning;

delta=params.fTwLength/params.fBinning/NuBins


for nto=1:NuRep
   disp(nto);

   which=ceil(100000*(rand(params.nNumberEvents,1)));
   for i=1:params.nNumberEvents
       rancata(i)=BigCatalog(which(i));
   end
   clear i which;
   mCatSyn_=(floor(params.fTminCat)+((floor(params.fTmaxCat)-ceil(params.fTminCat))*rancata))';
   % Histogram for whole period
   vR1Syn_=histogram(mCatSyn_(:),params.fTminCat:params.fTimeSteps/365:params.fTmaxCat);
   % Histogram for window length starting at fTimeCut
   tmp=[];
   tmp=histogram(mCatSyn_(:),params.fTimeCut-params.fTimeSteps/365:params.fTimeSteps/365:params.fTimeCut+params.fTwLength+params.fTimeSteps/365)';
   vR2Syn_=tmp(2:length(tmp)-1);

   mean1_= mean(vR1Syn_);
   mean2_= mean(vR2Syn_);
   var1_ = var(vR1Syn_);
   var2_ = var(vR2Syn_);


   clear rancata i;

   %FirstBin=ceil(rand(1)*(NuBins-params.fTwLength/params.fBinning+1));


   %zin=Bins(FirstBin:FirstBin+params.fTwLength/params.fBinning-1); zout=[Bins(1:FirstBin-1,1); Bins(FirstBin+params.fTwLength/params.fBinning:NuBins,1)];
   ToBeFitted(nto,1)=nto;
   % calculating beta
   %ToBeFitted(nto,2)=(sum(zin)-params.nNumberEvents*delta)/(sqrt(params.nNumberEvents*delta*(1-delta)));
   % calculating z
   ToBeFitted(nto,3)=(mean1_-mean2_)/sqrt(var1_/length(vR1Syn_)+var2_/(length(vR2Syn_)));
   clear mean1_ mean2_ var1_ var2_ Bins FirstBin zin zout;
end

clear BigCatalog nto;

[meanval, std] =normfit(ToBeFitted(:,2)); IsFitted(1,1)=meanval; IsFitted(1,2)=std;
[meanval, std] =normfit(ToBeFitted(:,3)); IsFitted(2,1)=meanval; IsFitted(2,2)=std;
clear meanval std;
clear ToBeFitted;

% Calculating rates changes for this node over time axes
% Selecting the date of the events from the sampling volume

vTimeSteps_=[params.fTminCat:params.fTimeSteps/365:params.fTimeCut];

for i=1:length(vTimeSteps_)
    i
    vR1Node_=histogram( params.mCatalog(params.caNodeIndices{nNodeGridPoint},3) ,params.fTminCat:params.fTimeSteps/365:params.fTmaxCat);
    tmp=[];
    tmp=histogram( params.mCatalog(params.caNodeIndices{nNodeGridPoint},3) ,vTimeSteps_(i):params.fTimeSteps/365:params.fTimeCut+params.fTwLength)';
    vR2Node_=tmp(2:length(tmp)-1);

    mean1_= mean(vR1Node_);
    mean2_= mean(vR2Node_);
    var1_ = var(vR1Node_);
    var2_ = var(vR2Node_);
    zValues(i)=(mean1_-mean2_)/sqrt((var1_/length(vR1Node_)+var2_/(length(vR2Node_))));
end


   j=0;
   for i=ceil(params.fTminCat):params.fBinning:floor(params.fTmaxCat)-params.fBinning
       l=sum(roundn(params.mCatalog(params.caNodeIndices{nNodeGridPoint},3),-1)==i);
       j=j+1 ;
       zBins(j,1)=sum(l);
       clear l;
   end



   for i=1:length(zBins)-params.fTwLength/params.fBinning
       zin=zBins(i:i+params.fTwLength/params.fBinning);
       zout=[zBins(1:i); zBins(i+params.fTwLength/params.fBinning:length(zBins))];



       betaValue(i)=(sum(zin)-params.nNumberEvents*delta)/(sqrt(params.nNumberEvents*delta*(1-delta)));
   end






% switch value2trans
% case 'beta'
%     Pbeta = normcdf(BetaValues,IsFitted(1,1),IsFitted(1,2));
%     l = Pbeta == 0; Pbeta(l) = nan;
% case 'z'
    Pbeta = normcdf(zValues,IsFitted(2,1),IsFitted(2,2));
    l = Pbeta == 0; Pbeta(l) = nan;
% end
% tmporaer=ceil(params.fTminCat):params.fBinning:floor(params.fTmaxCat-params.fTwLength)-params.fBinning % 1:1:length(zValues)
% plot the resuts
figure
pq = -log10(1-Pbeta); l = isinf(pq);pq(l) = 18 ;
pl1 = plot(vTimeSteps_,pq,'color',[0.0 0.5 0.9]);
hold on
l = pq < 1.3; pq(l) = nan;
pl3 = plot(vTimeSteps_,pq,'b','Linewidth',2);

pq = -log10(Pbeta);l = isinf(pq);pq(l) = 18 ;
pl2 = plot(vTimeSteps_,pq,'color',[0.8 0.6 0.8]);
l = pq < 1.3; pq(l) = nan;
pl4 = plot(vTimeSteps_,pq,'r','Linewidth',2);

maxd = [get(pl1,'Ydata') get(pl2,'ydata') ]; maxd(isinf(maxd)) = []; maxd = max(maxd);
if maxd < 5 ; maxd = 5; end
if isnan(maxd) == 1 ; maxd = 10; end

legend([pl3 pl4],'Rate increases','Rate decreases');
set(gca,'Ylim',[0 maxd+1])
set(gca,'YTick',[1.3 2 3 4 5])
set(gca,'YTickLabel',[ '    5%' ; '    1%' ;  '  0.1%' ;  ' 0.01%' ; '0.001%'])
set(gca,'TickDir','out','Ticklength',[0.02 0.02],'pos',[0.2 0.2 0.7 0.7]);
xlabel('Time [years]')
ylabel('Significance level');
set(gcf,'color','w')
grid



