function gmt_scale(hAxes, sOutput, sPrefix)

% Get the figure-handle
hFigure = get(hAxes, 'Parent');

% Is there a colorbar?
vKids = get(hFigure, 'Children');
for nCnt = length(vKids):-1:1
  sType = get(vKids(nCnt), 'Type');
  sTag = get(vKids(nCnt), 'Tag');
  if (strcmp(sType, 'axes') & strcmp(sTag, 'Colorbar'))
    vUserData = get(vKids(nCnt), 'UserData');
    if vUserData.PlotHandle == hAxes

    % Extract the colormap
     vCLim = get(hAxes, 'CLim');
     mColormap = colormap(hAxes);
     [nRow, nCol] = size(mColormap);
     fRange = vCLim(2)-vCLim(1);
     fStep = fRange/(nRow-1);

     % Create the cpt-file and save it
     mMap = [];
     for nRowCnt = 1:nRow-1
       mMap = [mMap; (vCLim(1)+((nRowCnt-1)*fStep)) mColormap(nRowCnt,:).*255 (vCLim(1)+(nRowCnt*fStep)) mColormap(nRowCnt+1,:).*255];
     end
     save([sPrefix 'colormap.cpt'], 'mMap', '-ascii');

    % Get properties of colorbar
    vXTick = get(vKids(nCnt), 'XTick');
    vYTick = get(vKids(nCnt), 'YTick');
    if isempty(vXTick)
      % Colorbar is vertical
      sD = '';
  vYDiff = diff(vYTick);
 vSel = ~(vYDiff == 0);
 vYDiff = vYDiff(:,vSel);
 fYDiff = min(abs(vYDiff));
     sB = num2str(fYDiff);
    else
      % Colorbar is horizontal
      sD = 'h';
     vXDiff = diff(vXTick);
    vSel = ~(vXDiff == 0);
    vXDiff = vXDiff(:,vSel);
    fXDiff = min(abs(vXDiff));
     sB = num2str(fXDiff);
    end
%

    %get(vKids(nCnt))

    % Plot the colorbar
hFile = fopen(sOutput, 'a');
    fprintf(hFile, 'psscale -D6.3i/1.35i/3i/0.3i%s -C%s -B%s -O -K >> $output\n', sD, [sPrefix 'colormap.cpt'], sB);

fclose(hFile);

end
  end
end





