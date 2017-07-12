function [result]=gui_NodeCalcStressInv(params,mCatalog)
% function [result]=gui_NodeCalcStressInv(params,mCatalog)
% --------------------------------------------------------
% Function to calculate stress inversion at a specific node
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% params       : See gui_CalcStressInv for parameters
%
% Outgoing variable:
% result.
%
% Author: J. Woessner
% j.woessner@sed.ethz.ch
% last update: 16.02.2005

% Init variable path has to be changed
result=[];
sZmapPath = './AddOneFiles/zmap/';

%get the computer type
% Array of focal mechanisms: dip direction, dip, rake
mFPS = [mCatalog(:,10:12)];
[nRow,nCol]=size(mFPS);
if nRow >= 999
    mFPS = mFPS(1:998,:);
end

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


%unix([sZmapPath 'external/slick ' sPath '/data2 ']);

%added support for different architectures
switch computer
    case 'GLNX86'
        unix([sZmapPath 'external/slick_linux ' sPath '/data2 ']);
    case 'MAC'
        unix([sZmapPath 'external/slick_macppc ' sPath '/data2 ']);
    case 'MACI'
        unix([sZmapPath 'external/slick_maci ' sPath '/data2 ']);
    case 'MACI64'
        unix([sZmapPath 'external/slick_maci64 ' sPath '/data2 ']);
    otherwise
        dos([sZmapPath 'external/slick.exe ' sPath '/data2 ']);
end

% Get data from data2.oput
sFilename = ['data2.oput'];
% Calculate avareage angle between tangential traction predicted by best
% stress tensor and the slip direction
[result.fBeta, result.fStdBeta, result.fTauFit, result.fAvgTau, result.fStdTau] = import_slickoput(sFilename);

% Delete existing from earlier runs data2.slboot
sData2 = ['data2.slboot'];
delete(sData2);

% Stress tensor inversion
%unix([sZmapPath 'external/slfast ' sPath '/data2 ']);

%added support for different architectures
switch computer
    case 'GLNX86'
        unix([sZmapPath 'external/slfast_linux ' sPath '/data2 ']);
    case 'MAC'
        unix([sZmapPath 'external/slfast_macppc ' sPath '/data2 ']);
    case 'MACI'
        unix([sZmapPath 'external/slfast_maci ' sPath '/data2 ']);
    case 'MACI64'
        unix([sZmapPath 'external/slfast_maci64 ' sPath '/data2 ']);
    otherwise
        dos([sZmapPath 'external/slfast.exe ' sPath '/data2 ']);
end





sGetFile = ['data2.slboot'];
load(sGetFile);
% Description of data2
% Line 1: Variance S11 S12 S13 S22 S23 S33 => Variance and components of
% stress tensor (S = sigma)
% Line 2: Phi S1t S1p S2t S2p S3t S3p
% Phi is relative size S2/S1, t=trend, p=plunge (other description)
result.fVariance = data2(1,1);
result.fS11 = data2(1,2);
result.fS12 = data2(1,3);
result.fS13 = data2(1,4);
result.fS22 = data2(1,5);
result.fS23 = data2(1,6);
result.fS33 = data2(1,7);
result.fPhi = data2(2,1);
result.fS1Trend = data2(2,2);
result.fS1Plunge = data2(2,3);
result.fS2Trend = data2(2,4);
result.fS2Plunge = data2(2,5);
result.fS3Trend = data2(2,6);
result.fS3Plunge = data2(2,7);

% Number of events
nY = mCatalog.Count;
result.nNumEvents = nY;

% Compute diversity
[fRms] = calc_FMdiversity(mCatalog(:,10),mCatalog(:,11),mCatalog(:,12));
result.fRms = fRms;

% Compute style of faulting
[fAphi] = calc_FaultStyle(result);
result.fAphi = fAphi;
