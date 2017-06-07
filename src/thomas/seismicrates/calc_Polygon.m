function [mPolygon,vX,vY,vUsedNodes]=calc_Polygon(vLonLim,vLatLim,fdLon,fdLat)
% [params.mPolygon,params.vX,params.vY,params.vUsedNodes]=calc_Polygon(params.vLonLim,...
%     vLatLim,params.fdLon,params.fdLat);
% vLonLim=[-118 -115];
% vLatLim=[33 36];
% fdLon=0.05;
% fdLat=0.05;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vX=[vLonLim(1):fdLon:vLonLim(2)]';
vY=[vLatLim(1):fdLat:vLatLim(2)]';

for i=1:size(vX,1)
    for j=1:size(vY,1)
        mPolygon((i-1)*size(vY,1)+j,:)=[vX(i), vY(j)];
    end; % end j
end; % end i

vUsedNodes=logical(ones(size(mPolygon,1),1));

% disp('Your chosen grid has the following dimension:');
% sDisp=sprintf('%5.0f Nodes\n (X x Y = %5.0f x %5.0f)',...
%     size(mPolygon,1),size(vX,1),size(vY,1) );
% disp(sDisp);

clear fdLat fdLon i j sDisp vLatLim vLonLim
save mPolygonXX.mat * -mat
