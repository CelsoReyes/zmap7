function plot_StressVarBeta(vVariance,vBeta)
% function plot_StressVarBeta(vVariance,vBeta)
% --------------------------------------------
% Plot linearly the variance of the stress tensor versus the angle beta,
% representing the difference between the assumed direction of traction and the inverted
%
% Incoming variables:
% vVariance : Vector of Variance values
% vBeta     : Vector of Beta values
%
% j.woessner@sed.ethz.ch
% last update: 24.02.2005

% Deselect nans
vSel = (~isnan(vVariance) & ~isnan(vBeta));
vVariance = vVariance(vSel,:);
vBeta = vBeta.subset(vSel);

% Plot figure
figure
plot(vBeta,vVariance,'k^')
xlabel('\beta [degree]','FontSize',12,'Fontweight','bold')
ylabel('Variance','FontSize',12,'Fontweight','bold')
set(gca,'Linewidth',2,'FontSize',12,'Fontweight','bold')
