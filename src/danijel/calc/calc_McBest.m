function [fMc, fMc95, fMc90] = calc_McBest(magnitudes, binInterval)
    % CALC_MCBEST calculate best Magnitude of Completion
    % [fMc, fMc95, fMc90] = calc_McBest(magnitudes, binInterval)
    
    % report_this_filefun();
    
    % Magnitude increment
    if ~exist('binInterval','var')
        binInterval = 0.1;
    end
    
    % First estimation of magnitude of completeness (maximum curvature)
    McStart = maxCurvature(magnitudes, [-2 6] , binInterval);
    
    half_fBin=binInterval/2;
    magCenters = (McStart - 0.9) : binInterval : (McStart + 1.5);
    eachedge = [magCenters-half_fBin , magCenters(end)+half_fBin]; 
    
    mData=[magCenters(:), nan(numel(magCenters),1)];
    
    % binForEvents = discretize(magnitudes, eachedge); % eg. where binForEvents==9, the event falls into magCenters(9)
    % smallestBin = min(binForEvents);
    % biggestBin = max(binForEvents);
    % minRepresentedMag = magCenters(smallestBin);
    % maxRepresentedMag = magCenters(biggestBin);
    
    %allBinnedEvents = histcounts(magnitudes, eachedge);
    
    for idx = 1:numel(magCenters)
        hypotheticalMc = magCenters(idx);
        bigEnough = magnitudes > eachedge(idx);
        nEvents = sum(bigEnough);
        
        if nEvents < 25
            continue
        end
        mData(idx,2) = doCalculation(magnitudes(bigEnough), binInterval, hypotheticalMc);
    end
    results = mData(:,2); % where results(x) are associated with magcenters(x)
    % Evaluation of results
    
    % Is fMc90 available
    nSel = find(results < 10, 1 );
    if isempty(nSel)
        fMc90 = NaN;
    else
        fMc90 = magCenters(nSel);
    end
    
    % Is fMc95 available
    nSel = find(results < 5, 1 );
    if isempty(nSel)
        fMc95 = NaN;
    else
        fMc95 = mData(nSel,1);
    end
    
    % take results from bins. (I tested against discretize, and this was faster -CGR)
    
    j =  find(results < 10 , 1, 'first');
    if isempty(j); j =  find(results < 15 , 1, 'first' ); end
    if isempty(j); j =  find(results < 20 , 1, 'first' ); end
    if isempty(j); j =  find(results < 25 , 1, 'first' ); end
    fMc = magCenters(j);
    if isempty(fMc)
        fMc = NaN;
    end
end

function result = doCalculation(theseMags, binInterval, hypotheticalMc)
        fBValue = calc_bmemag(theseMags, binInterval);
        half_fBin = binInterval/2;
        
        % log10(N)=A-B*M
        vMag = hypotheticalMc:binInterval:15; % Ending magnitude must be sufficiently high (???what is "sufficently high")
        vNumber = 10.^(log10(numel(theseMags))-fBValue*(vMag - hypotheticalMc));
        vNumber = round(vNumber);
        
        % Find the last bin with an event
        binsWithEvents = vNumber>0;
        nLastEventBin = find(binsWithEvents, 1,'last' );
        
        
        % Determine set of all magnitude bins with number of events > 0
        ct = round((vMag(nLastEventBin)-hypotheticalMc)*(1/binInterval) + 1);
        
        % PM=vMag(1:ct);
        PMedges = [vMag-half_fBin , vMag(end)+half_fBin]; 
        [bval, ~] = histcounts(theseMags, PMedges);
        b3 = cumsum(bval,'reverse');    % N for M >= (counted backwards)
        result = sum(abs(b3(1:ct) - vNumber(1:ct) )) / sum(b3)*100; %res2
end

function Mc = maxCurvature(m, min_max, binwidth)
    % MAXCURVATURE First estimation of magnitude of completeness (maximum curvature)
    % Mc = MAXCURVATURE(m, min_max, binwidth)
    centers=min_max(1) : binwidth : min_max(2); 
    halfBinwidth = binwidth/2;
    edges= [centers-halfBinwidth , centers(end)+halfBinwidth];
    [vEvents, ~] = histcounts(m, edges);
    nSel = find(vEvents == max(vEvents), 1, 'last' );
    Mc = centers(nSel);
end
