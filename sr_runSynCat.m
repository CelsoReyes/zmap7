zmap
close('Message Window')
close('ZMAP 6.0 - Menu')
% nohup matlab -nojvm -nodisplay -r sr_runSynCat > 070329PoissonN200.txt

clear vUsedNodes vResolution mValueGrid vResults mValueGridBkgr  vcsGridNames
N=1
for i=1:N

fFirst=logical(1);
while (fFirst || (size(mCatalog,1)>45000))
    fFirst=logical(0);
    [mCatalog, vMain] = calc_SynCat(10000,2.5,2.5,8,200,'January 1,1975','December 31,1990',10,2);
end
% [mCatalog1, vMain1] = calc_SynCat(3333,2.5,2.5,8,100,'January 1,1980','December 31,1985',6.5,1);
% [mCatalog2, vMain2] = calc_SynCat(1667,2.5,2.5,8,100,'January 1,1985','December 31,1990',6.5,1);
% mCatalog=[mCatalog1; mCatalog2];
% vMain=[vMain1; vMain2];
% mCatalog(:,3)=mCat(randperm(size(mCatalog,1))',3);
vcsGridNames_=[i sum(vMain) size(mCatalog,1) ];
% calculation rate for background seismicity
mCatalogTmp=mCatalog;
mCatalog=mCatalog(vMain,:);
save mCatalog.mat mCatalog -mat
sString=sprintf('save mCatBkgr%03.0f.mat mCatalog -mat',i);eval(sString);
sString=sprintf('save vMain%03.0f.mat vMain -mat',i);eval(sString);
params=sr_startZ(1);
vUsedNodesBkgr{i}=params.vUsedNodes;
vResolutionBkgr{i}=params.mValueGrid(:,7);
mValueGridBkgr(:,i)=params.mValueGrid(:,1);
mNumDeclusBkgr(:,i)=params.mNumDeclus;
vcsGridNames_=[vcsGridNames_ sum(params.mNumDeclus)];
sString=sprintf('End Synthetic Background Catalog No. %d',i);
disp(sString);


% calculation rate for background seismicity
mCatalog=mCatalogTmp;
mCatalog=mCatalog(vMain,:);
save mCatalog.mat mCatalog -mat
params=sr_startZ(2);
vUsedNodesBkgrDec{i}=params.vUsedNodes;
vResolutionBkgrDec{i}=params.mValueGrid(:,7);
mValueGridBkgrDec(:,i)=params.mValueGrid(:,1);
mNumDeclusBkgrDec(:,i)=params.mNumDeclus;
vcsGridNames_=[vcsGridNames_ sum(params.mNumDeclus)];
sString=sprintf('End Synthetic Background Catalog  No. %d, declustered',i);
disp(sString);

% calculation rate for background + ETAS seismicity
mCatalog=mCatalogTmp;
save mCatalog.mat mCatalog -mat
sString=sprintf('save mCatETAS%03.0f.mat mCatalog -mat',i);eval(sString);
params=sr_startZ(2);
vUsedNodes{i}=params.vUsedNodes;
vResolution{i}=params.mValueGrid(:,7);
mValueGrid(:,i)=params.mValueGrid(:,1);
vDeclus=params.mNumDeclus;
sString=sprintf('save vDeclus%03.0f.mat vDeclus -mat',i);eval(sString);
vcsGridNames_=[vcsGridNames_ sum(params.mNumDeclus)];
sString=sprintf('End  Synthetic Catalog No. %d',i);
disp(sString);

vcsGridNames(i,:)=vcsGridNames_;
end

params.vcsGridNames=cellstr(num2str(vcsGridNames));

params.sComment='Poissonian Background Rate';
vResults(1)=params;

vResults(1).vUsedNodes=vUsedNodesBkgr{1};
vResults(1).vResolution=vResolutionBkgr{1};
vResults(1).mValueGrid=mValueGridBkgr;
vResults(1).mNumDeclus=mNumDeclusBkgr;

params.sComment='Poissonian Background Rate / Declustered';
vResults(2)=params;

vResults(2).vUsedNodes=vUsedNodesBkgrDec{1};
vResults(2).vResolution=vResolutionBkgrDec{1};
vResults(2).mValueGrid=mValueGridBkgrDec;
vResults(1).mNumDeclus=mNumDeclusBkgrDec;

params.sComment='Poissonian Background Rate + ETES / Declustered';
vResults(3)=params;
vResults(3).vUsedNodes=vUsedNodes{1};
vResults(3).vResolution=vResolution{1};
vResults(3).mValueGrid=mValueGrid;



% clf
% subplot(1,2,1);
% plot(a(:,1),a(:,2),'.');
% subplot(1,2,2);
% plot(a(:,3),[1:1:sum(vMain)],'b');
% hold on;plot(mCatalog(:,3),[1:1:size(mCatalog,1)],'r');
% a=mCatalog;
% timeplot;
save 07061301-r1-n7500.mat vResults -mat
disp('Result saved in 07061301-r1-n7500.mat');
% exit
