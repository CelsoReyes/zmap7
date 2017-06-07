function plot_mls2p(vPar1, vPar2, vMlsprob, nType)
% function plot_mls2p(vPar1, vPar2, vMlsprob, nType);
% -------------------------------------------------------------------
% Plot maximum likelihod score (MLS) versus parameter space vPar1 and vPar2
% vPar1 and vPar2 are e.g. a shift and a stretch
%
% Incoming variable
% vPar1    : Vector of parameter 1 used in grid search
% vPar2    : Vector of parameter 2 used in grid search
% vMlsprob : Maximum likelihood score for parameter combination (vPar1(x),vPar2(x))
% nType    : Parameter identification
%            1 = dS & dM (Combined shift and stretch)
%            2 = dS & Rate (Stretch and rate factor)
%            3 = dM & Rf (Shift and rate factor)
%
% See also plot_mls1p, plot_mls3p
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 30.10.02

switch nType
case 1
    sTitle = 'Combined magnitude shift and stretch';
    sX = 'dS';
    sY = 'dM';
case 2
    sTitle = 'Stretch and rate factor';
    sX = 'dS';
    sY = 'R_f';
case 3
    sTitle = 'Shift and rate factor';
    sX = 'dM';
    sY = 'R_f';
otherwise
    break;
end
sZ = 'log10(Likelihood score)';

% Determine where to plot
if exist('mls_fig','var') &  ishandle(mls_fig)
    set(0,'Currentfigure',mls_fig);
else
    mls_fig=figure_w_normalized_uicontrolunits('tag','mls','Name','3D Max. Likelikehood score','Units','normalized','Nextplot','add',...
        'Numbertitle','off');
    mls_axs=axes('tag','ax_mls','Nextplot','add','box','off');
end

% Plot3D
set(gcf,'tag','mls');
set(gca,'tag','ax_mls','Nextplot','replace','box','off','visible','off');
[X,Y]=meshgrid(linspace(min(vPar1),max(vPar1),20),linspace(min(vPar2),max(vPar2),20));
Z = griddata(vPar1,vPar2,log10(vMlsprob),X,Y,'linear');
surf(X,Y,Z);
shading interp
colorbar('horiz');
title(sTitle);
xlabel(sX);
ylabel(sY);
zlabel(sZ);

% Plot in plane
if exist('mls2_fig','var') &  ishandle(mls2_fig)
    set(0,'Currentfigure',mls2_fig);
else
    mls2_fig=figure_w_normalized_uicontrolunits('tag','mls2','Name','Max. Likelikehood score','Units','normalized','Nextplot','add',...
        'Numbertitle','off');
    mls2_axs=axes('tag','ax_mls2','Nextplot','add','box','off');
end

set(gcf,'tag','mls2');
set(gca,'tag','ax_mls2','Nextplot','replace','box','off','visible','off');
pcolor(X,Y,Z);
colorbar('horiz');
title(sTitle);
xlabel(sX);
ylabel(sY);
