function [fMc, fProbability, mResult] =  calc_SchusterMc(mCatalog,fMagIncr, fMinMag, fMaxMag)
% function [fMc, fProbability, mResult] =  calc_SchusterMc(mCatalog,fMagIncr, fMinMag, fMaxMag)
% ---------------------------------------------------------------------------------------------
% Determine the magnitude of completness using Schuster's Method objectively.
% Philosophy: Detect if walkout > 95% significance level two times, then set upper magnitude as Mc.
% If that happens more times, choose the smaller magnitude!
%
% Incoming variables:
% mCatalog : EQ catalog
%
% Outgoing variables:
% fMc          : Magnitude of completeness
% fProbability : Probability of exceeding the 95% level radius
% mResult      : Result matrix for all cases
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 04.06.02

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fMagIncr = 0.4, fMinMag = min(mCatalog(:,6))*10/10, fMaxMag = max(mCatalog(:,6))
    disp('Default values: Increment = 0.4, Minimum and Maximum magnitude of catalog');end;
if nargin == 2, fMinMag = min(mCatalog(:,6))*10/10, fMaxMag = max(mCatalog(:,6))
    disp('Default values: Minimum and Maximum magnitude of catalog'); end
if nargin == 3, fMaxMag = max(mCatalog(:,6)), disp('Default value: Maximum magnitude of catalog'); end
if nargin > 4, error('incorrect number of argumenents'); end



% Initialize
mResult = [];

fMag=fMinMag;

while (fMag+fMagIncr) < (fMaxMag)
    vSel = (mCatalog(:,6) >= fMag & mCatalog(:,6) < fMag+fMagIncr);
    mCat = mCatalog(vSel,:);
    [mWalkout, fR95, fProb, PHI, R] = calc_Schusterwalk(mCat);
    [vThetaWalkout,vRadWalkout] = cart2pol(mWalkout(:,1),mWalkout(:,2));
    fMaxRadius = max(abs(vRadWalkout(:,1)));
    mResult = [mResult; fMag+fMagIncr, fMaxRadius, max(abs(mWalkout(:,1))), max(abs(mWalkout(:,2))), fR95, fProb, R];
    fMag= fMag+0.1;
end % END of WHILE

try
    % Select walkout > 95% level
    vSel = (mResult(:,2) >= mResult(:,5));
    mResOut = mResult(vSel,:);
    mDiffResOut=diff(mResOut);
    mDiffResOut(:,1) = round(mDiffResOut(:,1)*10)/10;
    [vIndice]=find(mDiffResOut(:,1) == 0.1);
    if isempty(vIndice)
        fMc = nan;
        fProbability = nan;
    else
        fMc = mResult(max(vIndice)+2,1); % Maximum value for Mc
        fProbability = mResult(max(vIndice)+2,6);
        for nCnt=length(vIndice):-1:2
            fdI = vIndice(nCnt)-vIndice(nCnt-1);
            if fdI > 1
                fMc = mResult(vIndice(nCnt-1)+2,1); % Find Mc
                fProbability = mResult(max(vIndice)+2,6);
            end
        end
    end
catch
    fMc = nan;
    fProbability = nan;
end
