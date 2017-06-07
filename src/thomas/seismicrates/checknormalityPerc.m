function checknormalityPerc(nSim,fTstart,fT,fTw,nTbin,nN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: mLTA=calc_Perc(mCat00,mCat20,params.fTstart, fT,fTw,nTbin, nN);
%
% This function calculates the rate changes (z-value) of earthquake
% occurrencs between two periods. This function calculates rate changes for
% all the grid nodes together. Input is either a single vector or a whole
% matrix columnswise only with dates (not the whole catalog). Output is the
% z(lta)- and its probability value for each grid point.
%
% Author: van Stiphout, Thomas
% Email: vanstiphout@sed.ethz.ch
% Created: 7. Aug. 2007
% Changed: 14. Aug.2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables:
% mCat0          Catalog complete (only origin time)
% mCat1          Catalog period 1 (vector or matrix with yrs in column)
% mCat2          Catalog period 2 (vector or matrix with yrs in column)
% fTstart        Begin of time period 1
% fT             Date for which rate change is calculated
% fTw            Length of Time window of second period
% nTbin          Length of Time steps for histogram
% nN             Sampling volume
%
% Output:
% mLTA           Scalar or vector with beta values for each input column
% mProb          Scalar or vector with probability for beta values for each
%                input column. The probability is either calculated based
%                on a synthetic catalog or a real-like catalog.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('~/zmap/src/thomas/seismicrates/checknormality.m');
% probability calculation based on synthetic catalogs.
% Synthetic catalogs either based catalog with uniform rates (o) or according to
% complete catalog (1)
bSyn=logical(0);


% create synthetic catalogs to extimate significance level
% reset random number generator
rand('state',sum(100*clock));
mSyn1=rand(nN,nSim)*(fT-fTstart)+fTstart;
% apply histogram to synthetic catalog
vS1=histc(mSyn1,fTstart : nTbin/365 : fT-fTw,1);
vS1=vS1(1:end-1,:);
vS2=histc(mSyn1,fT-fTw : nTbin/365:fT,1);
vS2=vS2(1:end-1,:);
% calculate the mean rate for different periods in synthetic catalog
mSynMean1=mean(vS1);
mSynMean2=mean(vS2);
mSynPerc=(mSynMean2./mSynMean1.*100)-100;
% figure;
% subplot(3,1,1);histogram(mSynMean1-mSynMean2,20)
% subplot(3,1,2);histogram(mSynMean1,20)
% subplot(3,1,3);histogram(mSynMean2,20)
% figure;subplot(2,1,1);plot(vS1,'.');subplot(2,1,2);plot(vS2,'.');
% figure;
% histogram(sqrt(mSynVar1./size(vS1,1)+mSynVar2./size(vS2,1)),50)
% calculate values for normal distribution
% [jbt(i), jbp(i)]=jbtest(mSynLTA);
% llt(i)=lillietest(mSynLTA);
% mSynLTA=randn(nSim,1)
[mu,s] = normfit(mSynPerc)
figure_w_normalized_uicontrolunits('Position',[100 100 400 600]);
sTitle=sprintf('Normality of Percent; (%5.0f Simulations)',nSim);
set(gca,'fontsize',14)
subplot(2,1,1);
normplot(mSynPerc);
title(sTitle,'FontSize',18)
ylabel('Probability','FontSize',16);
xlabel('Percent','FontSize',16);
subplot(2,1,2);
[N,X]=histogram(mSynPerc,20);
XX=diff(X);fX0=XX(1);
fNorm=sum(N.*fX0)
vYnorm=N./fNorm;
bar(X,vYnorm);

% histogram(mSynLTA./nSim,100);
t=-100:5:100;
% fTmax=1/(s*sqrt(2*pi))*exp(-(X(find(N==max(N)))-mu).^2./(2*s^2));
% fAcorr=max(N)/fTmax;
ft=1/(s*sqrt(2*pi))*exp(-(t-mu).^2./(2*s^2));
hold on;plot(t,ft);
xlim([-100 100]);
ylabel({'Normalized Cumulative';'no of earthquakes'},'FontSize',16);
xlabel('Percent','FontSize',16);

sPrint=sprintf('print -dpng -r300 NormalityPerc%06.0fSim.png',nSim);
eval(sPrint);
disp(sPrint);
