function [caIndices, vResolution] = ex_CreateCatalogCylinder(mCatalog,vGridpoint,vVector,vUsedNodes,bCylSmpModeN,fCylSmpValue,fCylSmpBnd)
% [params.caNodeIndices2 params.vResolution2]=ex_CreateIndexCatalogCylinder(params.mCatalog,params.mPolygon,params.mT,...
%                 params.vUsedNodes,params.bCylSmpModeN,params.fCylSmpValue,params.fCylSmpBnd)
% -------------------------------------------------------------------------------------------------------------
% Creates a cell-array with subcatalogs for every grid node defined by mPolygon. These subcatalogs
%   contain only indices to the earthquake "rows" in mCatalog.
%
% Input parameters:
%   mCatalog              Earthquake catalog
%   vGridpoint            contains gridpoints
%   vVector               contains cylinder axis
%   vUsedNodes            show only defined nodes
%   bCylSmpModeN          sampling for N (=1) or radius (=0)
%   fCylSmpValue          sampling value (N: bCylSmpModeN=1; r: bCylSmpModeN=0)
%   fCylSmpBnd            sampling limit (N: bCylSmpModeN=0; r: bCylSmpModeN=1)
%
% Output parameters:
%   caIndices             Indices for each grid node
%   vResolution           Resolution for each grid node
%
% Thomas van Stiphout
% February 28, 2006

fCylWidth=80
% Azimuth of strike
vPhi(1:sum(vUsedNodes))=azimuth(vGridpoint(:,2)-vVector(vUsedNodes,2),vGridpoint(:,1)-vVector(vUsedNodes,1),vGridpoint(:,2)+vVector(vUsedNodes,2),vGridpoint(:,1)+vVector(vUsedNodes,1));
vPhi=vPhi';
vPhi(isnan(vVector(vUsedNodes)))=nan;
% vTransf(:,:)=([[cosd(vPhi(:)), sind(vPhi(:)), -sind(vPhi(:)), cosd(vPhi(:))]]);
vTransf(:,:)=([[cosd(vPhi(:)), -sind(vPhi(:)), sind(vPhi(:)), cosd(vPhi(:))]]);

for i=1:length(vGridpoint)
    vTmpX(1:length(mCatalog),1)=vGridpoint(i,1);
    vTmpY(1:length(mCatalog),1)=vGridpoint(i,2);
    % distance in Lon and Lat direction of each earthquake to the actual gridpoint
    vXkm=(deg2km(distance(vTmpY,vTmpX,vTmpY,mCatalog(:,1))).*sign(vTmpX-mCatalog(:,1))).*sind(vGridpoint(i,2));
    vYkm=deg2km(distance(vTmpY,vTmpX,mCatalog(:,2),vTmpX)).*sign(vTmpY-mCatalog(:,2));
    fDz=vGridpoint(i,3)-mCatalog(:,7);
    %  rotate coordinate system
    Struc.mD{i}(:,:)=([[vTransf(i,1) vTransf(i,2)];[vTransf(i,3) vTransf(i,4)]]*[vXkm(:) vYkm(:)]')';
    % calculate distance from cylinder axis, thus radius of cylinder
    Struc.mD{i}(:,3)=sqrt(Struc.mD{i}(:,1).^2+fDz(:).^2);
%     Struc.mD{i}(:,3)=sqrt(Struc.mD{i}(:,2).^2+fDz(:).^2);
%   Switch btw different sampling mode / types of sampling volumes
    switch bCylSmpModeN
        case 0 % for constant radius
            vCylWidth=(Struc.mD{i}(:,2) < fCylWidth/2);
            Struc.mD{i}(:,4)=Struc.mD{i}(:,3).*vCylWidth;
            Struc.mD{i}(~vCylWidth,4)=nan;
            [Y, Struc.I{i}]= sort(Struc.mD{i}(:,4),1,'ascend');
            vCylRadius=(Struc.mD{i}(Struc.I{i},4) <= fCylSmpValue);
            Struc.I{i}=Struc.I{i}(vCylRadius);
            Struc.vResolution=Struc.mD{i}(vCylRadius,4);
        case 1   % for constant N
            vCylWidth=(abs(Struc.mD{i}(:,2)) < fCylWidth/2);
%             Struc.mD{i}(:,4)=sqrt(Struc.mD{i}(:,3).^2+Struc.mD{i}(:,1).^2);
            Struc.mD{i}(:,4)=Struc.mD{i}(:,3);
            Struc.mD{i}(~vCylWidth,:)=nan;
            [Y, Struc.I{i}]= sort(Struc.mD{i}(:,4),1,'ascend');
            % clear indices where strike is not defined
            if isnan(vPhi(i))
                Struc.I{i}=[];
            else
                Struc.I{i}=Struc.I{i}(1:fCylSmpValue,1);
                Struc.vResolution{i}=Struc.mD{i}(Struc.I{i},4);
                if (sum(isnan(Struc.vResolution{i}(:))) > 0)
                    Struc.vResolution{i}=[];
                    Struc.I{i}=[];
                end
            end
        case 3
            pause
    end
 end

 vResolution=Struc.vResolution;
 caIndices=Struc.I;
