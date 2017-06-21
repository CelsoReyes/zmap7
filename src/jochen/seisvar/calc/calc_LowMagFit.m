function calc_LowMagFit(mCatalog, fBinning)
% function calc_LowMagFit(mCatalog, fBinning);
% --------------------------------------------
% Determine Mc using maximum likelihood score
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Binning interval, usually 0.1
%
% Outgoing variables:
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 11.11.02

% Initialize
fMinMag = floor(min(mCatalog(:,6)));
if fMinMag > 0
  fMinMag = 0;
end
fMaxMag = ceil(10 * max(mCatalog(:,6))) / 10;
nCalculateMC =5;

vNCumTmp = [];
% Calculate max. likelihood b-value, use powerlaw to determinea-value
[vFMD, vNonCFMD] = calc_FMD(mCatalog);
%fMc = calc_Mc(mCatalog, nCalculateMC)
fMc = 1.2
[nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
[fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog(vSel,:), fBinning);
% Compute quantity of earthquakes by power law
vMstep = [fMinMag:0.1:fMaxMag];
vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number
% Compute non-cumulative numbers
fNCumTmp = 10^(fAValue-fBValue*(fMaxMag+0.1));
vNCumTmp  = [vNCum fNCumTmp];
vN = abs(diff(vNCumTmp));
% Calculate difference between real and synthetic magnitude distribution
vFMD = fliplr(vFMD);
vMagDiffCum = vNCum-vFMD(2,:);
vNonCFMD = fliplr(vNonCFMD);
vMagDiff = vN-vNonCFMD(2,:);

% Data selection below Mc
mData = [vMagDiff' vN' vNonCFMD'];
vSel = (mData(:,3) < fMc);
mData = mData.subset(vSel);

% Curve fitting: Non cumulative part below Mc
options = optimset;
options = optimset('Display','iter','Tolfun',1e-6,'TolX',0.0001);
% Entire data
[vX, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay2,[mData(1,4) 1], mData(:,3), mData(:,4))
yy = vX(1).*exp(vX(2).*mData(:,3))-1;
figure_w_normalized_uicontrolunits(20)
plot(mData(:,3), yy, mData(:,3), mData(:,4))

% % Curve fitting: Non cumulative part
% options = optimset;
% options = optimset('Display','iter','Tolfun',1e-6,'TolX',0.0001);
% % Entire data
% [vX, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay,[max(vMagDiff) 2], vNonCFMD(1,:),...
%     vMagDiff,[max(vMagDiff)-1000 1.5],[max(vMagDiff)+1000 2.6],options)
% yy=vX(1)*exp(-vX(2)*vNonCFMD(1,:));
% % vDiff = abs(vMagDiff-yy);
% % vFit = (vDiff./vNonCFMD(2,:)).*100-100;
% % [vX2, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay2,[max(vMagDiff) 2 1 0] ,vNonCFMD(1,:),...
% %     vMagDiff)
% % yy2=vX2(1)*exp(-vX2(2).*vNonCFMD(1,:))+vX2(3)*exp(vX2(4).*vNonCFMD(1,:));
% % Magnitudes below Mc
% % [vXl,resnorml, residl, exitflagl]=lsqcurvefit(@calc_expdecay,[max(mData(:,1)) 2], mData(:,3),...
% %     mData(:,1),[max(mData(:,1))-1000 1.5],[max(mData(:,1))+1000 2.6],options)
% % yy3=vX(1)*exp(-vX(2)*mData(:,1));
% [vXl,resnorml, residl, exitflagl]=lsqcurvefit(@calc_expdecay2,[sqrt(max(mData(:,1))) 2 1 ], mData(:,3),...
%     mData(:,1))%,[max(mData(:,1))-1000 1.5],[max(mData(:,1))+1000 2.6],options)
% yy3 = vXl(1)+vXl(2).*mData(:,1)+vXl(3).*(mData(:,1)).^2;
% figure_w_normalized_uicontrolunits(300)
% semilogy(vMstep,vNCum,'*',vFMD(1,:), vFMD(2,:),'^', vNonCFMD(1,:), vNonCFMD(2,:),'+',vMstep,vN,'o')
% hold on;
% semilogy(vNonCFMD(1,:),vN-yy,'ro')
% figure_w_normalized_uicontrolunits(400)
% plot(vNonCFMD(1,:),vMagDiff,'+')
% hold on;
% plot(vNonCFMD(1,:),yy,'g')
% % plot(vNonCFMD(1,:),yy2,'--r')
% figure_w_normalized_uicontrolunits(500)
% plot(mData(:,3),mData(:,1),'g*', mData(:,3), yy3, '-k')
% % figure_w_normalized_uicontrolunits(600);
% % plot(vNonCFMD(1,:),vFit,'k^');

% % Curve fitting: Cumulative
% options = optimset;
% options = optimset('Display','iter','Tolfun',1e-4,'TolX',0.01);
% % Entire data
% [vX, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay,[max(vMagDiff) 2], vFMD(1,:),...
%     vMagDiffCum,[max(vMagDiffCum)-1000 1.5],[max(vMagDiffCum)+1000 2.6],options)
% yy=vX(1)*exp(-vX(2)*vFMD(1,:));
%
% % [vX, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay,[max(vFMD(2,:)) 1 1], vFMD(1,:),...
% %     vFMD(2,:), [max(vFMD(2,:))-1000 0.8 -1],[max(vFMD(2,:))+1000 1.4 100],options);
% % yy = vX(1)-vX(2).*vFMD(1,:)-vX(3).*10.^(vX(2).*vFMD(1,:));
% % [vX2, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay2,[max(vMagDiff) 1] ,vNonCFMD(1,:),...
% %     vMagDiff);
% % yy2=vX2(1)*10.^(vX2(2).*vNonCFMD(1,:));
% % vX
% % vX2
% figure_w_normalized_uicontrolunits(300);
% semilogy(vFMD(1,:), vFMD(2,:),'^',vFMD(1,:),vNCum);
% figure_w_normalized_uicontrolunits(400)
% semilogy(vFMD(1,:),vMagDiffCum,'r*',vFMD(1,:),yy,'--g',vFMD(1,:),vFMD(2,:)-yy,'--k')
% % hold on;
% % semilogy(vNonCFMD(1,:),vN,'ro')


