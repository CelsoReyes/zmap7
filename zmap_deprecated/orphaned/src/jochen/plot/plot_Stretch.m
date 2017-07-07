function [mRes, fMshift, fStretch] = plot_Stretch(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC)
% function [fMshift] = plot_Stretch(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC);
% ------------------------------------------------------------------------------------
% Function to calculate and plot shift and stretch: Mnew = c*Mold+ dM;
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% bTimePeriod   : Use catalog from beginning to end (0), use time periods (1)
% fSplitTime   : Splittime of catalog
% fTimePeriod  : Time period in decimal years
% nCalculateMC : Method to determine Mc (1-5 see help calc_Mc)
%
% Outgoing variable:
% fMshift : magnitude shift
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 22.09.02

% Track of changes:
% 21.08.02: Solved stability  problem (Error: vFMD(1,1) index exceeds matrix dimension) by adding
%           ~isempty(vFMD) & ~isempty(vFMDSecond) into if statement
% 22.09.02:

% Track variables
% fProbability: log lokelihood score

global fProbability

[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
        result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);
% Time periods for normalization
if bTimePeriod == 0
    fPeriod1 = (max(mFirstCatalog(:,3))-min(mFirstCatalog(:,3)));
    fPeriod2 = (max(mSecondCatalog(:,3))-min(mSecondCatalog(:,3)));
else
    fPeriod1 = fTimePeriod;
    fPeriod2 = fTimePeriod;
end

% Create the frequency magnitude distribution vectors for the two time
% periods and entire catalog
[vFMD, vNonCFMD] = calc_FMD(mFirstCatalog);
[vFMDSecond, vNonCFMDSecond] = calc_FMD(mSecondCatalog);
[vFMDOrg, vNonCFMDOrg] = calc_FMD(mCatalog);


%% Calculate a and b for entire catalog, b max. likelihood
fMcOrg = calc_Mc(mCatalog, nCalculateMC);
vSel = (mCatalog(:,6) >= fMcOrg);
[fMeanMagOrg, fBValueOrg, fStdDevOrg, fAValueOrg] =  calc_bmemagMag(mCatalog(vSel,:));
sOrg = ['Entire Catalog: Mc = ' num2str(fMcOrg) ' a = ' num2str(fAValueOrg)...
        ' b = ' num2str(fBValueOrg)];

% Calculate magnitude of completeness
fMc = calc_Mc(mFirstCatalog, nCalculateMC);
fMcSecond = calc_Mc(mSecondCatalog, nCalculateMC);

if (~isempty(fMc) & ~isempty(fMcSecond) & ~isempty(vFMD) & ~isempty(vFMDSecond))
    % First period
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD, fMc);
    % Calculate the b-value etc. for M > Mc
    [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemagMag(mFirstCatalog(vSel,:));
    vPoly = [-1*fBValue fAValue];
    fBFunc = 10.^(polyval(vPoly, vMagnitudes));
    %% Second period
    [nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mSecondCatalog, vFMDSecond, fMcSecond);
    % Calculate the b-value etc. for M > Mc
    [fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] = calc_bmemagMag(mSecondCatalog(vSelSecond,:));
    vPolySecond = [-1*fBValueSecond fAValueSecond];
    fBFuncSecond = 10.^(polyval(vPolySecond, vMagnitudesSecond));
    % Determine magnitude shift
    fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
    fMshift = fMintercept - vFMD(1,nIndexLo);
else
    disp('fMc, fMcSecond or vFMD / vFMDSecond not derivable');
    fMshift=NaN;
end

sPer1 = ['Period 1: a = ' num2str(fAValue) ' const. b = ' num2str(fBValue) ' Mc = ' num2str(fMc)];
sPer2 = ['Period 2: a = ' num2str(fAValueSecond) ' const. b = ' num2str(fBValueSecond)...
        ' Mc = ' num2str(fMcSecond)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Max. likelihood estimations for a and b using different methods for the
%% SECOND time period

% Model 1: Variable a and b-value
mControlM1 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1]
[fBValue2M1, fAValue2M1] = calc_MaxLikelihoodABCombined(mSecondCatalog, mControlM1, 0);
fP_modelM1 = fProbability;
nDegFreeM1 = 2;
sMod1 = ['Model 1: a = ' num2str(fAValue2M1) ' b = ' num2str(fBValue2M1)];

% Model 2: Variable a, const. b-value from max. likelihood estimation of
% first period
vSel = (mSecondCatalog(:,6) >= fMcSecond);
mSecondComp = mSecondCatalog(vSel,:);
fBValue2M2 = fBValue;
mControlM2 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1]
[fAValue2M2] = calc_MaxLikelihoodA_org(mSecondComp, mControlM2, fBValue2M2, 0);
% [fAValue2M2] = calc_MaxLikelihoodA(mSecondComp, fBValue2M2)
fP_modelM2 = fProbability;
nDegFreeM2 = 1;
sMod2 = ['Model 2: a = ' num2str(fAValue2M2) ' const. b = ' num2str(fBValue)];

