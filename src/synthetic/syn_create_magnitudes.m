function newMags = syn_create_magnitudes(nEvents, B, startMag, magStep)
    % Generate a vector of synthetic magnitudes matching a desired b-value, start mag, and mag step
    %
    %   nEvents: total # events
    %   B : desired b-value
    %   startMag : starting magnitude (hypothetical Mc)
    %   magStep = 0.1 ;%magnitude increment
    %
    % by/modified by Yuzo Toya 1999, Danjiel Schorlemmer, Thomasvan Stiphout
    % reworked by Celso Reyes
    
    mags = startMag : magStep : 15;
    
    N = 10 .^ (log10(nEvents) - B*(mags - startMag)); %expected events per mag step
    
    N = round(N / sum(N) * nEvents); % get distribution at this number
    
    N(1) = N(1) + (nEvents - sum(N)); % we might be off by an event or two due to rounding
    mags(N<1) = [];
    N(N<1) = [];
    
    newMags = zeros(nEvents,1);
    
    lasts = cumsum(N)';
    nexts = [0;lasts(1:end-1)]+1;
    
    for i = 1:numel(N)
        newMags(nexts(i):lasts(i),1) = mags(i);
    end
    
    newMags = newMags(randperm(nEvents));
end
