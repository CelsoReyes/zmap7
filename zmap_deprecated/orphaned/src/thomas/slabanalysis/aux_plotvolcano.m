function aux_plotvolcano(params, hParentFigure)
% function aux_FMD(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% Thomas van Stiphout, thomas@sed.ethz.ch
% last update: 7.9.2005


report_this_filefun(mfilename('fullpath'));
hold on;plot3(-150,62,0,'r^','MarkerSize',15)
hold on;plot3([-150 -150],[62 62],[0 -200],'k','Linewidth',4)
