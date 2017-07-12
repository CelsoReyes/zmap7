function [mBeta]=calc_beta4(mCat,fTstart,fT,fTw,nTbin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example:[mBeta]=calc_beta(mCat,fTstart,fT,fTw,nTbin,nN);
%
% This function calculates the rate changes (beta-value) of earthquake
% occurrencs between two periods. This function calculates rate changes for
% all the grid nodes together. Input is either a single vector or a whole
% matrix columnswise only with dates (not the whole catalog). Output is the
% beta value for each grid point.
%
% Author: van Stiphout, Thomas
% Email: vanstiphout@sed.ethz.ch
% Created: 7. Aug. 2007
% Changed: 2. Jul. 2008
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables:
% mCat0          Catalog complete (only origin time)
% fTstart        Begin of time period 1
% fT             Date for which rate change is calculated
% fTw            Length of Time window of second period
% nTbin          Length of Time steps for histogram
%
% Output:
% mBeta          Scalar or vector with beta values for each input column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% disp('~/zmap/src/thomas/seismicrates/calc_beta4.m');

% add dummyrow
mDummy=ones(1,size(mCat,2))*(-1);

vR1=histc([mDummy;mCat],fTstart : days(nTbin) : fT,1);
vR1=vR1(1:end-1,:);

% vR1=histc(mCat1,fTimeStart:days(fTimeSteps):fTimeCut+fTimeWindow);
vR2=histc([mDummy;mCat],fT-fTw : days(nTbin):fT,1);
vR2=vR2(1:end-1,:);

if isempty(vR1)
    disp('Warning - Time Period 1 is without any event');
elseif isempty(vR2)
    disp('Warning - Time Period 2 is without any event');
end

% Calculation for real data
nEq1=sum(vR1);  % no of eq in the 1st period
nEq2=sum(vR2);  % no of eq in the 2nd period
nBin1=size(vR1,1); % no of bins in 1st period
% nBin2=size(vR2,1); % no of bins in 2nd period
iwl=fTw/days(nTbin);
fNormInvalLength=iwl/nBin1; % normalized interval length

% mBeta
mBeta=(nEq2 - nEq1.*fNormInvalLength )./sqrt(nEq1.*fNormInvalLength.*(1-fNormInvalLength));
% mBeta2=(nEq2-nEq1*nBin2/nBin1)/sqrt(nEq1*(nBin2/nBin1));
mBeta=mBeta';

