function [mCat, mCatSmStdr] = calc_fpfitqual(mCatalog, fSm, fStdr, fUncertMin, fUncertMax)
% [mCat, mCatSmStdr] = calc_fpfitqual(mCatalog,fSm, fStdr, fUncertMin, fUncertMax)
% --------------------------------------------------------------------------------
% Create quality restricted catalog using quality parameters from FPFIT
% Reference: Oppenheimer & Reasenberg, Open-File Report 85-739, 1985
% Based on catalogs imported using ncedc_fomech_imp.m
%
% Input variables
% mCatalog   : Focal meachnism catalog
% fSm        : Maximum solution misfit
% fStdr      : Minimum station distribution ratio
% fUncertMin : Min uncertainty for strike (dip direction), rake, dip
% fUncertMax : Max uncertainty for strike (dip direction), rake, dip
%
% Output:
% mCat       : Quality catalog selected according to the input
% mCatSmStdr : Quality only selected for Stdr and SM
%
% J. Woessner, 04.2004

% Selection of solution misfit and station distribution ratio
vSel = (mCatalog(:,15) >= fStdr & mCatalog(:,13) <= fSm);
mCatSmStdr = mCatalog(vSel,:);

% Selection using the uncertainties for strike, dip and slip
vSel = (mCatSmStdr(:,17) >= fUncertMin & mCatSmStdr(:,17) < fUncertMax & mCatSmStdr(:,18) >= fUncertMin & mCatSmStdr(:,18) < fUncertMax & mCatSmStdr(:,19) >= fUncertMin & mCatSmStdr(:,19) < fUncertMax);
mCat = mCatSmStdr(vSel,:);
