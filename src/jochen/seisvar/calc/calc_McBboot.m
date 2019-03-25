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
    
    % Correction
    if ~exist('fMcCorr', 'var')
        fMcCorr = 0;
    end
    
    % Initialize
    vMc = [];
    
    % Restrict to minimum number
    if catalog.Count >= nMinNum
        % Get magnitudes
        vMags = catalog.Magnitude;
        % Reset randomizer
        rng('shuffle');
        % Create bootstrap samples using bootstrap matlab toolbox
        % Determine Mc uncertainty
        vMc = nan(nBootstraps,1);
        mBvalue = nan(nBootstraps,4);
        halfBinInterval = binInterval/2;
        if nBootstraps > 0
            % get the calculator for faster calculations within the loop
            if ~ismember(mcCalcMethod, [McMethods.McDueB_Bootstrap, McMethods.McEMR])  % work with magnitudes only (faster, but uses more memory)
                [~, mc_calculator] = calc_Mc(vMags, mcCalcMethod, binInterval, fMcCorr);
                allmags = bootrsp(vMags, nBootstraps);
                fMcs = mc_calculator(allmags);
                vMc(:) = fMcs;
                for nSamp = 1:nBootstraps
                    idx = allmags(:, nSamp) >= fMcs(nSamp)-halfBinInterval;
                    mCatMag = allmags(idx, nSamp );
                    
                    % Check static for length of catalog
                    if length(mCatMag) >= nMinNum
                        [ fBvalue, fStdDev, fAvalue] = calc_bmemag(mCatMag, binInterval);
                        fMeanMag = sum(mCatMag)/numel(mCatMag);
                        mBvalue(nSamp, :) = [fMeanMag fBvalue fStdDev fAvalue];
                    end
                    
                end
            else % deal with entire catalogs (slower)
                [~, mc_calculator] = calc_Mc(catalog, mcCalcMethod, binInterval, fMcCorr);
                
                for nSamp = 1 : nBootstraps
                    catalog.Magnitude = bootrsp(vMags,1);
                    fMc = mc_calculator(catalog);
                    vMc(nSamp) =  fMc;
                    % Select magnitude range and calculate b-value
                    mCatMag = catalog.Magnitude( catalog.Magnitude >= fMc-halfBinInterval );
                    
                    % Check static for length of catalog
                    if length(mCatMag) >= nMinNum
                        [ fBvalue, fStdDev, fAvalue] = calc_bmemag(mCatMag, binInterval);
                        fMeanMag = mean(mCatMag);
                        mBvalue(nSamp, :) = [fMeanMag fBvalue fStdDev fAvalue];
                    end
                    
                end
            end
        end
        
        % Calculate mean Mc and standard deviation
        vMc(isnan(vMc))=[]; 
        fStd_Mc = std(vMc,1,'omitnan');
        fMc = nanmean(vMc);
        
        % Calculate mean b-value and standard deviation
        fStd_B = std(mBvalue(:,2),1,'omitnan');
        fStd_A = std(mBvalue(:,4),1,'omitnan');
        fBvalue = nanmean(mBvalue(:,2));
        fAvalue = nanmean(mBvalue(:,4));
        
    else
        mBvalue = [];
        sString = ['Less than N = ' num2str(nMinNum) ' events'];
        msg.dbdisp(sString)
        % Set all values to NaN
        [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A] = deal(NaN);
    end
    
