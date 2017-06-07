function [mLTA]=calc_zlta4(mCat,fTstart,fT,fTw,nTbin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: mLTA=calc_zlta4(mCat,fTstart,fT,fTw,nTbin);
%
% This function calculates the rate changes (z-value) of earthquake
% occurrencs between two periods. This function calculates rate changes for
% all the grid nodes together. Input is either a single vector or a whole
% matrix columnswise only with dates (not the whole catalog). Output is the
% z(lta)- and its probability value for each grid point.
%
% Author: van Stiphout, Thomas
% Email: vanstiphout@sed.ethz.ch
% Created: 2. Jul 2008
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables:
% mCat           Catalog complete (only origin time)  as Nx1-vector or
% NxMCS
% fTstart        Begin of time period 1
% fT             Date for which rate change is calculated
% fTw            Length of Time window of second period
% nTbin          Length of Time steps for histogram
%
% Output:
% mLTA           Scalar or vector with beta values for each input column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% disp('~/zmap/src/thomas/seismicrates/calc_zlta4.m');

% add dummyrow
mDummy=ones(1,size(mCat,2))*(-1);

% calculate histogram for different time periods
vR1=histc([mDummy; mCat],fTstart : nTbin/365 : fT-fTw,1);
% vR1=histc(mCat,fTstart : nTbin/365 : fT,1);
vR1=vR1(1:end-1,:);

% vR1=histc(mCat1,fTimeStart:fTimeSteps/365:fTimeCut+fTimeWindow);
vR2=histc([mDummy; mCat],fT-fTw : nTbin/365:fT,1);
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

% calculate z(lta)
mLTA=((mean1-mean2)./sqrt(var1./size(vR1,1)+var2./size(vR2,1)))';

