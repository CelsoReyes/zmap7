function [res, newMags]=synthb_aut(actualMags, B, startMag, magStep) 
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
    
    %report_this_filefun();
    nEvents=numel(actualMags);
    mags= startMag : magStep : 10;
    
    N = 10 .^ (log10(nEvents) - B*(mags - startMag)); %expected events per mag step

    N=round(N / sum(N) * nEvents); % get distribution at this number
    
    N(1) = N(1) + (nEvents - sum(N)); % we might be off by an event or two due to rounding
    mags(N<1)=[];
    N(N<1) = [];
    
    halfStep = magStep /2;
    magBinEdges = [mags - halfStep , max(mags)];
    bval = histcounts(actualMags,magBinEdges);

    b3 = cumsum(bval,'reverse');
    res = sum(abs(b3 - N)) / sum(b3)*100;
    
    if nargout==2
        
        newMags=zeros(nEvents,1);
        
        lasts=cumsum(N)';
        nexts=[0;lasts(1:end-1)]+1;
        
        for i=1:numel(N)
            newMags(nexts(i):lasts(i),1) = mags(i);
        end
        
        newMags = newMags(randperm(nEvents));
    end
end