% Model 3: Variable b-value,  twoa-value
mControlM3 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1 1];
[fBValue2M3, fAValue2M3_1, fAValue2M3_2] = calc_MaxLikelihoodA1A2B(mSecondCatalog,mControlM3,0);
fP_modelM3 = fProbability;
fAValue2M3 = max([fAValue2M3_1 fAValue2M3_2]);
nDegFreeM3 = 3;
sMod3 = ['Model 3: a_1 = ' num2str(fAValue2M3_1) ' a_2 = ' num2str(fAValue2M3_2) ...
        ' a = ' num2str(fAValue2M3) ' b = ' num2str(fBValue2M3)];

% Model 4: Variable a, const. b-value from max. likelihood estimation of of
% entire catalog
vSel = (mSecondCatalog(:,6) >= fMcSecond);
mSecondComp = mSecondCatalog(vSel,:);
mControlM4 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1]
[fAValue2M4] = calc_MaxLikelihoodA_org(mSecondComp, mControlM4, fBValueOrg, 0);
% [fAValue2M4] = calc_MaxLikelihoodA(mSecondComp, fBValueOrg);
fBValue2M4 = fBValueOrg;
fP_modelM4 = fProbability;
nDegFreeM4 = 1;
sMod4 = ['Model 4: a = ' num2str(fAValue2M4) ' const. b = ' num2str(fBValueOrg)];

% Model 5: Variable a, const. b-value from max. likelihood estimation of b
% from second period
vSel = (mSecondCatalog(:,6) >= fMcSecond);
mSecondComp = mSecondCatalog(vSel,:);
mControlM5 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1]
[fAValue2M5] = calc_MaxLikelihoodA_org(mSecondComp, mControlM5, fBValueSecond, 0);
% [fAValue2M4] = calc_MaxLikelihoodA(mSecondComp, fBValueOrg);
fBValue2M5 = fBValueSecond;
fP_modelM5 = fProbability;
nDegFreeM5 = 1;
sMod5 = ['Model 5: a = ' num2str(fAValue2M5) ' const. b = ' num2str(fBValue2M5)];


% Bayesian Information Criteria (BIC) for model decision
% Take the one with the highest BIC value
%n_samples = length(fMcSecond:0.1:ceil(max(mSecondCatalog(:,6))));
n_samples = length(mSecondCatalog(:,6));
fBIC_1 = 2*fP_modelM1 + 2*log(n_samples)*nDegFreeM1;
fBIC_2 = 2*fP_modelM2 + 2*log(n_samples)*nDegFreeM2;
fBIC_3 = 2*fP_modelM3 + 2*log(n_samples)*nDegFreeM3;
fBIC_4 = 2*fP_modelM4 + 2*log(n_samples)*nDegFreeM4;
fBIC_5 = 2*fP_modelM5 + 2*log(n_samples)*nDegFreeM5;
sBIC = ['Model comparison: Model 1 BIC: ' num2str(fBIC_1) ';    Model 2 BIC: ' num2str(fBIC_2) '; '...
        ' Model 3 BIC: ' num2str(fBIC_3) ' Model 4 BIC: ' num2str(fBIC_4)...
        ' Model 5 BIC: ' num2str(fBIC_5)];

