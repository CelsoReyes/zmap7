function [fMc, fMc95, fMc90] = calc_McBest(mCatalog, fBinning)
    % CALC_MCBEST calculate best Magnitude of Completion
    % [fMc, fMc95, fMc90] = calc_McBest(mCatalog, fBinning)
    
    report_this_filefun();
    
    % Magnitude increment
    if ~exist('fBinning','var')
        fBinning = 0.1;
    end
    
    % First estimation of magnitude of completeness (maximum curvature)
    McStart = maxCurvature(mCatalog.Magnitude, [-2 6] , fBinning);
    
    half_fBin=fBinning/2;
    eachbin = (McStart - 0.9) : fBinning : (McStart + 1.5);
    eachedge = [eachbin-half_fBin , eachbin(end)+half_fBin]; 
    
    mData=[eachbin(:), nan(numel(eachbin),1)];
    
    for idx = 1:numel(eachbin)
        vSel = mCatalog.Magnitude > eachedge(idx);
        nEvents = sum(vSel);
        
        if nEvents < 25
            continue
        end
        
        fBValue = calc_bmemag(mCatalog.Magnitude(vSel));
        
        fStartMag = eachbin(idx); % Starting magnitude (hypothetical Mc)
        
        % log10(N)=A-B*M
        vMag = fStartMag:fBinning:15; % Ending magnitude must be sufficiently high
        vNumber = 10.^(log10(nEvents)-fBValue*(vMag - fStartMag));
        vNumber = round(vNumber);
        
        % Find the last bin with an event
        nLastEventBin = find(vNumber > 0, 1,'last' );
        
        % Determine set of all magnitude bins with number of events > 0
        ct = round((vMag(nLastEventBin)-fStartMag)*(1/fBinning) + 1);
        
        % PM=vMag(1:ct);
        PMedges = [vMag-half_fBin , vMag(end)+half_fBin]; 
        [bval, ~] = histcounts(mCatalog.Magnitude(vSel),PMedges);
        b3 = cumsum(bval,'reverse');    % N for M >= (counted backwards)
        mData(idx,2) = sum(abs(b3 - vNumber(1:ct) )) / sum(b3)*100; %res2
    end
    
    % Evaluation of results
    
    % Is fMc90 available
    nSel = find(mData(:,2) < 10, 1 );
    if isempty(nSel)
        fMc90 = NaN;
    else
        fMc90 = mData(nSel,1);
    end
    
    % Is fMc95 available
    nSel = find(mData(:,2) < 5, 1 );
    if isempty(nSel)
        fMc95 = NaN;
    else
        fMc95 = mData(nSel,1);
    end
    
    % ?????
    j =  find(mData(:,2) < 10 , 1 );
    if isempty(j); j =  find(mData(:,2) < 15 , 1 ); end
    if isempty(j); j =  find(mData(:,2) < 20 , 1 ); end
    if isempty(j); j =  find(mData(:,2) < 25 , 1 ); end
    %j2 =  min(find(dat(:,2) == min(dat(:,2)) ));
    
    fMc = mData(j,1);
    if isempty(fMc)
        fMc = NaN;
    end
end

function Mc = maxCurvature(m, min_max, binwidth)
    % MAXCURVATURE First estimation of magnitude of completeness (maximum curvature)
    % Mc = MAXCURVATURE(m, min_max, binwidth)
    centers=min_max(1) : binwidth : min_max(2); 
    halfBinwidth = binwidth/2;
    edges= [centers-halfBinwidth , centers(end)+halfBinWidth];
    [vEvents, ~] = histcounts(m, edges);
    nSel = find(vEvents == max(vEvents), 1, 'last' );
    Mc = centers(nSel);
end
