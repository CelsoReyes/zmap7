function [mSynCat] = create_syncat(mCatalog,nCdf,fMu,fSigma, fMinMagIn,bPlot)
% function [mSynCat] = create_syncat(mCatalog,nCdf,fMu,fSigma,fMinMagIn,bPlot);
% --------------------------------------------------
% Creates a synthetic catalog for the part below Mc with a Normal CDF.
% Usage:
% Before using this function, create a defined synthetic catalog according
% to a power-law behavior. It's assumed that the smallest magnitude bin is
% the bin of the magnitude of completeness. If fMu, fSigma and fMinMagIn are
% missing, enter interactively.
%
% Incoming variable:
% mCatalog : EQ catalog
% nCdf : Choice of cumulative distribution function
%        1 : Normal cumulative distribution function
%        2 : Lognormal cumulative distribution function
%        3 : Weibull CDF
%
% fMu    : Mu of Normal / Lognormal CDF
% fSigma : Sigma of Normal / Lognormal CDF
% fMinMagIn : Minimum magnitude for synthetic catalog
% bPlot : Plot historgram, 0 =no plot, 1 = plot
% Output:
% mSynCat : Synthetic catalog
% mCat : Catalog of events below Mc
%
% Authour: J. Woessner, j.woessner@sed.ethz.ch
% last update: 10.07.04

% Initialize
mCat = [];

if ~exist('bPlot','var')
    bPlot = 0;
end

% Check for input values
if nargin < 3
    % Calculate probablities for Normal CDF
    prompt = {'Enter mu:','Enter sigma:','Minimum magnitude:'};
    dlg_title = 'Parameters for normal CDF';
    num_lines= 1;
    def     = {'0.8','0.4','0'};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    fMu = str2double(answer(1));
    fSigma = str2double(answer(2));
    fMinMagIn = str2double(answer(3));
end

% Calculate FMD
[mFMDC, mFMD] = calc_FMD(mCatalog);

% Find first bin (Mc bin) with data
vSel = (max(mFMD(2,:)) == mFMD(2,:));
fN_Mc = mFMD(2,vSel);

fMinBin = mFMD(1,vSel);
vMagstep = fMinMagIn:0.1:fMinBin-0.1;

% Choose CDF
switch nCdf
    case 1
        vProb = normcdf(vMagstep,fMu, fSigma);
    case 2
        vProb = logncdf(vMagstep,fMu,fSigma);
    case 3
        vProb = wblcdf(vMagstep,fMu,fSigma);
    otherwise
        disp('Check nCdf parameter!');
        return;
end

vProb = vProb';
vMagstep = vMagstep';

% Calculate number of EQs in bins
vN = round(vProb(:,1)*fN_Mc);
mData = [vMagstep vN];
vMag = [];
nCount=1;
for nMag=fMinMagIn:0.1:fMinBin-0.1
    %fM = repmat(nMag,mData(floor(abs(nMag)*10+1),2),1);
    fM = repmat(nMag,mData(nCount,2),1);
    vMag = [vMag; fM];
    nCount=nCount+1;
end

% Choose appropriate number of events from the catalog, change magnitudes
% and add to original catalog
vInd = round(rand(length(vMag),1)*length(mCatalog(:,1)));
% Avoid zeros
vIndice = find(vInd == 0);
vInd(vIndice) = vInd(vIndice)+1;

for n=1:length(vInd)
    mCat = [mCat; mCatalog(vInd(n),:)];
end
%mCat = mCatalog(vSel,:);
%mCat = mCatalog(1:length(vMag),:);
mCat(:,6) = vMag;
mSynCat = [mCat;mCatalog];

if (exist('bPlot','var') & bPlot == 1)
    %Plot result
    fMaxMag = max(mCatalog(:,6));
    figure_w_normalized_uicontrolunits('tag','maghist');
    histogram(mSynCat(:,6),fMinMagIn:0.1:fMaxMag);
    xlabel('Magnitude');
    ylabel('Frequency');
end
