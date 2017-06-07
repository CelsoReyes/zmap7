function [fMshift, fStdMshift, fMshift1] = calc_MagshiftStat(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC)
% function [fMshift] = calc_MagshiftStat(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC);
% ------------------------------------------------------------------------------------
% Function to calculate simple magnitude shift between two time periods using the
% procedure proposed by Zuniga & Wyss, BSSA, Vol.85, No.6, 1858-1866, 1995
% Mnew = Mold + fMshift
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% bTimePeriod   : Use catalog from beginning to end (0), use time periods (1)
% fSplitTime   : Splittime of catalog
% fTimePeriod  : Time periods
% nCalculateMC : Method to determine Mc (1-5 see help calc_Mc)
%
% Outgoing variable:
% fMshift : magnitude shift
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 10.07.02

[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
       result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);

% Create the frequency magnitude distribution vectors for the two time periods
[vFMD, vNonCFMD] = calc_FMDMag(mFirstCatalog(:,6));
[vFMDSecond, vNonCFMDSecond] = calc_FMDMag(mSecondCatalog(:,6));

% Calculate magnitude of completeness
fMc = calc_Mc(mFirstCatalog, nCalculateMC);
fMcSecond = calc_Mc(mSecondCatalog, nCalculateMC);

if (~isempty(fMc) & ~isempty(fMcSecond))
    % First period
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD, fMc);
    % Calculate the b-value etc. for M > Mc
    [fMeanMag, fBValue, fStdDev, fAValue] =  bmemag(mFirstCatalog(vSel,:));
    vPoly = [-1*fBValue fAValue];
    fBFunc = 10.^(polyval(vPoly, vMagnitudes));
    %% Second period
    [nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mSecondCatalog, vFMDSecond, fMcSecond);
    % Calculate the b-value etc. for M > Mc
    [fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] =  calc_bmemagMag(mSecondCatalog(vSelSecond,:));
    vPolySecond = [-1*fBValueSecond fAValueSecond];
    fBFuncSecond = 10.^(polyval(vPolySecond, vMagnitudesSecond));
    % Determine magnitude shift
    fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
    fMshift1 = fMintercept - vFMD(1,nIndexLo);
else
    disp('fMcSecond or fMc not derivable');
    fMshift=NaN;
end

%%% Bootstrap %%%%
[mbootSecondCatalog] = bootrsp(mSecondCatalog(:,6),200);
for nBstCatalog = 1:200
    mTmpCatalog = mbootSecondCatalog(nBstCatalog);
    [vFMDSecond, vNonCFMDSecond] = calc_FMDMag(mTmpCatalog);
    fMcSecond(nBstCatalog) = calc_McMag(mTmpCatalog,nCalculateMC);
    [nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mTmpCatalog, vFMDSecond, fMcSecond(nBstCatalog));
    [fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] =  calc_bmemagMag(mTmpCatalog(vSelSecond));
    vPolySecond = [-1*fBValueSecond fAValueSecond];
    fBFuncSecond = 10.^(polyval(vPolySecond, vMagnitudesSecond));
    fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
    fMshift(nBstCatalog) = fMintercept - vFMD(1,nIndexLo);
end
figure_w_normalized_uicontrolunits(300);
histogram(fMshift,20);
fStdMshift = std(fMshift);
