function gmt_colorscale(hAxes, sOutput, fFacScale)
% function gmt_colorscale(hAxes, sOutput,fFacScale);
% --------------------------------------------
% Create gmt *.cpt file from Matlab colorscale
%
% Incoming:
% hAxes   : axis handle
% sOutput : Output string for sOutput.cps
% fFacScale : Scale factor for colorscale, default= 1

% jowoe@gps.caltech.edu

% Scaling factor if range is not 0 - 1
if nargin < 3
    fFacScale = 1;
end

% Extract the colormap
vCLim = get(hAxes, 'CLim');
mColormap = colormap(hAxes);
[nRow, nCol] = size(mColormap);
fRange = vCLim(2)-vCLim(1);
fStep = fRange/(nRow-1);

% Create the cpt-file and save it
mMap = [];
for nRowCnt = 1:nRow-1
    mMap = [mMap; (vCLim(1)+((nRowCnt-1)*fStep))*fFacScale mColormap(nRowCnt,:).*255 (vCLim(1)+(nRowCnt*fStep))*fFacScale mColormap(nRowCnt+1,:).*255];
end
save([sOutput '.cpt'], 'mMap', '-ascii');

