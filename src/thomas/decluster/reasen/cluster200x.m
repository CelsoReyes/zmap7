function [vM, vM_]=cluster200x(fTaumin, fTaumax, fXk, fXmeff, fP1, fRfact, fMerr, fZerr,mCat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: [vMain, vClus]=cluster200x(2880,14400,0.5,3.0,0.99,10,0,0,a)
% Author: van Stiphout, Thomas
% Email: vanstiphout@sed.ethz.ch
% Created: 14. Feb. 2007
% Changed: -
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables:
% mCat              Catalog to be declustered
% iYr1                Starting year (read from mCat)
% iYr2                Ending year (read from mCat)
% fXmeff            Magnitude cutoff
% fRfact             rfact
% fTau0              Tau0 (is equal fTaumin)
% fTaumin          Taumin
% fTaumax         Taumax
% fP1                  P1
% fXk                  xk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prevent year 2000 problem / transition
fYrStart_=floor(min(mCat(:,3)));
mCatTime_=mCat(:,3);
mCat(:,3)=mCat(:,3)-fYrStart_;
% prepare variables
fTaumin=fTaumin*24*60;
fTau0=fTaumin;
fTaumax=fTaumax*24*60;
sYr1=num2str(floor(min(mCat(:,3))));
sYr2=num2str(ceil(max(mCat(:,3))));
% sYr1=sYr1(3:4);
% sYr2=sYr2(3:4);

% does catalog contain 12 columns?
if (size(mCat,2)<12)
    mTmp=ones(size(mCat,1),(12-size(mCat,2)))*NaN;
    mCat=[mCat mTmp];
end
!rm tmp cluster.* input.cmn tmp v.dat CA.hypo71
% export to readalbe format for tmp
export2hypo71(mCat,'tmp');
% remove NaN from exported catalog
unix(['sed ''s/NaN/   /'' tmp > CA.hypo71']);
% write input file (input.cmn)
in=fopen('input.cmn','w');
fprintf(in,'CA.hypo71\n4\n%2s\n%2s\n%3.1f\n%06.3f\n%08.3f\n%010.2f\n%010.2f\n%05.2f\n%05.2f',...
    sYr1,sYr2,fXmeff,fRfact,fTau0,fTaumin,fTaumax,fP1,fXk);
fclose(in);
% run declustering algorithm of f reasenberg cluster200x
unix('~/zmap/src/thomas/decluster/reasen/cluster200x > tmp');
% extract vector with 1 and 0's of events in declustered catalog
unix(['awk -f ~/zmap/src/thomas/decluster/reasen/clu2list.awk cluster.ano > v.dat ' ]);
% import vector
vM_=load('v.dat');
vSelN0=(vM_==0);
vSelNc=zeros(size(vSelN0));

for i=1:max(vM_)
    vPos1=find(vM_==i);
    if ~isempty(vPos1)
        vPos2=find(mCat(vPos1,6)==max(mCat(vPos1,6)));
        if (vPos2==1)
            vPos3=vPos1(vPos2);
        else
            vPos3=vPos1(1);
        end
        vSelNc(vPos3)=1;
    end
    clear vPos1 vPos2 vPos3
end

vM=(logical(vSelN0) | logical(vSelNc));
% % clean up
% !rm cluster.*
