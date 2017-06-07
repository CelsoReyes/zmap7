function [mWalkout, fR95, fProbR95, PHI, R] = calc_Schusterwalk(mCatalog)
% function  [mWalkout, fR95, fProbR95, PHI, R] = calc_Schusterwalk(mCatalog)
% ------------------------------------------------------------------------
% Calculate random walkout (Schuster's method). See Rydelek & Sacks, Nature
% 1989. Shows phazor plot for one catalog.
%
% Incoming variables:
% mCatalog : EQ catalog
%
% Outgoing variables:
% mWalkout : Random walkout phases
% fR95     : Critical radius at 95% level
% fProbR95 : Probability to obtain vector of length >= R
% PHI      : Sum of phase angles
% R        : Possible sum of vector length
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 12.02.03

% Get hours and minutes, calculate minutes
vH = mCatalog(:,8);
vMin = mCatalog(:,9);
vTime = vH*60+vMin;

% Calculate degrees and radians
vThetaDegree = vTime*180/720;
vThetaRad = deg2rad(vThetaDegree);

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
if mWalkout(length(mCatalog(:,8)),2)<0
    PHI=PHI+pi;
end

N=length(mCatalog(:,8));
% Critical radius at 95% level
fR95=1.37*sqrt(N); %Nature 1989
% Probability to obtain vector of length >= R
fProbR95=exp(-R^2/N);


figure_w_normalized_uicontrolunits('tag','schuster')
% Plot Schuster walkout
plot(mWalkout(:,1),mWalkout(:,2));
hold on;
polar([0:360]*pi/180,ones(1,361)*fR95,'r');
[x, y] =pol2cart(PHI,R);
plot([0,x],[0 y],'g');
plot ([0 0],[-1/5*fR95,1/5*fR95],'k');
plot ([-1/5*fR95,1/5*fR95],[0 0],'k');
hold off
text (0,2/5*fR95,'0:00','HorizontalAlignment','center');
text (2/5*fR95,0,'6:00','HorizontalAlignment','left');
text (0,-2/5*fR95,'12:00','HorizontalAlignment','center');
text (-2/5*fR95,0,'18:00','HorizontalAlignment','right');
text (0,fR95 ,'95KI','VerticalAlignment','bottom','HorizontalAlignment','center');
axis equal;
%xlim([-15 15])
%ylim([-15 15])
text (-fR95,-fR95,num2str(length(mCatalog(:,8))));

figure_w_normalized_uicontrolunits('tag','schuster2')
% Plot hourly histogram
subplot(2,1,1);
vTime = (mCatalog(:,8)*60+mCatalog(:,9))/60; % Calculate decimal hour
histogram(vTime,0:1:24)
% Plot FMD
subplot(2,1,2);
[mFMDC, mFMD] = calc_FMD(mCatalog);
plot(mFMDC(1,:),mFMDC(2,:),'ks',mFMD(1,:),mFMD(2,:),'k^');
