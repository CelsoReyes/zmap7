function [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename)
% function [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);
% ---------------------------------------------------------------------------
%
% Read measures of misfit computed for the stress tensor inversion from files
% sFilename.oput (usually data2.oput) produced with external/slick sFilename
% Reference:
% A. Michael, JGR, Vol. 96, No. B4, 6303-6319, Spatial variation in stress
% within the 1987 Whittier Narrows, CA, aftershock sequence: New techniques
% and Results
%
% Input variables:
% sFilename : String of the file name
%
% Output variables:
% fBeta    : Angle between observed slip direction and and predicted
%            tangential traction averaged over the slip data
% fStdBeta : Standard deviation of fBeta
% fTauFit  : Spread of fAvgTau over the data set; the smaller (=0) the
%            better
% fAvgTau  : Size of the traction that actually should be =1 due to the
%            assumption of the method
% fStdTau  : Standard deviation of fAvgTau
%
% last update: J. Woessner, 02.03.04

% Open file
hFile = fopen(sFilename, 'r');
while ~feof(hFile)
    sLine = fgetl(hFile);
    % Ignore empty line
    if ~isempty(sLine)
        % Check for beta
        if sLine(1:2) == 'fi'
            sBeta = sLine(17:24);
            [fBeta, nCnt] = sscanf(sBeta, '%8f');
            try
                sStdBeta = sLine(47:52);
                [fStdBeta, nCnt] = sscanf(sStdBeta, '%7f');
            catch
                fStdBeta = nan;
            end
        end
        if sLine(1:3) == 'avg'
            sAvgTau = sLine(10:17);
            [fAvgTau, nCnt] = sscanf(sAvgTau, '%8f');
            try
                sStdTau = sLine(32:37);
                [fStdTau, nCnt] = sscanf(sStdTau, '%6f');
            catch
                fStdTau = nan;
            end
        end
    end
end
fclose(hFile);

% Check for Tau determination
if isempty(fAvgTau)
    disp('Tau not determined!')
    fAvgTau = nan;
end
if isempty(fStdTau)
    fStdTau = nan;
end

% Calculate spread of fAvgTau
if (~isnan(fAvgTau) & ~isnan(fStdTau))
    fTauFit = fStdTau/fAvgTau;
else
    fTauFit = nan;
end
