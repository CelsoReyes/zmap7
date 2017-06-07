function gmt_done(sOutput)

hFile = fopen(sOutput, 'a');

fprintf(hFile, '# Last command clips the figure\n');
fprintf(hFile, 'psclip -C -O >> $output\n');

fclose(hFile);

% Remove sed-filter
unix(['rm -f xy.sed']);


