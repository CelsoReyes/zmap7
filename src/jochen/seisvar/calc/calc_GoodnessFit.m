function [fPerMc, res2] = calc_GoodnessFit(mCatalog, fMc, fBinning)
% function [fPerMc, res2] = calc_FitComp(mCatalog, fMc, fBinning);
% -----------------------------------------------------------------------------
%
% Function to calculate  Goodness of fit percentage of a fitted to observed
% magnitude frequency distribution
%
% Incoming variables:
% mCatalog
% fMc
% fBinning
%
% Outgoing variables:
% fPerMc : Percentage of fit
% res2   : Result
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 23.01.03


vSel = mCatalog(:,6) > (fMc - (fBinning/2));
nNumberEvents = length(mCatalog(vSel,6));
if nNumberEvents >= 25
    [fDummy fBValue fDummy,  fDummy] =  bmemag(mCatalog(vSel,:));

    fStartMag = fMc; % Starting magnitude (hypothetical Mc)

    % log10(N)=A-B*M
    vMag = [fStartMag:fBinning:10]; % Ending magnitude must be sufficiently high
    vNumber = 10.^(log10(nNumberEvents)-fBValue*(vMag - fStartMag));
    vNumber = round(vNumber);

    % Find the last bin with an event
    nLastEventBin = min(find(vNumber == 0)) - 1;
    if isempty(nLastEventBin)
        nLastEventBin = length(vNumber);
    end
    % Determine set of all magnitude bins with number of events > 0
    ct = round((vMag(nLastEventBin)-fStartMag)*(1/fBinning) + 1);

    PM=vMag(1:ct);
    vNumber = vNumber(1:ct);
    [bval, vDummy] = hist(mCatalog(vSel,6),PM);
    b3 = fliplr(cumsum(fliplr(bval)));    % N for M >= (counted backwards)
    res2 = sum(abs(b3 - vNumber))/sum(b3)*100;
    fPerMc = 100-res2;
end
