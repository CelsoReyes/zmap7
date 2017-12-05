function [vSel, vM]=misd(mCat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: vMain=misd(mCat)
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
% fTaumax          Taumax
% fP1                  P1
% fXk                  xk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prepare variables
% fTaumin=fTaumin*24*60;
% fTau0=fTaumin;
% fTaumax=fTaumax*24*60;
% sYr1=num2str(floor(min(mCat(:,3))));
% sYr2=num2str(ceil(max(mCat(:,3))));
% sYr1=sYr1(3:4);
% sYr2=sYr2(3:4);
%
% % does catalog contain 12 columns?
% if (size(mCat,2)<12)
%     mTmp=nan(size(mCat,1),(12-size(mCat,2)));
%     mCat=[mCat mTmp];
% end
!rm ~/zmap/src/thomas/decluster/marsan/*.out
!rm ~/zmap/src/thomas/decluster/marsan/misd_input.dat
!rm ~/zmap/src/thomas/decluster/marsan/CORRECT.DAT
% !rm ~/zmap/src/thomas/decluster/marsan/misdMcorr.dat
% export to readalbe format for tmp
export4misd(mCat,'misd_input.dat');
!mv misd_input.dat  ~/zmap/src/thomas/decluster/marsan/.
calc_misdMcorr(mCat,'CORRECT.DAT');
!mv CORRECT.DAT  ~/zmap/src/thomas/decluster/marsan/.
% calc_misdMcorr(mCat,'misdMcorr.dat');
% !mv misdMcorr.dat  ~/zmap/src/thomas/decluster/marsan/.
% save ~/zmap/src/thomas/decluster/marsan/misd_input.dat mCat -ascii

% write input file (input.cmn)
% infile=fopen('input.cmn','w');
% fprintf(infile,'CA.hypo71\n4\n%2s\n%2s\n%3.1f\n%06.3f\n%08.3f\n%010.2f\n%010.2f\n%05.2f\n%05.2f',...
%     sYr1,sYr2,fXmeff,fRfact,fTau0,fTaumin,fTaumax,fP1,fXk);
% fclose(infile);
% run misd algorithm of Marsan2007
sPath=pwd;
cd ~/zmap/src/thomas/decluster/marsan
tic
unix('./misd inputmisd.in');
toc
cd(sPath); % was: eval(sprintf('cd %s',sPath));
% extract vector with 1 and 0's of events in declustered catalog
% unix(['awk -f ~/zmap/src/thomas/decluster/reasen/clu2list.awk cluster.ano > v.dat ' ]);
% import vector
vM=load('~/zmap/src/thomas/decluster/marsan/W0.out');
vSel=(vM>rand(size(vM,1),1));
% % clean up
% !rm cluster.*
