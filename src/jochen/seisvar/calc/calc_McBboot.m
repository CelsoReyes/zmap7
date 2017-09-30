function [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mCatalog, fBinning, nSample, nMethod, nMinNum, fMcCorr)
    %calc_McBboot Calculates Mc, b-value and their uncertainties from bootstrapping
    % [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mCatalog, fBinning, nSample, nMethod, nMinNum, fMcCorr)
    %--------------------------------------------------------------------------------------------------------------------------------------
    
    % Mc and b are actually the mean values of the empirical distribution
    %
    % Input parameters
    % mCatalog    : Earthquake catalog
    % fBinning    : Binning interval [magnitude]
    % nSample     : Number of bootstraps to determine Mc
    % nMethod     : Method to determine Mc (see calc_Mc)
    % nMinNum     : Minimum number of events above Mc to calculate
    % fMcCorr     : Correction term for Mc
    %
    % Output parameters
    % fMc     : Mean Mc of the bootstrap
    % fStd_Mc : 2nd moment of Mc distribution
    % fBvalue : Mean b-value of the bootstrap
    % fStd_B  : 2nd moment of b-value distribution
    % fAvalue : Meana-value of the bootstrap
    % fStd_A  : 2nd moment of a-value distribution
    % vMc     : Vector of Mc-values
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
    mBvalue = [];
    
    % Check size of catalog
    nRow=mCatalog.Count;
    
    % Restrict to minimum number
    if nRow >= nMinNum
        % Get magnitudes
        vMags = mCatalog.Magnitude;
        % Reset randomizer
        rand('state',sum(100*clock));
        % Create bootstrap samples using bootstrap matlab toolbox
        %mMag_bstsamp = bootrsp(vMags,nSample);
        % Determine Mc uncertainty
        vMc = nan(nSample,1);
        for nSamp=1:nSample
            mCatalog.Magnitude = bootrsp(vMags,1);
            [fMc] = calc_Mc(mCatalog, nMethod, fBinning, fMcCorr);
            vMc(nSamp) =  fMc;
            % Select magnitude range and calculate b-value
            vSel = mCatalog.Magnitude >= fMc-fBinning/2;
            mCat = mCatalog.subset(vSel);
            % Check static for length of catalog
            if mCat.Count >= nMinNum
                [ fBvalue, fStdDev, fAvalue] =  calc_bmemag(mCat, fBinning);
            else
                fMeanMag = NaN;
                fBvalue = NaN;
                fStdDev = NaN;
                fAvalue = NaN;
            end
            mBvalue = [mBvalue; fMeanMag fBvalue fStdDev fAvalue];
            
        end
        
        % Calculate mean Mc and standard deviation
        vSel = isnan(vMc);
        vMc = vMc(~vSel,:);
        fStd_Mc = std(vMc,1,'omitnan');
        fMc = nanmean(vMc);
        
        % Calculate mean b-value and standard deviation
        fStd_B = std(mBvalue(:,2),1,'omitnan');
        fStd_A = std(mBvalue(:,4),1,'omitnan');
        fBvalue = nanmean(mBvalue(:,2));
        fAvalue = nanmean(mBvalue(:,4));
        
    else
        sString = ['Less than N = ' num2str(nMinNum) ' events'];
        disp(sString)
        % Set all values to NaN
        [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A] = deal(NaN);
    end
    
