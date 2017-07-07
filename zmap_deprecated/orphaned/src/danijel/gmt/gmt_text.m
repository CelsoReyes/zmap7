function gmt_text(hText, sOutput, sPrefix)

% Get text properties
vPosition = get(hText, 'Position');
sString = get(hText, 'String');
fFontSize = get(hText, 'FontSize');
sFontUnits = get(hText, 'FontUnits');

% Write data-file
hFile = fopen([sPrefix '_text.dat'], 'w');
fprintf(hFile, '%f %f %f 0 0 LB %s\n', vPosition(1), vPosition(2), fFontSize, sString);
fclose(hFile);

% Append pstext command
hFile = fopen(sOutput, 'a');
fprintf(hFile, 'pstext %s $default -O -K >> $output\n', [sPrefix '_text.dat']);
fclose(hFile);


