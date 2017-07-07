function [mMLS] = calc_FitComp(mCatalog, fMinRad, fMaxRad, fRadIncr, fX, fY)
% function [mMLS] = calc_FitComp(mCatalog, fMinRad, fMaxRad, fRadIncr, fX, fY);
% -----------------------------------------------------------------------------
%
% Function to calculate the MLS fit and the Goodness of fit rate to discriminate which
% method works best exploring increasing radii
%
% Incoming variables:
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 23.01.03

% Initialize
mMlS = [];

% Start value
fRadius = fMinRad;
while fRadius <= fMaxRad
    % Create catalog
    vDistances_ = sqrt(((mCatalog(:,1)-fX)*cos(pi/180*fY)*111).^2 + ((mCatalog(:,2)-fY)*111).^2);
    % Select those in between the maximum radius
    vSel = (vDistances_ <= fRadius);
    vCheckDist = vDistances_(vSel, :);
    mRadCatalog = mCatalog(vSel, :);
    % Determine Mc-values
    [result]=sv_NodeCalcMc(mRadCatalog); % For parameters in result see sv_NodeCalcMc

    % Calculate normal and lognormal fit
    [mResult, fProbNorm, fMcNorm, vX_resNorm, fNmaxNorm, mDatPredNorm] = calc_McCdfnormal(mRadCatalog, 0.1);
    [mResult2, fProbLog, fMcLog, fMuLog, fSigmaLog, mDatPredLog, vPredBest] = calc_McCdflognormal(mCat, fBinning);
    [fProbExp, fMcExp, vX_resExp, fNmaxExp, mDatPredExp] = calc_McCdfexp(mRadCatalog, 0.1);

    % Show data fit below Mc
    vSel = (mDatPredNorm(:,2) < fMcNorm);
    mTmpNorm = mDatPredNorm(vSel,:);
    vSel = (mDatPredLog(:,2) < fMcLog);
    mTmpLog = mDatPredLog(vSel,:);
    vSel = (mDatPredExp(:,2) < fMcExp);
    mTmpExp = mDatPredExp(vSel,:);
    figure;
    plot(mTmpNorm(:,2), mTmpNorm(:,3),'k*',mTmpNorm(:,2), mTmpNorm(:,1),'-b');
    hold on;
    plot(mTmpLog(:,2), mTmpLog(:,1),'-r');
    plot(mTmpExp(:,2), mTmpExp(:,1),'-g');
    legend('Data','Normal CDF', 'Lognorm. CDF', 'Exponential func.');
    sTitlestr = ['McNorm = ' num2str(fMcNorm) ', McLog = ' num2str(fMcLog) ', McExp = ' num2str(fMcExp) ', R = ' num2str(fRadius)];
    title(sTitlestr)
    xlabel('Magnitude')
    drawnow;
    hold off;
    sPrintstr = ['Fit_kobe_1986_92_135.6_35' num2str(fRadius) 'km.eps'];
    print('-deps2c', '-tiff','-r400', sPrintstr);

    % Result array
    mMLS = [mMLS; fRadius result.fProbMcNorm result.fProbMcLog fProbExp result.fMc_max result.fMc_90 result.fMc_95...
            result.fMc_com result.fMcNorm result.fMcLog fMcExp];

    % Plot Non-cumulative distribution, original and predicted
    % Time period
    [vFMD, vNonCFMD] = calc_FMD(mRadCatalog);
    vNonCFMD = fliplr(vNonCFMD);
    fPeriod1 = max(mRadCatalog(:,3)) - min(mRadCatalog(:,3));
    %     figure_w_normalized_uicontrolunits('tag','ncumdist','Name','Best model','Units','normalized','Nextplot','add',...
    %         'Numbertitle','off','visible','on');
    figure;
    semilogy(vNonCFMD(1,:)', vNonCFMD(2,:)', '-k^',mDatPredNorm(:,2) ,mDatPredNorm(:,1).*fPeriod1,'-bo');
    hold on;
    semilogy(mDatPredLog(:,2) ,mDatPredLog(:,1).*fPeriod1,'-r*');
    semilogy(mDatPredExp(:,2) ,mDatPredExp(:,1).*fPeriod1,'-gs');
    legend('Data','Normal CDF', 'Lognorm. CDF', 'Exponential func.');
    sTitlestr = ['McNorm = ' num2str(fMcNorm) ', McLog = ' num2str(fMcLog) ', McExp = ' num2str(fMcExp) ', R = ' num2str(fRadius)];
    title(sTitlestr)
    xlabel('Magnitude')
    ylabel('Non-cumulative FMD')
    drawnow;
    sPrintstr = ['FMD_kobe_1986_92_135.6_35' num2str(fRadius) 'km.eps'];
    print('-deps2c', '-tiff','-r400', sPrintstr);
    % Increase radius
    fRadius = fRadius+fRadIncr;
end

figure;
subplot(2,1,1);
plot(mMLS(:,1), mMLS(:,8),'-bd', mMLS(:,1), mMLS(:,9),'-rd', mMLS(:,1), mMLS(:,10),'-gd');
xlabel('Radius / [km]')
ylabel('Mc')
legend('Normal CDF', 'Lognorm. CDF', 'Exponential func.');
subplot(2,1,2);
plot(mMLS(:,1), mMLS(:,2),'-bd', mMLS(:,1), mMLS(:,3),'-rd', mMLS(:,1), mMLS(:,4),'-gd');
xlabel('Radius / [km]')
ylabel('MLS')
drawnow;
sPrintstr = ['Radius_kobe_1986_92_135.6_35.eps'];
print('-deps2c', '-tiff','-r400', sPrintstr);

