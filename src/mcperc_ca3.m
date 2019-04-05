function [Mc, Mc90, Mc95, magco, prf] = mcperc_ca3(magnitudes) 
    % MCPERC_CA3 This is a completeness determination test
    %
    % FIXME: WHAT MAKES THIS SPECIAL?  doesn't calc_Mc do this? what is this method, specifically!
    %
    % MCPERC_CA3(catalog)
    % returns:
    %     [Mc, Mc90, Mc95, magco, prf]
  
    % used to pull from newt2
    
    % 
    
    MIN_EVENT_COUNT = 25;
    
    magwin_centers = -2 : 0.1 : 6;
    [bval,xt2] = histcounts(magnitudes, centers2edges(magwin_centers));
    xt2 = edges2centers(xt2);
    l = find(bval == max(bval), 1, 'last' );
    magco0 =  xt2(l);
    
    loopMags = magco0-0.5 : 0.1 : magco0+0.7; % from near magnitude of completion to a little past it.
        
    ls = magnitudes>=loopMags-0.0499; % magnitudes x loopMags logical array
    dat(:,1) = loopMags;
    dat(:,2) = NaN;
    mask = find(sum(ls) > MIN_EVENT_COUNT);
    for idx = mask
        smallcat = magnitudes(ls(:,idx));
        bv2 = calc_bmemag(smallcat, 0.1);
        res2 = calc_res(smallcat, bv2, loopMags(idx), 0.1);
        dat(idx,2)=res2;
    end
    
    j =  find(dat(:,2) < 10 , 1 );
    if isempty(j)
        Mc90 = NaN ;
    else
        Mc90 = dat(j,1);
    end
    
    j =  find(dat(:,2) < 5 , 1 );
    if isempty(j) 
        Mc95 = NaN ;
    else
        Mc95 = dat(j,1);
    end
    
    j =  find(dat(:,2) < 10 , 1 );
    if isempty(j)
        j =  find(dat(:,2) < 15 , 1 ); 
    end
    if isempty(j)
        j =  find(dat(:,2) < 20 , 1 ); 
    end
    if isempty(j)
        j =  find(dat(:,2) < 25 , 1 );
    end
    j2 =  find(dat(:,2) == min(dat(:,2)) , 1 );
    %j = min([j j2]);
    
    Mc = dat(j,1);
    magco = Mc;
    if isempty(magco)
        magco = NaN;
        prf = 100 - min(dat(:,2));
    else
        magco = Mc;
        prf = 100 - dat(j2,2);
    end
    %disp(['Completeness Mc: ' num2str(Mc) ]);
    
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
    
    nEvents = numel(actualMags);
    mags = startMag : magStep : 10;
    
    N = 10 .^ (log10(nEvents) - B * (mags - startMag)); %expected events per mag step

    N = round(N / sum(N) * nEvents); % get distribution at this number
    
    N(1) = N(1) + (nEvents - sum(N)); % we might be off by an event or two due to rounding
    mags(N < 1) = [];
    N(N<1) = [];
    
    halfStep = magStep / 2;
    magBinEdges = [mags - halfStep , max(mags)];
    bval = histcounts(actualMags, magBinEdges);

    b3 = cumsum(bval, 'reverse');
    res = sum(abs(b3 - N)) / sum(b3) * 100;
    
end

