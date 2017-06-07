function [fBetaBstMean, fBetaBstStd, mResult] = calc_beta_bootstrap(mCat,nBst,nSample)
% function [fBetaBstMean, fBetaBstStd, mResult] = calc_beta_bootstrap(mCat,nBst,nSample)
% -------------------------------------------------------------------------
%
% Calculate beta uncertainty for Michaels` Stress Tensor inversion approach boostrapping
% the Focal Mechanisms of the earthquake catalog mCat. This is a stability
% test of the method. No flipping of focal mechanisms included.
%
% Incoming
% mCat: EQ catalog or [dip direction dip rake]
% nBst: Number of boostraps
% nSample: Number of events from catalog to be used, default is all
%

if ~exist('nSample','var')
    nSample = length(mCat(:,1));
end

% Bootstrap event to be used
[nNy,nNx] = size(mCat);
if nNx > 3
    mCat = mCat(:,10:12);
end

% Bootstrap numbers
vNy = 1:1:nNy;
mBootstrap = bootrsp(vNy,nBst);

%Path
sZmapPath = './AddOneFiles/zmap/';

% Container for bootstrap beta values
mResult = [];

for nCnt = 1:1:nBst
    mCatBst = mCat(mBootstrap(1:nSample,nCnt),:);
    % Array of focal mechanisms: dip direction, dip, rake
    mFPS = mCatBst;

    % Do inversion using A. Michael code
    % Create file for inversion
    fid = fopen('data2','w');
    str = ['Inversion data'];str = str';
    fprintf(fid,'%s  \n',str');
    fprintf(fid,'%7.3f  %7.3f  %7.3f\n',mFPS');
    fclose(fid);
    % slick calculates the best solution for the stress tensor according to
    % Michael(1987): creates data2.oput
    sPath = pwd;
    unix([sZmapPath 'external/slick ' sPath '/data2 ']);

    % Get data from data2.oput
    sFilename = ['data2.oput'];
    % Calculate average angle between tangential traction predicted by best
    % stress tensor and the slip direction
    [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);

    % Delete existing from earlier runs data2.slboot
    sData2 = ['data2.slboot'];
    delete(sData2);

    % Stress tensor inversion
    unix([sZmapPath 'external/slfast ' sPath '/data2 ']);
    sGetFile = ['data2.slboot'];
    load(sGetFile);
    % Description of data2
    % Line 1: Variance S11 S12 S13 S22 S23 S33 => Variance and components of
    % stress tensor (S = sigma)
    % Line 2: Phi S1t S1p S2t S2p S3t S3p
    % Phi is relative size S2/S1, t=trend, p=plunge (other description)
    fVariance = data2(1,1);
%     fS11 = data2(1,2);
%     fS12 = data2(1,3);
%     fS13 = data2(1,4);
%     fS22 = data2(1,5);
%     fS23 = data2(1,6);
%     fS33 = data2(1,7);
    fPhi = data2(2,1);
    fS1Trend = data2(2,2);
    fS1Plunge = data2(2,3);
    fS2Trend = data2(2,4);
    fS2Plunge = data2(2,5);
    fS3Trend = data2(2,6);
    fS3Plunge = data2(2,7);
    % Container
    mResult = [mResult; fBeta fStdBeta fTauFit fAvgTau fStdTau fVariance fPhi fS1Trend fS1Plunge fS2Trend fS3Trend fS3Plunge];
end

% Bootstrap standar deviation
fBetaBstStd = calc_StdDev(mResult(:,1));
fBetaBstMean = mean(mResult(:,1));
