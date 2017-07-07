function [params]=aux_cs2(params,CS)
% function aux_FMD(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% nCS           : coordinates of cross section
% hParentFigure : Handle of the parent figure
%
% Thomas van Stiphout, thomas@sed.ethz.ch
% last update: 1.6.2006


report_this_filefun(mfilename('fullpath'));

disp('here we go for a cross section');
params.nDx=5;
params.nDy=5;

vSecLim1=[CS(1,1) CS(1,2)]
vSecLim2=[CS(1,3) CS(1,4)]
dist_=deg2km(distance(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1)));
azimuth_=azimuth(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1));

% round length of cross section to multiple of nDx
[vSecLim2(2),vSecLim2(1)]=reckon('gc',vSecLim1(2),vSecLim1(1),km2deg(params.nDx*(round(dist_/params.nDx))),azimuth_);

vDist_=km2deg(0:params.nDx:params.nDx*(round(dist_/params.nDx)))';
vOnes_=ones(length(vDist_),1);
mPolygon(:,1)=vSecLim1(1)*ones(length(vDist_),1);
mPolygon(:,2)=vSecLim1(2)*ones(length(vDist_),1);
vAzimuth_=azimuth_*vOnes_;
[params.vY, params.vX]=reckon('gc',mPolygon(:,2),mPolygon(:,1),vDist_,vAzimuth_(:));
vDepth_=[40:5:160]';
params.mPolygon=reshape(ones(length(vDepth_),1)*params.vX',length(vDepth_)*length(mPolygon),1);
% vOrigin_=(max(params.mPolygon)+min(params.mPolygon))./2;
% mOrigin_=ones(size(params.mPolygon(:,1),1),1)*vOrigin_;
% distance(mOrigin_(:,2),params.mPolygon(:,1),mOrigin_(:,2),mOrigin_(:,1));
params.mPolygon(:,2)=reshape(ones(length(vDepth_),1)*params.vY',length(vDepth_)*length(mPolygon),1);
params.mPolygon(:,3)=reshape(vDepth_*ones(1,size(mPolygon,1)),size(mPolygon,1)*size(vDepth_,1),1);


parmas.mValueGrid=params.mPolygon(:,3);
params.mValueGrid(isnan(params.mPolygon(:,3)),:)=nan;
params.mX=reshape(params.mPolygon(:,1),length(vDepth_),size(params.mPolygon,1)/length(vDepth_));
params.mY=reshape(params.mPolygon(:,2),length(vDepth_),size(params.mPolygon,1)/length(vDepth_));
params.mZ=reshape(params.mPolygon(:,3),length(vDepth_),size(params.mPolygon,1)/length(vDepth_));
[Nx,Ny,Nz]=surfnorm(params.mX,params.mY,-params.mZ);
% vAzimuth2_=repmat(vAzimuth_,1,size(params.mX,1))';
% vAzimuth2_=repmat(vAzimuth_,size(params.mPolygon(:,1),1)/size(vAzimuth_,1),1);
% [Y_, X_]=reckon('gc',params.mY,params.mX,ones(size(vAzimuth2_))*km2deg(30),vAzimuth2_+90);
% Nx=params.mX-X_;
% Ny=params.mY-Y_;
params.mT=reshape(Nx,size(params.mPolygon,1),1);
params.mT(:,2)=reshape(Ny,size(params.mPolygon,1),1);
params.mT(:,3)=reshape(Nz,size(params.mPolygon,1),1);

% mT_1=reshape(params.mT(:,1),17,23)
% mT_2=reshape(params.mT(:,2),17,23)
% mT_3=reshape(params.mT(:,3),17,23)
% hold on;quiver3(params.mX(:),params.mY(:),-params.mZ(:),mT_1,mT_2,mT_3,2,'r')

params.mValueGrid=params.mPolygon(:,3);

params.vUsedNodes=ones(size(params.mPolygon,1),1);
Name=cellstr('Cylindrical Volume Sampling');
for ii=1:length(Name)
    if strcmp(Name(ii),'Cylindrical Volume Sampling')
        disp(Name(ii));
        params.sComment=strcat(Name(ii),'; CS lon:',num2str(CS(1)),' lat:',num2str(CS(2)));
        [params.caNodeIndices2 params.vResolution2]=ex_CreateIndexCatalogCylinder(params.mCatalog,params.mPolygon,params.mT,...
            params.vUsedNodes,params.bCylSmpModeN,params.fCylSmpValue,params.fCylSmpBnd);
        if ((params.bCylSmpModeN==1) && (params.bCylSmpModeR==0))
            params.vcsGridNames(6) = cellstr(char('Resolution [R]'));
        else
            params.vcsGridNames(6) = cellstr(char('Resolution [N]'));
        end
    elseif strcmp(Name(ii),'3D Spherical Volume Sampling')
        disp(Name(ii));
        params.sComment=strcat(Name(ii),' Depth=',num2str(params.vPercentiles(nLayer)));
        % nGriddingMode = 3 means 3D sphere around polygonpoint
        params.nGriddingMode=3;
        % select
        % Create Indices to catalog and select quakes in time period
        [params.caNodeIndices2 params.vResolution2] = ex_CreateIndexCatalog3D(params.mCatalog, params.mPolygon, '1', params.n3DGriddingMode, ...
            params.f3DSmpValue, params.f3DSmpBnd, params.fSizeRectHorizontal, params.fSizeRectDepth);
        if ((params.b3DSmpModeN==1) && (params.b3DSmpModeR==0))
            params.vcsGridNames(6) = cellstr(char('Resolution [R]'));
        else
            params.vcsGridNames(6) = cellstr(char('Resolution [N]'));
        end
        % clear indices where not enough quakes for depth estimation
        for i=1:length(params.mPolygon)
            if isnan(params.mPolygon(i,3))
                params.caNodeIndices2{i}=[];
            end
        end
    else
        disp('Something is going wrong');
    end

    % for testing sampling volumes
    % hold on;i=300;plot3(params.mCatalog(params.caNodeIndices2{i},1),params.mCatalog(params.caNodeIndices2{i},2),-params.mCatalog(params.caNodeIndices2{i},7),'xr')

    % Calculation of bValue
    for i=1:length(params.mPolygon)
        if ~isempty(params.mCatalog(params.caNodeIndices2{i},:))
            % function [fBValue, fStdDev, fAValue, fMeanMag] =  calc_bvalue(mCatalog, fBinning)
            [params.mValueGrid(i,2),params.mValueGrid(i,3),params.mValueGrid(i,4),params.mValueGrid(i,5),] =  calc_bvalue(params.mCatalog(params.caNodeIndices2{i},:));
            params.mValueGrid(i,6)=max(params.vResolution2{i});
            % set values to NaN, when radius of sampling volume increase limit
            %             if (params.mValueGrid(i,6) > 20) %params.fCylSmp)
            %                 params.mValueGrid(i,2:5)=nan;
            %             end
        else
            % create NaN's in mValueGrid, where strike is not defined
            params.mValueGrid(i,:)=nan;
        end

    end





    params.vcsGridNames(1:6) = cellstr(char(...
        'Depth Level',...               %   1
        'b-Value',...                   %   2
        'Standard Deviation',...        %   3
        'A-Value',...                   %   4
        'Mean Magnitude',...            %   5
        'Resolution [km]'));            %   6

    params.bMap=3;
end



