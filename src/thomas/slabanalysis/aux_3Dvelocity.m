function aux_cs(params, hParentFigure)
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


disp('her we go for plotting velocity structure');

vp3D=load('~/Alaska/3d/PS/REAL/Inv6/VP1/vpvs3D.xyz');
min_=min(vp3D);
max_=max(vp3D);
[Y,I]=sort(vp3D(:,4),1,'ascend');
dX_=vp3D(I(2),3)-vp3D(I(1),3);
nX_=((max_(3)-min_(3))/dX_)+1
[Y,I]=sort(vp3D(:,3),1,'ascend');
dY_=vp3D(I(2),4)-vp3D(I(1),4);
nY_=((max_(4)-min_(4))/dY_)+1
nZ_=size(vp3D,1)/(nY_*nX_)
mLon_=reshape(vp3D(:,1),nX_,nY_,nZ_);
mLat_=reshape(vp3D(:,2),nX_,nY_,nZ_);
mZ_=reshape(vp3D(:,5),nX_,nY_,nZ_);
mC_=reshape(vp3D(:,6),nX_,nY_,nZ_);
mZ_=-1*mZ_;
hold on;
p = patch(isosurface(mLon_,mLat_,mZ_,mC_,1.76));
set(p,'FaceColor','red','EdgeColor','none');

view(3);




