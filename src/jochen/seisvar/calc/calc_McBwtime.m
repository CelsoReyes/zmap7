function [result] = calc_McBwtime(catalog, varargin)
    % calc_McBwtime Calculate Mc and b-value with time using Mc mean from bootstrap to calculate b-values
    %
    % [mResult] = calc_McBwtime(catalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, binWidth)
    %
    % Incoming variables:
    % catalog    : Earthquake Catalog
    % nSampleSize : Number of events to calculate single b-value
    % nOverlap    : Samplesize/nOverlap determines overlap of moving windows
    % nMethod     : Method to determine Mc
    % nBstSample  : Number of bootstraps to determine Mc
    % nMinNumberevents : Minimum number of events
    % binWidth    : Binning interval
    %
    % outgoing variable:
    % result : struct containing fields 
    %   meanSampleTime : Mean time of sample
    %   mcMeanWithTime : fMc with time (mean Mc)
    %   mcStdDevBoot : Standard deviation of mean Mc from the bootstrap
    %   bMeanWithTime : b-value (mean b)
    %   bStdDevBoot : Standard deviation of mean b-value from the bootstrap
    %   aMeanWithTime :a-value (mean b)
    %   aStdDevBoot : Standard deviation of mean a-value from the bootstrap
    
    % OLD Outgoing variables:
    % mResult(:,1) : Mean time of sample
    % mResult(:,2) : fMc with time (mean Mc)
    % mResult(:,3) : Standard deviation of mean Mc from the bootstrap
    % mResult(:,4) : b-value (mean b)
    % mResult(:,5) : Standard deviation of mean b-value from the bootstrap
    % mResult(:,6) :a-value (mean b)
    % mResult(:,7) : Standard deviation of mean a-value from the bootstrap
    %
    % Author: J. Woessner, heavily modified by C Reyes
    
    % Check input
    p=inputParser();
    p.addRequired('catalog');
    p.addOptional('nSampleSize',    15);
    p.addOptional('nOverlap',       10);
    p.addOptional('nMethod',        1);
    p.addOptional('nBstSample',     100);
    p.addOptional('nMinNumberEvents',50);
    p.addOptional('binWidth',       0.1);
    p.addOptional('fMcCorr',        0.0);
    p.addParameter('ParMode', ZmapGlobal.Data.ParallelProcessingOpts.Enable);
    p.parse(catalog, varargin{:});
    
    % report any default values being used
    if ~isempty(p.UsingDefaults) && ~verLessThan('matlab','9.3') % cellfun behavior changed in R2017
        fprintf("Defaults -> ");
        disp(strjoin(cellfun(@(x)strjoin(string(x) + " : " + p.Results.(x)),p.UsingDefaults),', '));
    end
    
    nSampleSize = p.Results.nSampleSize;
    
    % Set fix values
    % fMinMag = min(catalog.Magnitude);
    fMaxMag = max(catalog.Magnitude);
    
    stride = max(round(nSampleSize .* 1 - (p.Results.nOverlap ./ 100)), 1);
    windowStarts = 1 : stride : catalog.Count - nSampleSize ;
    windowEnds = windowStarts + nSampleSize - 1;
    nWindows = numel(windowStarts);
    
    % mResult = nan(nWindows, 7);
    % pre-initialize the results array
    result = struct();
    result.meanSampleTime   = NaT;
    result.mcMeanWithTime   = nan;
    result.mcStdDevBoot     = nan;
    result.bMeanWithTime    = nan;
    result.bStdDevBoot      = nan;
    result.aMeanWithTime    = nan;
    result.aStdDevBoot      = nan;
    result(nWindows)=result;
    
    % stash all the repeated parameters in this anonymous function
    doMcBootCalc=@(events)calc_McBboot(events, p.Results.binWidth, p.Results.nBstSample,...
        p.Results.nMethod, p.Results.nMinNumberEvents, p.Results.fMcCorr);
        
    if p.Results.ParMode
        parfor i = 1 : nWindows
            % Select samples
            eventsInWindow = catalog.subset( windowStarts(i) : windowEnds(i) );
            [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A] = doMcBootCalc(eventsInWindow);
            
            result(i).meanSampleTime   = mean(eventsInWindow.Date);
            result(i).mcMeanWithTime   = fMc;
            result(i).mcStdDevBoot     = fStd_Mc;
            result(i).bMeanWithTime    = fBvalue;
            result(i).bStdDevBoot      = fStd_B;
            result(i).aMeanWithTime    = fAvalue;
            result(i).aStdDevBoot      = fStd_A;
            
        end % END of FOR fMag
        
    else
        hWait = waitbar(0,'Please wait...');
        updateInterval = ceil(nWindows/100);
        for i = 1 : nWindows
            % Select samples
            eventsInWindow = catalog.subset( windowStarts(i) : windowEnds(i) );
            
            %fTime = decyear(mean(eventsInWindow.Date)); %TODO replace all mResult decyear with something datetime based
            [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A] = doMcBootCalc(eventsInWindow);
            
            % mResult(i,:) = [fTime fMc fStd_Mc fBvalue fStd_B fAvalue fStd_A];
            if mod(i, updateInterval) == 0
                waitbar(i/nWindows)
            end
            
            result(i).meanSampleTime   = mean(eventsInWindow.Date);
            result(i).mcMeanWithTime   = fMc;
            result(i).mcStdDevBoot     = fStd_Mc;
            result(i).bMeanWithTime    = fBvalue;
            result(i).bStdDevBoot      = fStd_B;
            result(i).aMeanWithTime    = fAvalue;
            result(i).aStdDevBoot      = fStd_A;
            
        end % END of FOR fMag
        close(hWait)
    end
    
    
end