%% Display results
disp(sOrg);
disp(sPer1);
disp(sPer2);
disp(sMod1);
disp(sMod2);
disp(sMod3);
disp(sMod4);
disp(sMod5);
disp(sBIC);

%% Stretch factors from b-value ratios
fStretchM1 = fBValue/fBValue2M1;
fStretchM2 = fBValue/fBValue;
fStretchM3 = fBValue/fBValue2M3;
fStretchM4 = fBValue/fBValueOrg;
fStretchM5 = fBValue/fBValue2M5;

%% Result - Matrix
mRes = [];
mRes = [fAValue2M1 fBValue2M1 fBIC_1 fStretchM1; fAValue2M2 fBValue2M2 fBIC_2 fStretchM2; fAValue2M3 fBValue2M3 fBIC_3 fStretchM3];
mRes = [mRes; fAValue2M4 fBValue2M4 fBIC_4 fStretchM4; fAValue2M5 fBValue2M5 fBIC_5 fStretchM5];

vSel2 = (mRes(:,3) == min(mRes(:,3)));
vBestModel = mRes(vSel2,:)

%% Magnitude Shift and stretch for the best model
fMshift = vBestModel(:,4)*( vBestModel(:,1)- fAValue)/fBValue;
fStretch = vBestModel(:,4);
%% Rate factor
[fFactorHi, fStdHi, fResHi, fPerHi, fFactorLow, fStdLow, fResLow, fPerLow] = calc_ratefac(mFirstCatalog, mSecondCatalog,...
    fPeriod1, fPeriod2, fMc, fMcSecond)


%%% Result for events M >= Mc(Per1)
vSel1 = (mFirstCatalog(:,6) >= fMc);
mCat1ModelHi = mFirstCatalog(vSel1,:);
[vFMDModelHi, vNonCFMDModelHi] = calc_FMD(mCat1ModelHi);
vFMDModelHiFac = vFMDModelHi;
vNonCFMDModelHiFac =  vNonCFMDModelHi;
vFMDModelHiFac(2,:) = vFMDModelHi(2,:)*fFactorHi;
vNonCFMDModelHiFac(2,:) = vNonCFMDModelHi(2,:)*fFactorHi;
mCat1ModelHi(:,6) = vBestModel(:,4)*mCat1ModelHi(:,6) + fMshift;
[vFMDModelHi, vNonCFMDModelHi] = calc_FMD(mCat1ModelHi);


%%% Result for events M < Mc(Per1)
mCat1ModelLow = mFirstCatalog(~vSel1,:);

%%%%%%%%%%%%%% PLOTTING ROUTINE STUFF
if exist('new_fig','var') &  ishandle(new_fig)
    set(0,'Currentfigure',new_fig);
    disp('Figure exists');
else
    new_fig=figure_w_normalized_uicontrolunits('tag','bnew','Name','FMD and b-value fit','Units','normalized','Nextplot','add','Numbertitle','off');
    new_axs=axes('tag','ax_bnew','Nextplot','add','box','on');
