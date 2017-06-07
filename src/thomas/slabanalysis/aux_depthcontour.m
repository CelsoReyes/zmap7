function aux_depthcontour(params, hParentFigure)
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

% prepare Value that will be illustrated on the 3D surface defined above
 params.mPlotValues=ones(length(params.vUsedNodes),1)*nan;
 params.mPlotValues(params.vUsedNodes)=params.mValueGrid(:,1);
 vSel=~isnan(params.mValueGrid(:,1));
 vTmp=params.mValueGrid(:,1);
 vTmp(~vSel)=nan;
 params.mPlotValues(params.vUsedNodes)=vTmp;
 %       params.mPlotValues(params.mPlotValues == 0)=nan;
 params.mPlotValues=reshape(params.mPlotValues,length(params.vY),length(params.vX));
 mZ_=params.mZ;
 mZ_(isnan(params.mPlotValues))=nan;
 V_=-10:-20:-190;
 hold on;contour3(params.mX,params.mY,-mZ_,V_,'k--');
 V_=-0:-20:-200;
 hold on;contour3(params.mX,params.mY,-mZ_,V_,'k-');
 hold on;contour(params.mX,params.mY,-mZ_,'ShowText','on');
%  figure;surf(params.mX,params.mY,-mZ_,params.mPlotValues);
      view(3)
