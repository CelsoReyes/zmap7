function gmt_catalogexport(mCatalog, fMagfac)
% function gmt_catalogexport(mCatalog, fMagfac)
% -----------------------------
% Exports ZMAP formatted catalog to 3 column ascii-file that can be read into GMT
%
%
% Input variable:
% mCatalog   : EQ catalog ZMAP formatted
% fMagfac    : Multiplication factor for sizing in gmt-plot
%
% Output     : EQ data
%              Lon Lat Magnitude
%
% J. Woessner
% last update: 25.08.03

if nargin < 2
    fMagfac =1;
    disp('Magnitudes not scaled!')
end

% Read lat lon
mCat = [mCatalog(:,1) mCatalog(:,2) mCatalog(:,6)*fMagfac];
mCat = mCat';

% Get filename
prompt  = {'Enter output filename:'};
title   = 'Output filename';
lines= 1;
def     = {'Catname.dat'};
answer  = inputdlg(prompt,title,lines,def);
sCatname = char(answer(1));

fid = fopen(sCatname,'w');
fprintf(fid,'%7.4f %7.4f %4.2f\n',mCat);
fclose(fid)