end
subplot(3,1,1);
% axs1=findobj('tag','ax_bnew1');
% axes(axs1(1));
semilogy(vFMD(1,:), vFMD(2,:)/fPeriod1,'-d', 'Color', [0 0 1]);
hold on;
semilogy(vFMDSecond(1,:), vFMDSecond(2,:)/fPeriod2,'-*','Color', [0 0.5 0]);
semilogy(vFMDModelHiFac(1,:), vFMDModelHiFac(2,:)/fPeriod1,'-*','Color', [1 1 0]);
semilogy(vFMDModelHi(1,:), vFMDModelHi(2,:)/fPeriod1,'-*','Color', [1 0 0]);
sColor = 'b';
legend('1st period', '2nd period');
ylabel('Rate/year');
subplot(3,1,2);
% axs2=findobj('tag','ax_bnew2');
% axes(axs2(1));
semilogy(vNonCFMD(1,:), vNonCFMD(2,:)/fPeriod1,'-d', 'Color', [0 0 1]);
hold on;
semilogy(vNonCFMDModelHi(1,:), vNonCFMDModelHi(2,:)/fPeriod1,'*','Color', [1 0 0]);
semilogy(vNonCFMDSecond(1,:), vNonCFMDSecond(2,:)/fPeriod2,'-*','Color', [0 0.5 0]);
semilogy(vNonCFMDModelHiFac(1,:), vNonCFMDModelHiFac(2,:)/fPeriod1,'-*','Color', [1 1 0]);
ylabel('Rate/year');
subplot(3,1,3);
% axs2=findobj('tag','ax_bnew2');
% axes(axs2(1));
plot(vNonCFMD(1,:), vNonCFMD(2,:)/fPeriod1,'-d', 'Color', [0 0 1]);
hold on;
plot(vNonCFMDModelHi(1,:), vNonCFMDModelHi(2,:)/fPeriod1,'*','Color', [1 0 0]);
plot(vNonCFMDSecond(1,:), vNonCFMDSecond(2,:)/fPeriod2,'-*','Color', [0 0.5 0]);
plot(vNonCFMDModelHiFac(1,:), vNonCFMDModelHiFac(2,:)/fPeriod1,'-*','Color', [1 1 0]);
ylabel('Rate/year');
xlabel('Magnitude');

%%%% PLot 2
vMagnitudes = 0:0.1:max(mCatalog(:,6));
figure;
mPoly1 = [ -fBValue  fAValue];
vFuncPer1 = 10.^(polyval(mPoly1,vMagnitudes));
hPlot1= semilogy(vMagnitudes,vFuncPer1,'b:');
set(hPlot1, 'LineWidth', [2.0]);
hold on;
% txtInfoString = ['Max. Likelihood: a: ' num2str(fAValue) ', b: ' num2str(fBValue) ', std: ' num2str(fStdDev)];
% text(0.5, 0.6, txtInfoString, 'Color', [0 0 1]);
mPolyM1 = [ -fBValue2M1  fAValue2M1];
vFuncM1 = 10.^(polyval(mPolyM1,vMagnitudes));
semilogy(vMagnitudes,vFuncM1,'Color', [0 0.5 0]);
mPolyM2 = [ -fBValue  fAValue2M2];
vFuncM2 = 10.^(polyval(mPolyM2,vMagnitudes));
semilogy(vMagnitudes,vFuncM2,'Color', [0 0.5 0 ],'Linestyle','--');
mPolyM3 = [ -fBValue2M3  (fAValue2M3_1*3+fAValue2M3_2)/4];
vFuncM3 = 10.^(polyval(mPolyM3,vMagnitudes));
semilogy(vMagnitudes,vFuncM3,'Color', [0 0.5 0 ],'Linestyle',':');
mPolyM4 = [ -fBValueOrg  fAValue2M4];
vFuncM4 = 10.^(polyval(mPolyM4,vMagnitudes));
semilogy(vMagnitudes,vFuncM4,'Color', [0 0.5 0 ],'Linestyle','-.');
semilogy(vFMDSecond(1,:), vFMDSecond(2,:),'-*','Color', [0 0.5 0]);
semilogy(vFMDModelHi(1,:), vFMDModelHi(2,:),'-*','Color', [1 0 0]);
