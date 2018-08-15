function [fAphi] = calc_FaultStyle(rStress)
    % Determine the faulting style based on Quantifying Anderson's fault type
% [fAphi] = calc_FaultStyle(rStress)
% ------------------------------------------
% Determining the faulting style based on Quantifying Anderson's fault type
% by B. Simpson, 1997, JGR
%
% Incoming:
% rStress : Structure from script gui_NodeCalcStressInv giving stress
%           tensor inversion by Michael
% Output:
% fAphi   : 0 <= fAphi < 1 Normal faulting
%           1 <= fAphi < 2 Strike slip
%           2 <= fAphi < 3 Thrust faulting
%
% jowoe@gps.caltech.edu
% 19.05.2006

% Stress tensor from Michael inversion
mS=[rStress.fS11 rStress.fS12 rStress.fS13; rStress.fS12 rStress.fS22 rStress.fS23; rStress.fS13 rStress.fS23 rStress.fS33];

% Eigenvector; sorted from max. compressive to minimum (S1, S2, S3)
% Maximum compressive is the most negative value
vEig = eig(mS);

% Check for "most" vertical axis
vPlunge = [rStress.fS1Plunge; rStress.fS2Plunge; rStress.fS3Plunge];

vSel = (vPlunge == max(vPlunge));
fSigvert = vEig(vSel);

% This is because maximum compressive is negative
fSighmax = min(vEig(~vSel,:));
fSighmin = max(vEig(~vSel,:));

if fSighmax > fSigvert
    n = 0;
elseif fSigvert > fSighmin
    n = 2;
else
    n = 1;
end
% Formula 2, Simpson, JGR, 1997
fAphi = (n+0.5)+(-1)^n*(rStress.fPhi-0.5);
