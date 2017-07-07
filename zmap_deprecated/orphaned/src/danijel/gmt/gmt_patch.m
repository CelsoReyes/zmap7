function gmt_patch(hPatch, sOutput, sPrefix)

% Get data
mXData = get(hPatch, 'XData');
mYData = get(hPatch, 'YData');

% Transform data and save it
[nRow, nCnt] = size(mXData);
if nRow == 1
  mXData = mXData';
end
[nRow, nCnt] = size(mYData);
if nRow == 1
  mYData = mYData';
end
mXYValues = [mXData mYData];
save([sPrefix '_patch.dat'], 'mXYValues', '-ascii');

% Get attributes
vEdgeColor = get(hPatch, 'EdgeColor');
vFaceColor = get(hPatch, 'FaceColor');
fLineWidth = get(hPatch, 'LineWidth');

% Write GMT
hFile = fopen(sOutput, 'a');
fprintf(hFile, '# Plot patch\n');
sG = sprintf('-G%s/%s/%s', num2str(round(vFaceColor(1)*255)), num2str(round(vFaceColor(2)*255)), num2str(round(vFaceColor(3)*255)));
sW = sprintf('-W%s/%s/%s/%s', num2str(fLineWidth), num2str(vEdgeColor(1)*255), num2str(vEdgeColor(2)*255), num2str(vEdgeColor(3)*255));
fprintf(hFile, 'psxy %s $default %s %s -O -K >> $output\n', [sPrefix '_patch.dat'], sW, sG);
fclose(hFile);
