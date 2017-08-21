function [mBeta, mProb] =calc_beta4(mCat,fTstart,fT,fTw,nTbin,nN)
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

% disp('~/zmap/src/thomas/seismicrates/calc_beta.m');
% probability calculation based on synthetic catalogs.
% Synthetic catalogs either based catalog with uniform rates (o) or according to
% complete catalog (1)
bSyn=true;

vR1=histc(mCat1,fTstart : days(nTbin) : fT,1);
vR1=vR1(1:end-1,:);

% vR1=histc(mCat1,fTimeStart:days(fTimeSteps):fTimeCut+fTimeWindow);
vR2=histc(mCat2,fT-fTw : days(nTbin):fT,1);
vR2=vR2(1:end-1,:);

% % calculate the mean rate for different periods
% mean1=mean(vR1);
% mean2=mean(vR2);
%
% var1 = var(vR1);
% var2 = var(vR2);

if isempty(vR1)
    disp('Warning - Time Period 1 is without any event');
elseif isempty(vR2)
    disp('Warning - Time Period 2 is without any event');
end

% create synthetic catalogs to extimate significance level
% reset random number generator
rand('state',sum(100*clock));
if bSyn
    vPos=ceil(rand(nN,5000).*size(mCat0,1));
    mSyn1=mCat0(vPos);
 else
    mSyn1=rand(nN,5000)*(fT-fTstart)+fTstart;
end
% apply histogram to synthetic catalog
vS1=histc(mSyn1,fTstart : days(nTbin) : fT,1);
vS1=vS1(1:end-1,:);
vS2=histc(mSyn1,fT-fTw : days(nTbin):fT,1);
vS2=vS2(1:end-1,:);
% preparation for beta calculation
nEq1=sum(vS1);  % no of eq in the 1st period
nEq2=sum(vS2);  % no of eq in the 2nd period
nBin1=size(vS1,1); % no of bins in 1st period
% nBin2=size(vS2,1); % no of bins in 2nd period
winlen_days=fTw/days(nTbin);
fNormInvalLength=winlen_days/nBin1; % normalized interval length
% mSynBeta
mSynBeta=(nEq2 - nEq1.*fNormInvalLength )./sqrt(nEq1.*fNormInvalLength.*(1-fNormInvalLength));
% calculate values for normal distribution
[mu,s] = normfit(mSynBeta);

% Calculation for real data
nEq1=sum(vR1);  % no of eq in the 1st period
nEq2=sum(vR2);  % no of eq in the 2nd period
nBin1=size(vR1,1); % no of bins in 1st period
% nBin2=size(vR2,1); % no of bins in 2nd period
winlen_days=fTw/days(nTbin);
fNormInvalLength=winlen_days/nBin1; % normalized interval length

% mBeta
mBeta=(nEq2 - nEq1.*fNormInvalLength )./sqrt(nEq1.*fNormInvalLength.*(1-fNormInvalLength));
% mBeta2=(nEq2-nEq1*nBin2/nBin1)/sqrt(nEq1*(nBin2/nBin1));
mBeta=mBeta';
[mProb]=1-normcdf(mBeta,mu,s);

