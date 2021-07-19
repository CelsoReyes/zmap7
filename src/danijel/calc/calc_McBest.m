function [Mc, Mc95, Mc90] = calc_McBest(magnitudes, binInterval)
    % CALC_MCBEST calculate best Magnitude of Completion
    % [fMc, fMc95, fMc90] = calc_McBest(magnitudes, binInterval)
    % each row of magitudes gets its own calculation
    
    % report_this_filefun();
    
    % Magnitude increment
    if ~exist('binInterval','var')
        binInterval = 0.1;
    end
    magnitudes = sort(magnitudes); %each column sorted
    
    
    half_bin   = binInterval / 2;
    lowest = floor(min(magnitudes,[],'all'));
    highest = ceil(max(magnitudes,[],'all'));
    % First estimation of magnitude of completeness (maximum curvature)
    McStarts = maxCurvature(magnitudes, lowest : binInterval : highest , half_bin); % vectorized
    
    
    % cheat to allow this to handle multiple rows of magnitudes (independently)
    for jj = 1:size(magnitudes,2)
        valid = ~isnan(magnitudes(:,jj));
        [Mc(jj), Mc95(jj), Mc90(jj)] = calc_McBest_unvectorized(McStarts(jj), magnitudes(valid,jj), binInterval, half_bin);
    end
end

function  [fMc, fMc95, fMc90] = calc_McBest_unvectorized(McStart, magnitudes, binInterval, half_fBin)
    magCenters  = (McStart - 0.9) : binInterval : (McStart + 1.5);
    eachedge    = [magCenters - half_fBin , magCenters(end) + half_fBin]; 
    
    magnitudes = flipud(magnitudes); % from biggest to smallest
    nGtEdge = sum(magnitudes > eachedge((end-1) : -1 : 1)); % magnitudes(nGtEdge) gives last event above threshhold
    nGtEdge = fliplr(nGtEdge);
    too_few = nGtEdge < 25;
    
    results=nan(numel(magCenters),1);
    for idx = 1:numel(magCenters)
        if too_few(idx)
            continue
        end
        hypotheticalMc  = magCenters(idx);
        results(idx) = doCalculation(magnitudes(1:nGtEdge(idx)), binInterval, hypotheticalMc);
    end
    
    % Evaluation of results
    
    % Is fMc90 available
    nSel = find(results < 10, 1, 'first' );
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
        fMc95 = magCenters(nSel);
    end
    
    % take results from bins. (I tested against discretize, and this was faster -CGR)
    
    j =  find(results < 10 , 1, 'first');
    if isempty(j)
        j =  find(results < 15 , 1, 'first' ); 
    end
    if isempty(j)
        j =  find(results < 20 , 1, 'first' ); 
    end
    if isempty(j)
        j =  find(results < 25 , 1, 'first' ); 
    end
    fMc = magCenters(j);
    if isempty(fMc)
        fMc = NaN;
    end
end

function [result] = doCalculation(theseMags, binInterval, hypotheticalMc)
        fBValue   = calc_bmemag(theseMags, binInterval);
        half_fBin = binInterval ./ 2;
        
        % log10(N)=A-B*M
        vMag    = hypotheticalMc:binInterval:15; % Ending magnitude must be sufficiently high (???what is "sufficently high")
        vNumber = 10.^(log10(numel(theseMags)) - fBValue*(vMag - hypotheticalMc));
        vNumber = round(vNumber);
        
        
        % PM=vMag(1:ct);
        PMedges     = [vMag-half_fBin , vMag(end)+half_fBin]; 
        [bval, ~]   = histcounts(theseMags, PMedges);
        b3          = cumsum(bval,'reverse');    % N for M >= (counted backwards)
        result      = sum(abs(b3 - vNumber)) / sum(b3)*100; %res2
end

function Mc = maxCurvature(m, centers, halfBinwidth)
    % MAXCURVATURE First estimation of magnitude of completeness (maximum curvature)
    % Mc = MAXCURVATURE(m, min_max, binwidth)
    %
    % vectorized
    edges           = [centers - halfBinwidth , centers(end) + halfBinwidth];
    [vEvents, ~]    = histc(m, edges, 1);
    [~,idx] = max(flipud(vEvents));
    nSel = size(vEvents,1) - idx + 1;
    % nSel    = find(vEvents == max(vEvents), 1, 'last' );
    Mc      = centers(nSel);
end
