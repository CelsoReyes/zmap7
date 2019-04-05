function [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(magnitudes, bins, fMc)
    % Determine logical selection vector for a selection of magnitudes above Mc.
    %
    % [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagtoFitBValue(magnitudes, bincenters, fMc);
    %-------------------------------------------------------------------------------------
    %
    % Determine logical selection vector for a selection of magnitudes above Mc. Use before
    % fitting b-value
    % Incoming variables:
    % magnitudes: earthquake catalogue
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
    % updated: 17.07.02
    
    if size(bins,1) == 2 && size(bins,2) > 1 % old-style
        nIndexLo = find((bins(1,:) < fMc + 0.05) & (bins(1,:) > fMc - 0.05));
        fMagHi = bins(1,1);
        vSel = bins(1,:) <= fMagHi & bins(1,:) >= fMc-.0001;
        vMagnitudes = bins(1,vSel);
        
        if isnumeric(magnitudes)
            vSel = magnitudes >= fMc-0.05;
        else
            vSel = magnitudes.Magnitude >= fMc-0.05;
        end
    else % new style
        nIndexLo = find((bins < fMc + 0.05) & (bins > fMc - 0.05));
        fMagHi = bins(1);
        vSel = bins <= fMagHi & bins >= fMc-0.0001;
        vMagnitudes = bins(vSel);
        
        % Selection of magnitudes M>Mc to calculate b-value
        vSel = magnitudes >= fMc - 0.05;
    end
end
