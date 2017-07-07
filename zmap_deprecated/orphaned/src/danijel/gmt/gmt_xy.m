function gmt_xy(hLine, sOutput, sPrefix)

% Get attributes
sLineStyle = lower(get(hLine, 'LineStyle'));
sMarker = get(hLine, 'Marker');

if ~((strcmp(sLineStyle, 'none'))  &&  (strcmp(sMarker, 'none')))

  % Get data
  mXData = get(hLine, 'XData');
  mYData = get(hLine, 'YData');

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
  save([sPrefix '_xy.tmp'], 'mXYValues', '-ascii');



  hFile = fopen(sOutput, 'a');
  fprintf(hFile, '# Plot xy\n');

  unix(['sed -f xy.sed ' sPrefix '_xy.tmp > ' sPrefix '_xy.dat']);
  unix(['rm -f ' sPrefix '_xy.tmp']);

  % Get attributes
  sLineStyle = lower(get(hLine, 'LineStyle'));
  fLineWidth = get(hLine, 'LineWidth');
  sMarker = get(hLine, 'Marker');
  fMarkerSize = get(hLine, 'MarkerSize');
  vColor = get(hLine, 'Color');

  if ~strcmp(sLineStyle, 'none')
    sS = '';
    sW = sprintf('-W%s/%s/%s/%s ', num2str(fLineWidth), num2str(vColor(1)*255), num2str(vColor(2)*255), num2str(vColor(3)*255));
    sM = '-M ';
    fprintf(hFile, 'psxy %s $default %s %s %s -O -K >> $output\n', [sPrefix '_xy.dat'], sW, sM, sS);
  end
  if ~strcmp(sMarker, 'none')
    switch sMarker
    case '^',         % triangle upwards
      sSymbol = 't';
    case '.',         % point
      sSymbol = 'p';
    case 'hexagram',  % hexagram
      sSymbol = 'a';
    case 'o',         % circle
      sSymbol = 'c';
    case 'square',    % square
      sSymbol = 's';
    case 'x',         % cross
      sSymbol = 'x';
    case '*',         % asterix
      sSymbol = 'a';
    otherwise         % point as default
      sSymbol = 'p';
    end
    vEdgeColor = get(hLine, 'MarkerEdgeColor');
    if strcmp(vEdgeColor, 'auto')
      vEdgeColor = get(hLine, 'Color');
    end
    vFaceColor = get(hLine, 'MarkerFaceColor');
    if ~strcmp(vFaceColor, 'none')
      sG = sprintf('-G%s/%s/%s ', num2str(vFaceColor(1)*255), num2str(vFaceColor(2)*255), num2str(vFaceColor(3)*255));
    else
      sG = '';
    end
    sS = ['-S' sSymbol num2str(fMarkerSize) 'p ']

    sW = sprintf('-W%s/%s/%s/%s ', num2str(fLineWidth), num2str(vEdgeColor(1)*255), num2str(vEdgeColor(2)*255), num2str(vEdgeColor(3)*255));
    fprintf(hFile, 'psxy %s $default %s %s %s -O -K >> $output\n', [sPrefix '_xy.dat'], sW, sG, sS);
  end
  fclose(hFile);
end
