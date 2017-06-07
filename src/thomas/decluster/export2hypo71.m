function export2hypo71(mCat,sOutputFile)
% function export2hypo71(a,sOutputFile)
% EXAMPLE: export2hypo71(a,'Catalog.dat')
%
% Author: van Stiphout, Thomas
% vanstiphout@sed.ethz.ch
%
% Created: 09. Feb 2007
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SUMMARY HYPO71 FORMAT YEAR 2000
% ------- ------ ------ ---- ----
% C--HYPO71-2000 FORMAT
%   104 read (3, 2010, err= 900, END=35) icent,itime,lat1,ins,xlat1,
%      1                     lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1
%  2010 format (4i2,1x,2i2,6x,i3,a1,f5.2,i4,a1,f5.2,
%      1        f7.2,2x,f5.2,17x,2f5.1,1x,a1)

hypo71=fopen(sOutputFile,'w');
for nCnt=1:size(mCat,1)
    nCnt;
    % prepare lat lon with min and N/S or E/W sign.
     if (mCat(nCnt,2) < 0)  cns='S'; else cns='N'; end
     if (mCat(nCnt,1) < 0) cew='W'; else cew='E'; end
     londeg=floor(abs(mCat(nCnt,1)));
     latdeg=floor(abs(mCat(nCnt,2)));
     lonmin=(abs(mCat(nCnt,1))-floor(abs(mCat(nCnt,1))))*60;
     latmin=(abs(mCat(nCnt,2))-floor(abs(mCat(nCnt,2))))*60;

    fprintf(hypo71,'%4.0f%02.0f%02.0f %02.0f%02.0f%6.2f%3d%1s%05.2f%4d%1s%05.2f%7.2f  %5.2f%22.1f%5.1f %1s\n',...
        floor(mCat(nCnt,3)), mCat(nCnt,4),mCat(nCnt,5),mCat(nCnt,8),...
        mCat(nCnt,9),mCat(nCnt,10),latdeg,cns,latmin,londeg,cew,...
        lonmin,mCat(nCnt,7),mCat(nCnt,6),' ',mCat(nCnt,12),'  ');
end
fclose(hypo71);


