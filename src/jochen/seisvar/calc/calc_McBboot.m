function [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mCatalog, binInterval, nBootstraps, mcCalcMethod, nMinNum, fMcCorr)
    %calc_McBboot Calculates Mc, b-value and their uncertainties from bootstrapping
    %
    % [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mCatalog, fBinning, nSample, mcCalcMethod, nMinNum, fMcCorr)
    %--------------------------------------------------------------------------------------------------------------------------------------
    
    % Mc and b are actually the mean values of the empirical distribution
    %
    % Input parameters
    % mCatalog    : Earthquake catalog
    % binInterval : Binning interval [magnitude]
    % nBootstraps : Number of bootstraps to determine Mc
    % mcCalcMethod     : Method to determine Mc (see calc_Mc)
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
    if mCatalog.Count >= nMinNum
        % Get magnitudes
        vMags = mCatalog.Magnitude;
        % Reset randomizer
        rng('shuffle');
        % Create bootstrap samples using bootstrap matlab toolbox
        % mMag_bstsamp = bootrsp(vMags,nSample);
        % Determine Mc uncertainty
        vMc = nan(nBootstraps,1);
        mBvalue = nan(nBootstraps,4);
        
        %[~, mc_calculator] = calc_Mc(mCatalog, mcCalcMethod, binInterval, fMcCorr);
        
        for nSamp=1:nBootstraps
            mCatalog.Magnitude = bootrsp(vMags,1);
            fMc = calc_Mc(mCatalog, mcCalcMethod, binInterval, fMcCorr);
            vMc(nSamp) =  fMc;
            % Select magnitude range and calculate b-value
            mCatMag = mCatalog.Magnitude( mCatalog.Magnitude >= fMc-binInterval/2 );
            
            % Check static for length of catalog
            if length(mCatMag) >= nMinNum
                [ fBvalue, fStdDev, fAvalue] =  calc_bmemag(mCatMag, binInterval);
                fMeanMag=mean(mCatMag);
            else
                fMeanMag = NaN;
                fBvalue = NaN;
                fStdDev = NaN;
                fAvalue = NaN;
            end
            mBvalue(nSamp,:) = [fMeanMag fBvalue fStdDev fAvalue];
            
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
    
