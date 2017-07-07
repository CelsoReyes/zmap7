function [fXDiff, fYDiff] = gmt_pcolor(hHandle, sOutput, sPrefix)

mXData = get(hHandle, 'XData');
mYData = get(hHandle, 'YData');
mZData = get(hHandle, 'CData');

vY=repmat(mYData',length(mXData),1);
vX=repmat(mXData,length(mYData),1);
vX=reshape(vX,length(mYData)*length(mXData),1);
% vX1=vX(:,1);
% for nCol=2:1:length(mXData)
%     vX1=[vX1(:,1); vX(:,nCol)];
% end
% vX=vX1;

vZ = reshape(mZData, length(mYData)*length(mXData), 1);
% [nRow, nCol] = size(mXData);
% vX = reshape(mXData, nRow * nCol, 1);
% vY = reshape(mYData, nRow * nCol, 1);
% vZ = reshape(mZData, nRow * nCol, 1);

vXDiff = diff(vX);
vSel = ~(vXDiff == 0);
vXDiff = vXDiff(vSel,:);
fXDiff = min(abs(vXDiff));
vYDiff = diff(vY);
vSel = ~(vYDiff == 0);
vYDiff = vYDiff(vSel,:);
fYDiff = min(abs(vYDiff));

mXYZValues = [vX vY vZ];

save([sPrefix '_pcolor.dat'], 'mXYZValues', '-ascii');

hFile = fopen(sOutput, 'a');

fprintf(hFile, '# Grid the data\n');
fprintf(hFile, 'xyz2grd %s $area -G%s -I%s/%s\n', [sPrefix '_pcolor.dat'], [sPrefix '_pcolor.grd'], num2str(fXDiff), num2str(fYDiff));

fprintf(hFile, '# Plot the data\n');
fprintf(hFile, 'grdimage %s $default -C%s -Ts -O -K >> $output\n', [sPrefix '_pcolor.grd'], ['colormap.cpt']);

fprintf(hFile, '# Delete the temporary file\n');
fprintf(hFile, ['rm ' sPrefix '_pcolor.grd\n']);

% hAxes = get(hHandle, 'Parent');
% vCLim = get(hAxes, 'CLim');
% mColormap = colormap(hAxes);
% [nRow, nCol] = size(mColormap);
% fRange = vCLim(2)-vCLim(1);
% fStep = fRange/(nRow-1);
%
% mMap = [];
% for nCnt = 1:nRow-1
%   mMap = [mMap; (vCLim(1)+((nCnt-1)*fStep)) mColormap(nCnt,:).*255 (vCLim(1)+(nCnt*fStep)) mColormap(nCnt+1,:).*255];
% end
%
% save([sPrefix '_pcolor.cpt'], 'mMap', '-ascii');
%
%
% fprintf(hFile, 'psscale -D6.3i/1.35i/3i/0.3i -C%s -O -K >> $output\n', [sPrefix '_pcolor.cpt']);

fclose(hFile);
