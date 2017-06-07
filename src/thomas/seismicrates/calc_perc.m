function [mPerc, mProb] =calc_zlta(mCat0,mCat1,mCat2,fTstart,fT,fTw,nTbin,nN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: mLTA=calc_zlta(mCat00,mCat20,params.fTstart, fT,fTw,nTbin, nN);
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

% disp('~/zmap/src/thomas/seismicrates/calc_zlta.m');
% probability calculation based on synthetic catalogs.
% Synthetic catalogs either based catalog with uniform rates (o) or according to
% complete catalog (1)
bSyn=logical(0);

% calculate histogram for different time periods
% nSteps=floor((fT-fTstart)/(nTbin/365));
% vR1=histc(mCat1,  fTstart:(nTbin/365):fTstart+nSteps*(nTbin/365)  );
vR1=histc(mCat1,fTstart : nTbin/365 : fT-fTw,1);
vR1=vR1(1:end-1,:);

% vR1=histc(mCat1,fTimeStart:fTimeSteps/365:fTimeCut+fTimeWindow);
vR2=histc(mCat2,fT-fTw : nTbin/365:fT,1);
vR2=vR2(1:end-1,:);


% calculate the mean rate for different periods
mean1=mean(vR1);
mean2=mean(vR2);


var1 = var(vR1);
var2 = var(vR2);

if isempty(vR1)
    disp('Warning - Time Period 1 is without any event');
elseif isempty(vR2)
    disp('Warning - Time Period 2 is without any event');
end

% create synthetic catalogs to extimate significance level
% reset random number generator
rand('state',sum(100*clock));
if bSyn
    vPos=ceil(rand(nN,1000).*size(mCat0,1));
    mSyn1=mCat0(vPos);
 else
    mSyn1=rand(nN,1000)*(fT-fTstart)+fTstart;
end
% apply histogram to synthetic catalog
vS1=histc(mSyn1,fTstart : nTbin/365 : fT-fTw,1);
vS1=vS1(1:end-1,:);
vS2=histc(mSyn1,fT-fTw : nTbin/365:fT,1);
vS2=vS2(1:end-1,:);
% calculate the mean rate for different periods in synthetic catalog
mSynMean1=mean(vS1);
mSynMean2=mean(vS2);
% calculate z(lta) values for synthetic catalog
mSynPerc=(mSynMean2./mSynMean1.*100)-100;
% calculate values for normal distribution
% [jbt(i), jbp(i)]=jbtest(mSynLTA);
% llt(i)=lillietest(mSynLTA);
[mu,s] = normfit(mSynPerc);

% z(lta)
mPerc=(mean2./mean1.*100)-100;
% calculate the probability of z(lta)-values
[mProb] = 1-normpdf(mPerc,mu,s);
% figure;plot(mLTA,mProb,'.');
