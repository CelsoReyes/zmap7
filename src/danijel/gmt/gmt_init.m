function [vXLim, vYLim] = gmt_init(hAxes, sOutput)

hFile = fopen(sOutput, 'w');

% Write script header
fprintf(hFile, '#!/usr/bin/tcsh\n\n');
fprintf(hFile, '# Automatically generated GMT script\n');
fprintf(hFile, '# License: GPL\n');
fprintf(hFile, '# Author: Danijel Schorlemmer, Swiss Seismological Service, ETH Zuerich\n\n');

% Write filenames
fprintf(hFile, '# Set filenames\n');
fprintf(hFile, 'set output = "map.eps"\n\n');

% Get Limits
vXLim = get(hAxes, 'XLim');
vYLim = get(hAxes, 'YLim');

% Get ticks
vXTick = get(hAxes, 'XTick');
vXDiff = diff(vXTick);
vSel = ~(vXDiff == 0);
vXDiff = vXDiff(:,vSel);
fXDiff = min(abs(vXDiff));
vYTick = get(hAxes, 'YTick');
vYDiff = diff(vYTick);
vSel = ~(vYDiff == 0);
vYDiff = vYDiff(:,vSel);
fYDiff = min(abs(vYDiff));

% Create script-defaults
fprintf(hFile, '# Set defaults\n');
sRLine = sprintf('set area = "-R%s/%s/%s/%s"', num2str(vXLim(1)), num2str(vXLim(2)), num2str(vYLim(1)), num2str(vYLim(2)));
fprintf(hFile, '%s\n', sRLine);
fprintf(hFile, 'set default = "-V $area -JM6i -Bf%f/f%fWeSn"\n\n', fXDiff, fYDiff);
fprintf(hFile, '# Plot the data\n');
fprintf(hFile, 'psbasemap $default -P -K >! $output\n\n');
fclose(hFile);

% Create sed-filter for xy-plots (sed -f xy.sed input > output)
hFile = fopen('xy.sed', 'w');
fprintf(hFile, 's/^ *NaN/> /\ns/^ *Inf/> /\ns/^ *-Inf/> /\n');
fclose(hFile);


