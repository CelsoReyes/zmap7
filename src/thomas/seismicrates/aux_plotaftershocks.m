function aux_plotaftershocks(params, hParentFigure, fBeginAS, fEndAS)
% function aux_FMD(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
% fBeginAS      : Begin of aftershock sequence to plot
% fEndAS        : End of aftershock sequence to plot
%
% Th. van Stiphout, vanstiphout@sed.ethz.ch
% last update: 22.12.05

fBeginAS=1983
fEndAS=1986
vSel=((params.mCatalog(:,3) > fBeginAS) & (params.mCatalog(:,3) < fEndAS));

plot(params.mCatalog(vSel,1),params.mCatalog(vSel,2),'*')

hold on;


