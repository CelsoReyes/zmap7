function [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc)
%function [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagtoFitBValue(mCatalog, vFMD, fMc);
%-------------------------------------------------------------------------------------
%
% Determine logical selection vector for a selection of magnitudes above Mc. Use before
% fitting b-value
% Incoming variables:
% mCatalog: earthquake catalogue
% vFMD    : cumulative frequency magnitude distribution
% fMc     : magnitude of completeness
%
% Outgoing variables:
% nIndexLo   : Index of magnitude at which straight line fit breaks off
% fMagHi     : Highest magnitude
% vSel       : Selection vector
% vMagnitude : Magnitudes accordsing to selection vector
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 17.07.02

nIndexLo = find((vFMD(1,:) < fMc + 0.05) & (vFMD(1,:) > fMc - 0.05));
fMagHi = vFMD(1,1);
vSel = vFMD(1,:) <= fMagHi & vFMD(1,:) >= fMc-.0001;
vMagnitudes = vFMD(1,vSel);

[nXSize, nYSize] = size(mCatalog);
% Selectoin of magnitudes M>Mc to calculate b-value
if nXSize > 1
    vSel = mCatalog(:,6) >= fMc-0.05;
else
    vSel = mCatalog(:,1) >= fMc-0.05;
end
return
