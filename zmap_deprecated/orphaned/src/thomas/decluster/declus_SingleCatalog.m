function declus_SingleCatalog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Example: mDeclusIndex=declus_SingleCatalog
%
% This function to calculate declustering probabilities
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author:
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
%
% Created on 02.07.2008
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initialize
disp('~/zmap/src/thomas/decluster/declus_SingleCatalog');

% load catalog to work with (can also be selected later
load anss-1981-19923-M15-Wiemer1994.mat
% load '~/zmap/eq_data/lsh_1.12/lsh1.12WiemerWyss1994.mat';
%  output filename
sFilename='mDeclus08072800.mat';

if ~exist('mCatalog')
  mCatalog=a;
  clear a;
end
bHypo=true;
bMag=true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nMCS=2;            % number of simulation for hypocenter and/or magnitude and/or declustering

nDeclusMode=2;   % Applied declustering algorithm
% 1: Reasenberg Matlab
% 2: Gardner Knopoff
% 3: Stochastic
% 4: Reasenberg Cluster2000 (fortran)
% 5: Marsan
% 6: cluster GK written by Annemarie
% 7: cluster Uhrhammer written by Annemarie
% 8: cluster Utsu written by Annemarie


% parameter range for reasenberg declustering (nDeclusMode=4)
% Taumin, Taumax, P1, Xk, Xmeff, Rfact, Err, Derr
    mReasenParam=[[1 1];[10 10];[0.95 0.95];[0.5 0.5];...
        [1.6 1.6];[10 10];[2 2];[4 4]];
% mReasenParam=[[0.5 2.5];[03 15];[0.90 0.99];[0.0 1.0];...
%    [1.6 1.8];[05 20];[2 2];[4 4]];

fMc=3.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preallocate matrices
mCatalog=mCatalog(mCatalog(:,3)<1992.3,:);
mNumDeclus=zeros(size(mCatalog,1),nMCS);
mDeclusLon=nan(size(mCatalog,1),nMCS);
mDeclusLat=nan(size(mCatalog,1),nMCS);
mDeclusDepth=nan(size(mCatalog,1),nMCS);
mDeclusMag=nan(size(mCatalog,1),nMCS);

nMCS
for i=1:nMCS
    mCat=mCatalog;
    %% include hypocenter uncertainties
    if bHypo
%         mHypo=[2 2 5];mDelta=repmat(mHypo,size(mCatalog,1),1);
        mDelta=[mCat(:,11) mCat(:,11) mCat(:,12)];
        [mCat]=calc_hyposhift(mCat,mDelta,true);
    end

    %% include magnitude uncertainties
    if bMag
%         mMag=[0.1];mDeltaMag=repmat(mMag,size(mCatalog,1),1);
        mDeltaMag=mCat(:,13);
        [mCat]=calc_magerr(mCat,mDeltaMag);
    end

    %% cut catalog
    vSel=(mCat(:,6)>fMc);
%     mCat=mCat{i}(vSel{i},:)
    [declusCat, mNumDeclus(vSel,i)] = MonteDeclus(mCat(vSel,:),...
        1,nDeclusMode,mReasenParam);
    % save results of i-th simulation in matrices
    if bHypo
%         mNumDeclus(isnan(mNumDeclus(~vSel,i)),i)=0;
        mDeclusLon(logical(mNumDeclus(:,i)),i)=declusCat(:,1);
        mDeclusLat(logical(mNumDeclus(:,i)),i)=declusCat(:,2);
        mDeclusDepth(logical(mNumDeclus(:,i)),i)=declusCat(:,7);
    end
    if bMag
%         mNumDeclus(isnan(mNumDeclus(vSel,i)),i)=0;
        mDeclusMag(logical(mNumDeclus(:,i)),i)=declusCat(:,6);
    end
    disp(i);
end
mDeclusIndex=sum(mNumDeclus,2)./nMCS;
clear params vSel declusCat mCat  mDelta mDeltaMag ans i sString


sString=sprintf('save %s * -mat',sFilename);
eval(sString);
disp(sString);
