function [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(catalog, binInterval, nBootstraps, mcCalcMethod, nMinNum, fMcCorr)
    %CALC_MCBOOT Calculates Mc, b-value and their uncertainties from bootstrapping
    %
    % [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = CALC_MCBOOT(catalog, fBinning, nSample, mcCalcMethod, nMinNum, fMcCorr)
    %--------------------------------------------------------------------------------------------------------------------------------------
    
    % Mc and b are actually the mean values of the empirical distribution
    %
    % Input parameters
    % catalog    : Earthquake catalog
    % binInterval : Binning interval [magnitude]
    % nBootstraps : Number of bootstraps to determine Mc
    % mcCalcMethod     : Method to determine Mc (see calc_Mc , McMethods)
    % nMinNum     : Minimum number of events above Mc to calculate
    % fMcCorr     : Correction term for Mc
    %
    % Output parameters
    % fMc     : Mean Mc of the bootstrap
    % fStd_Mc : 2nd moment of Mc distribution
    % fBvalue : Mean b-value of the bootstrap
    % fStd_B  : 2nd moment of b-value distribution
    % fAvalue : Mean a-value of the bootstrap
    % fStd_A  : 2nd moment of a-value distribution
    % vMc     : Vector of Mc-values (excluding any NaN values)
    % mBvalue : Matrix of [fMeanMag fBvalue fStdDev fAvalue]
    %
    % J. Woessner
    % updated: 27.12.05
    
    % Check input variables
    % Minimum number of events
    
    if ~exist('nMinNum', 'var')
        nMinNum = 50;
    end
    
    if ~exist('fMcCorr', 'var')
        fMcCorr = 0;
    end
    
    % Initialize
    mBvalue = [];
    vMc = [];
    [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A] = deal(NaN);
    
    if nBootstraps <= 0
        return
    end
    
    if isnumeric(catalog)
        results = process_magnitudes(catalog);
    else
        if McMethods.acceptsMagnitudes(mcCalcMethod)
            results = process_magnitudes(catalog.Magnitude);
        else
            results = process_catalog(catalog);
        end
        % provided entire catalog
    end
    if ~isempty(results)
        % fill in returns
        
    
        % Calculate mean Mc and standard deviation
        vMc(isnan(vMc))=[];
        fStd_Mc = std(vMc);
        fMc = mean(vMc);

        % Calculate mean b-value and standard deviation
        fStd_B = std(mBvalue(:,2),1,'omitnan');
        fStd_A = std(mBvalue(:,4),1,'omitnan');
        fBvalue = mean(mBvalue(:,2), 'omitnan');
        fAvalue = mean(mBvalue(:,4), 'omitnan');
    end
    
    return
    
    %%
        
    function [vMc, mBvalue, halfBinInterval, mc_calculator]= prepare_calculation(McInputType)
        rng('shuffle');
        
        % Create bootstrap samples using bootstrap matlab toolbox
        % Determine Mc uncertainty
        vMc = nan(nBootstraps,1);
        mBvalue = nan(nBootstraps,4);
        halfBinInterval = binInterval/2;
        [~, mc_calculator] = calc_Mc(McInputType, mcCalcMethod, binInterval, fMcCorr);
        
    end
    
    function results = process_catalog(catalog)
        if catalog.Count < nMinNum
            results = [];
            return
        end
        
        [vMc, mBvalue, halfBinInterval, mc_calculator] = prepare_calculation("AsCatalogs");
        vMags = catalog.Magnitude;
        for nSamp = 1 : nBootstraps
            catalog.Magnitude = bootrsp(vMags,1);
            fMc = mc_calculator(catalog);
            vMc(nSamp) =  fMc;
            % Select magnitude range and calculate b-value
            mCatMag = catalog.Magnitude( catalog.Magnitude >= fMc - halfBinInterval );
            
            % Check static for length of catalog
            if length(mCatMag) >= nMinNum
                [ fBvalue, fStdDev, fAvalue] = calc_bmemag(mCatMag, binInterval);
                fMeanMag = mean(mCatMag);
                mBvalue(nSamp, :) = [fMeanMag, fBvalue, fStdDev, fAvalue];
            end
            
        end
        
        % Calculate mean Mc and standard deviation
        results = true;
    end
    
    function results = process_magnitudes(magnitudes)
        if catalog.Count < nMinNum
            results = [];
            return
        end
        
        [vMc, mBvalue, halfBinInterval, mc_calculator] = prepare_calculation("AsMagnitudes");
        allmags = bootrsp(magnitudes, nBootstraps);
        fMcs = mc_calculator(allmags);
        vMc(:) = fMcs;
        
        for nSamp = 1:nBootstraps
            idx = allmags(:, nSamp) >= fMcs(nSamp) - halfBinInterval;
            mCatMag = allmags(idx, nSamp);
            
            % Check static for length of catalog
            if length(mCatMag) >= nMinNum
                [ fBvalue, fStdDev, fAvalue] = calc_bmemag(mCatMag, binInterval);
                fMeanMag = sum(mCatMag) / numel(mCatMag);
                mBvalue(nSamp, :) = [fMeanMag, fBvalue, fStdDev, fAvalue];
            end
            
        end
        results = true;
    end
end

