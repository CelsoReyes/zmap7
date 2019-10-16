function [Mc90, Mc95, magco, prf] = mcperc_ca3(magnitudes) 
    % MCPERC_CA3 This is a completeness determination test
    %
    % FIXME: WHAT MAKES THIS SPECIAL?  doesn't calc_Mc do this? what is this method, specifically!
    %
    % MCPERC_CA3(catalog)
    % returns:
    %     [Mc, Mc90, Mc95, magco, prf]
      % 
    
    MIN_EVENT_COUNT = 25;
    
    magwin_centers = -2 : 0.1 : 6;
    [bval,xt2] = histcounts(magnitudes, centers2edges(magwin_centers));
    xt2 = edges2centers(xt2);
    l = find(bval == max(bval), 1, 'last' );
    magco0 =  xt2(l);
    
    loopMags = magco0-0.5 : 0.1 : magco0+0.7; % from near magnitude of completion to a little past it.
    loopMags = loopMags(:);
    ls = magnitudes >= loopMags-0.0499; % magnitudes x loopMags logical array
    res2s = NaN(size(loopMags));
    mask = find(sum(ls) > MIN_EVENT_COUNT);
    for idx = mask
        smallcat = magnitudes(ls(:,idx));
        bv2 = calc_bmemag(smallcat, 0.1);
        res2 = calc_res(smallcat, bv2, loopMags(idx), 0.1);
        res2s(idx) = res2;
    end
    
    minres2s = min(res2s);
    
    % Mc90
    if minres2s < 10
        Mc90 = loopMags(find(res2s < 10, 1));
    else 
        Mc90 = NaN;
    end
        
    % Mc95
    if minres2s < 5
        Mc95 = loopMags(find(res2s < 5, 1));
    else
        Mc95 = NaN;
    end
    
    % get first Magnitude that 
    if ~isnan(Mc90) % equivelent to finding res2s <10
        Mc = Mc90; 
    elseif minres2s < 15
        Mc = loopMags(find(res2s < 15, 1));
    elseif minres2s < 20
        Mc = loopMags(find(res2s < 20, 1));
    elseif minres2s < 25
        Mc = loopMags(find(res2s < 25, 1));
    else
        Mc = NaN;
    end
    magco = Mc;
    
    % FIXME: (or not) previous code simplifed to this, but not sure about its original intent.
    prf = 100 - minres2s;
    
end

function res = calc_res(actualMags, B, startMag, magStep) 
    %This program generates a synthetic catalog of given total number of events, b-value, minimum magnitude,
    %and magnitude increment. matches number of events provided
    %
    % VALUE RETURNED IS some sort of residual from binned actual mags
    %  
    %   actualMags: total # events
    %   B : desired b-value
    %   startMag : starting magnitude (hypothetical Mc)
    %   magStep = 0.1 ;%magnitude increment
    %
    % Yuzo Toya 2/1999
    % turned into function by Celso G Reyes 2017
    % rewritten by Celso G Reyes 2017
    %
    % now, save lots of time by only doing a permutation if we are going to return newMags
    % surprisingly, 'res' does not depend on the synthetic catalog at all.  This was verified
    % by looking at old (2014 source code) -CGR
    
    nActual = numel(actualMags);
    mags = startMag : magStep : 10;
    
    events_each_step = 10 .^ (log10(nActual) - B * (mags - startMag));
    total_expected_events = sum(events_each_step);
    distribution = round(events_each_step / total_expected_events * nActual);
    distribution(1) = distribution(1) + (nActual - sum(distribution)); % adjust for  rounding errors
    
    mags(distribution < 1) = []; 
    distribution(distribution<1) = [];
    
    halfStep = magStep / 2;
    magBinEdges = [mags - halfStep , max(mags)];
    bval = histcounts(actualMags, magBinEdges);

    b3 = cumsum(bval, 'reverse');
    res = sum(abs(b3 - distribution)) / sum(b3) * 100;
    
end

