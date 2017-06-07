function export4misd(mCat,sOutputFile)
% function export4mid(mCatalog,'Catalog.dat')
%
% Author: van Stiphout, Thomas
% vanstiphout@sed.ethz.ch
%
% Created:  Oct, 17 2007
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fYrStart=floor(min(mCat(:,3)));
misd=fopen(sOutputFile,'w');
for nCnt=1:size(mCat,1)
    fprintf(misd,'%12.7f %3.1f %08.4f %09.4f \n',...
        (mCat(nCnt,3)-fYrStart)*365,mCat(nCnt,6), mCat(nCnt,2),mCat(nCnt,1));
end
fclose(misd);


