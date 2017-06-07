function gmt_Colormap_ConvertPovRayToGMT(sPovRayFile, sGMTFile, fMin, fMax, bFlip)

mMatlabColormap = gui_Colormap_ReadPovRay(sPovRayFile, 256);
if exist('bFlip', 'var')
  if bFlip
    mMatlabColormap = flipud(mMatlabColormap);
  end
end
nRow = length(mMatlabColormap(:,1));
fDiff = fMax - fMin;
vMinRow = fMin:(fDiff/nRow):(fMax-(fDiff/nRow));
vMaxRow = (fMin+(fDiff/nRow)):(fDiff/nRow):fMax;
mGMTColormap = [vMinRow' mMatlabColormap.*255 vMaxRow' mMatlabColormap.*255];
save(sGMTFile, 'mGMTColormap', '-ascii');
