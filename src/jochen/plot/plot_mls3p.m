function plot_mls3p(vPar1, vPar2, vPar3, vMlsprob)
% function plot_mls2p(vPar1, vPar2, vPar3, vMlsprob);
% -------------------------------------------------------------------
% Plot maximum likelihood score (MLS) versus parameter space vPar1 and vPar2
% vPar1, vPar2 and vPar3 are e.g. a shift and a stretch and rate factor
%
% Incoming variable
% vPar1         : Vector of parameter 1 used in grid search (stretch)
% vPar2         : Vector of parameter 2 used in grid search (shift)
% vPar3         : Vector of parameter 3 used in grid search (rate factor)
% vMlsprob      : Maximum likelihood score for parameter combination
%                 (vPar1(x),vPar2(x),vPar3(x))
%
% See also plot_mls1p, plot_mls2p
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Determine where to plot
if exist('mls_fig','var') &  ishandle(mls_fig)
    set(0,'Currentfigure',mls_fig);
else
    mls_fig=figure_w_normalized_uicontrolunits('tag','mls','Name','Likelikehood scores','Units','normalized','Nextplot','add',...
        'Numbertitle','off');
    mls_axs=axes('tag','ax_mls','Nextplot','add','box','off');
end
set(gcf,'tag','mls');
set(gca,'tag','ax_mls','Nextplot','replace','box','off','visible','off');

% Constant: Minimum stretch
vSel = (vMlsprob == min(vMlsprob));
mVal = [vPar1 vPar2 vPar3 vMlsprob];
mMinVal =  mVal(vSel,:);
vSel2 = (mVal == mMinVal(1,1));
mVal_Par = mVal(vSel2(:,1),:);
[X_dS,Y_dS]=meshgrid(linspace(min(mVal_Par(:,2)),max(mVal_Par(:,2)),20),linspace(min(mVal_Par(:,3)),max(mVal_Par(:,3)),20));
Z_dS = griddata(mVal_Par(:,2),mVal_Par(:,3),log10(mVal_Par(:,4)),X_dS,Y_dS,'linear');
% surf(X_dS, Y_dS, Z_dS);

% Constant: Minimum shift
vSel = (vMlsprob == min(vMlsprob));
mVal = [vPar1 vPar2 vPar3 vMlsprob];
mMinVal =  mVal(vSel,:);
vSel2 = (mVal == mMinVal(1,2));
mVal_Par = mVal(vSel2(:,2),:);
[X_dM,Y_dM]=meshgrid(linspace(min(mVal_Par(:,1)),max(mVal_Par(:,1)),20),linspace(min(mVal_Par(:,3)),max(mVal_Par(:,3)),20));
Z_dM = griddata(mVal_Par(:,1),mVal_Par(:,3),log10(mVal_Par(:,4)),X_dM,Y_dM,'linear');

% Constant: Minimum rate factor
vSel = (vMlsprob == min(vMlsprob));
mVal = [vPar1 vPar2 vPar3 vMlsprob];
mMinVal =  mVal(vSel,:);
vSel2 = (mVal == mMinVal(1,3));
mVal_Par = mVal(vSel2(:,3),:);
[X_Rate,Y_Rate]=meshgrid(linspace(min(mVal_Par(:,1)),max(mVal_Par(:,1)),20),linspace(min(mVal_Par(:,2)),max(mVal_Par(:,2)),20));
Z_Rate = griddata(mVal_Par(:,1),mVal_Par(:,2),log10(mVal_Par(:,4)),X_Rate,Y_Rate,'linear');


% Plotting
subplot(2,2,1);
pcolor(X_dS, Y_dS, Z_dS);
sTxt_dS = ['Stretch: dS = ' num2str( mMinVal(1,1))];
title(sTxt_dS);
xlabel('dM');
ylabel('R_f');
subplot(2,2,2);
pcolor(X_dM, Y_dM, Z_dM);
sTxt_dS = ['Shift: dM = ' num2str( mMinVal(1,2))];
title(sTxt_dS);
xlabel('dS');
ylabel('R_f');
subplot(2,2,3);
pcolor(X_Rate, Y_Rate, Z_Rate);
sTxt_dS = ['Rate factor: R_f = ' num2str( mMinVal(1,3))];
title(sTxt_dS);
xlabel('dS');
ylabel('dM');
colorbar('vert');
subplot(2,2,4);
% Annotations
set(gca,'box','off', 'visible' ,'off');
sTxt = ['Minimum BIC: dM =' num2str(mMinVal(1,2)) ' , dS = ' num2str(mMinVal(1,1)) ' R_f = ' num2str(mMinVal(1,3))];
text(0,0.5,sTxt);
