function [mGrid]=calc_SynRateGrid(nNeqM4,fMinLon,fMaxLon,fMinLat,fMaxLat,dfLon,dfLat,nMode,mCat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: [mGrid] = calc_SynRateGrid(12,-118.2,-114.5,32.1,36.1,0.25,0.25,2,a);
%
% This function (calc_SynRateGrid) calculates the rates on the grid for the
% background rate used for calc_SynCat (program package ETESProject by karen
% Felzer was used.)
%
% Author: van Stiphout, Thomas
% Email: vanstiphout@sed.ethz.ch
% Created: 12. Nov 2007
% Changed: -
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Variables
% Input:
% nNeqM4         No. of Events with greater M>=4 eqs/year
% fMinLon    Min Longitude of rate grid
% fMaxLon    Max Longitude of rate grid
% fMinLat    Min Latitude of rate grid
% fMaxLat    Max Latitiude of rate grid
% dfLon      discretization for Longitude grid
% dfLat      discretization for Latitude grid
% nMode      rate grid mode 1: uniform rate, 2: rate according to real data
%              3: probability of an earthquake to occure in this polygon
%
% Output:
% SynCat Simulated ETES catalog [yr lon lat month day mag depth hrs min sec]
% vMain            Vector with assignments if main (=1) or aftershock (=0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vLon=[fMinLon:dfLon:fMaxLon]';
vLat=[fMinLat:dfLat:fMaxLat]';

for i=1:size(vLon,1)-1
    for j=1:size(vLat,1)-1
        mGrid((i-1)*(size(vLat,1)-1)+j,1:4)=[vLon(i),vLon(i+1), vLat(j),vLat(j+1)];
    end
end

% switch btw different rategrids (uniform (nMode = 1)  according to real
% data (n Mode = 2)
switch nMode
    case 1
        mGrid(:,5)=nNeqM4/size(mGrid,1);
    case 2
        nNeqM4=sum(mCat(:,6)>=4)/(max(mCat(:,3))-min(mCat(:,3)))
        for i=1:size(mGrid)
            mGrid_sum(i)= sum(mCat(:,1)>=mGrid(i,1) & mCat(:,1)<mGrid(i,2) & ...
                mCat(:,2)>=mGrid(i,3) & mCat(:,2)<mGrid(i,4));
        end
        % normalize values in mGrid_sum
        mGridNorm=mGrid_sum/sum(mGrid_sum);
        mGrid(:,5)=nNeqM4*mGridNorm;
    case 3
%         nNeqM4=sum(mCat(:,6)>=4)/(max(mCat(:,3))-min(mCat(:,3)))
        for i=1:size(mGrid)
            mGrid_sum(i)= sum(mCat(:,1)>=mGrid(i,1) & mCat(:,1)<mGrid(i,2) & ...
                mCat(:,2)>=mGrid(i,3) & mCat(:,2)<mGrid(i,4));
        end
        % normalize values in mGrid_sum
        mGridNorm=mGrid_sum/max(mGrid_sum);
        mGrid(:,5)=mGridNorm;
end

