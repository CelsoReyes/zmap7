function [mBeta, mProb] =checknormalityB(nSim,fTstart,fT,fTw,nTbin,nN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example:[mBeta,% mBetaprob]=calc_beta(mCat,mCat00,mCat20,params.fTstart,.
%                                  fT,fTw,nTbin, nN);
%
% This function calculates the rate changes (beta-value) of earthquake
% occurrencs between two periods. This function calculates rate changes for
% all the grid nodes together. Input is either a single vector or a whole
% matrix columnswise only with dates (not the whole catalog). Output is the
% zbeta- and its probability value for each grid point.
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
% mBeta          Scalar or vector with beta values for each input column
% mProb          Scalar or vector with probability for beta values for each
%                input column. The probability is either calculated based
%                on a synthetic catalog or a real-like catalog.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('~/zmap/src/thomas/seismicrates/checknormalityB.m');
% probability calculation based on synthetic catalogs.
% Synthetic catalogs either based catalog with uniform rates (o) or according to
% complete catalog (1)
bSyn=logical(0);

% vR1=histc(mCat1,fTstart : nTbin/365 : fT);
% vR1=vR1(1:end-1,:);
%
% % vR1=histc(mCat1,fTimeStart:fTimeSteps/365:fTimeCut+fTimeWindow);
% vR2=histc(mCat2,fT-fTw : nTbin/365:fT);
% vR2=vR2(1:end-1,:);
%
% % calculate the mean rate for different periods
% mean1=mean(vR1);
% mean2=mean(vR2);
%
% var1 = var(vR1);
% var2 = var(vR2);
%
% if isempty(vR1)
%     disp('Warning - Time Period 1 is without any event');
% elseif isempty(vR2)
%     disp('Warning - Time Period 2 is without any event');
% end

% create synthetic catalogs to extimate significance level
% reset random number generator
rand('state',sum(100*clock));
mSyn1=rand(nN,nSim)*(fT-fTstart)+fTstart;
% apply histogram to synthetic catalog
vS1=histc(mSyn1,fTstart : nTbin/365 : fT);
vS1=vS1(1:end-1,:);
vS2=histc(mSyn1,fT-fTw : nTbin/365:fT);
vS2=vS2(1:end-1,:);
% preparation for beta calculation
nEq1=sum(vS1);  % no of eq in the 1st period
nEq2=sum(vS2);  % no of eq in the 2nd period
nBin1=size(vS1,1); % no of bins in 1st period
nBin2=size(vS2,1);; % no of bins in 2nd period
% iwl=fTw*365/nTbin;
fNormInvalLength=nBin2/nBin1; % normalized interval length
% mSynBeta
mSynBeta=(nEq2 - nEq1.*fNormInvalLength )./sqrt(nEq1.*fNormInvalLength.*(1-fNormInvalLength));
% mSynBeta=randn(nSim,1);
[mu,s] = normfit(mSynBeta)
% [bmu,bs] = binofit(mSynBeta);
figure_w_normalized_uicontrolunits('Position',[100 100 400 600]);
sTitle=sprintf('Normality of \beta; (%5.0f Simulations)',nSim);
set(gca,'fontsize',14);
subplot(2,1,1);
normplot(mSynBeta);
title(sTitle,'FontSize',18)
ylabel('Probability','FontSize',16);
xlabel('\beta-value','FontSize',16);
subplot(2,1,2);
[N,X]=histogram(mSynBeta,100);
XX=diff(X);fX0=XX(1);
fNorm=sum(N.*fX0);
vYnorm=N./fNorm;
bar(X,vYnorm);

t=-5:0.1:5;
% fTmax=1/(s*sqrt(2*pi))*exp(-(X(find(N==max(N)))-mu).^2./(2*s^2));
% fAcorr=max(N)/fTmax;
ft=1/(s*sqrt(2*pi))*exp(-(t-mu).^2./(2*s^2));
hold on;plot(t,ft);
xlim([-4 4]);
ylabel({'Normalized Cumulative';'no of earthquakes'},'FontSize',16);
xlabel('\beta-value','FontSize',16);

sPrint=sprintf('print -dpng -r300 NormalityB%06.0fSim.png',nSim);
eval(sPrint);
 disp(sPrint);
