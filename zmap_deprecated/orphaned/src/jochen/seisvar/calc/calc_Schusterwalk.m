function [mWalkout, fR95, fProb, PHI, R] = calc_Schusterwalk(mCatalog)
% function  [mWalkout, fR95, fProb, PHI, R] = calc_Schusterwalk(mCatalog)
% ------------------------------------------------------------------------
% Calculate random walkout (Schuster's method). See Rydelek & Sacks, Nature
% 1989.
%
% Incoming variables:
% mCatalog : EQ catalog
%
% Outgoing variables:
% mWalkout : Random walkout phases
% fR95     : Critical radius at 95% level
% fProb    : Probability to obtain vector of length >= R
% PHI      : Sum of phase angles
% R        : Possible maximum length of vector
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 13.03.03

% Get hours and minutes, calculate minutes
vH = mCatalog(:,8);
vMin = mCatalog(:,9);
vTime = vH*60+vMin;

% Calculate degrees and radians
vThetaDegree = vTime*180/720;
vThetaRad = vTime*pi/720;

mWalkout(1,1)=0;
mWalkout(1,2)=0;
for i=1:length(mCatalog(:,8))
    mWalkout(i+1,1)=mWalkout(i,1)+sin(vThetaRad(i));
    mWalkout(i+1,2)=mWalkout(i,2)+cos(vThetaRad(i));
end

A=sum(sin(vThetaRad));
B=sum(cos(vThetaRad));
R=sqrt(A^2+B^2);
PHI=atan(B/A);
% length(mCatalog(:,8))
% if mWalkout(length(mCatalog(:,8)),2)<0
%     PHI=PHI+pi;
% end

N=length(mCatalog(:,8));
% Critical radius at 95% confidence level
fR95=1.73*sqrt(N); % Rydelek & Sacks, Nature 1989
% Probability to obtain vector of length >= R from a random walkout
fProb=exp(-R^2/N);
