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


disp('here we go for a cross section');
view(0,90);
params2=params;
params.nDx=2;
params.nDy=2;

figure_w_normalized_uicontrolunits('PaperType','A4','PaperOrientation','Portrait','Position',[100,100,400,600],...
    'Name','cs')

bAutoCS=0;
if ~bAutoCS

    CS_=[[-154.1571 60.6191 -150.6693 60.1093];
         [-154.0081 60.8768 -150.4916 60.367];
         [-153.8591 61.1345 -150.3139 60.6247];
         [-153.7101 61.3922 -150.1362 60.8823];
         [-153.5611 61.6499 -149.9585 61.1399]];

%     CS_=[ [-154.10 60.45 -149.70 59.50];
%         [-153.78 60.90 -149.37 59.95];
%         [-153.40 61.30 -149.00 60.40];
%         [-153.05 61.75 -148.65 60.80];
%         [-152.70 62.15 -148.30 61.20] ];
elseif bAutoCS
    fSpacingCS=20;
    fLengthCS=200;
%     fLat1=59.85;fLon1=-152.40;fLat2=61.53;fLon2=-151.10;
%     fLat1=59.08;fLon1=-153.18;fLat2=61.55;fLon2=-151.52;
    fLat1=59.60;fLon1=-153.16;fLat2=61.57;fLon2=-151.72;
%     fLat1=59.60;fLon1=-152.86;fLat2=62.28;fLon2=-151.15;
    dist_=deg2km(distance(fLat1,fLon1,fLat2,fLon2));
    azimuth_=azimuth(fLat1,fLon1,fLat2,fLon2);
    [fLatEnd,fLonEnd]=reckon('gc',fLat1,fLon1,km2deg(fSpacingCS*(round(dist_/fSpacingCS))),azimuth_);
    vDist_=km2deg(0:fSpacingCS:fSpacingCS*(round(dist_/fSpacingCS)))';
    [vLatCenter,vLonCenter]=reckon('gc',ones(size(vDist_,1),1)*fLat1,ones(size(vDist_,1),1)*fLon1,vDist_,ones(size(vDist_,1),1)*azimuth_)
    [vLat1, vLon1] =reckon('gc',vLatCenter,vLonCenter,km2deg(ones(size(vLatCenter,1),1)*fLengthCS/2),ones(size(vLatCenter,1),1)*(azimuth_-90));
    [vLat2, vLon2] =reckon('gc',vLatCenter,vLonCenter,km2deg(ones(size(vLatCenter,1),1)*fLengthCS/2),ones(size(vLatCenter,1),1)*(azimuth_+90));
    CS_=[vLon1 vLat1 vLon2 vLat2]
end

% subplot(5,2,1);
% vXLim=[-155 -145];
% vYLim=[58 64];
% vIdXLim=(params.vVolcanoes(:,1) < vXLim(2)).*(params.vVolcanoes(:,1) > vXLim(1));
% vIdYLim=(params.vVolcanoes(:,2) < vYLim(2)).*(params.vVolcanoes(:,2) > vYLim(1));
% vId=(vIdXLim.*vIdYLim == 1);
% hold on;plot(params.vCoastline(:,1),params.vCoastline(:,2),'k')
% plot(params.vVolcanoes(vId,1),params.vVolcanoes(vId,2),'^r')
% % plot(params.vFaults(:,1),params.vFaults(:,2),'r')
figure_w_normalized_uicontrolunits('Name','cs_map')
plot(params.vCoastline(:,1),params.vCoastline(:,2),'k','LineWidth',1)
hold on;plot(params.vVolcanoes(:,1),params.vVolcanoes(:,2),'^r')
set(gca,'XLimMode','manual',...
    'YLimMode','manual',...
    'XLim',[-155 -149],...
    'YLim',[58 64]);

if size(CS_,1) > 12
    disp('********** Max No. of Cross Sections is set to 12 ************');
    nMaxCS=12;
else
    nMaxCS=size(CS_,1);
    str=sprintf('No. of Cross Sections is set to %s',num2str(nMaxCS));
    disp(str);
end
for nCs=1:nMaxCS
    % ask for coordinates
    vSecLim1=CS_(nCs,1:2)
    vSecLim2=CS_(nCs,3:4)
    figure_w_normalized_uicontrolunits(findobj('Name','cs_map'));
    hold on;plot([vSecLim1(1) vSecLim2(1)]',[vSecLim1(2); vSecLim2(2)]','k','LineWidth',2)
    % vSecLim1 = ginput(1);
    % vSecLim2 = ginput(1);
    dist_=deg2km(distance(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1)));
    azimuth_=azimuth(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1));

    [vSecLim2(2),vSecLim2(1)]=reckon('gc',vSecLim1(2),vSecLim1(1),km2deg(params.nDx*(round(dist_/params.nDx))),azimuth_);

    vDist_=km2deg(0:params.nDx:params.nDx*(round(dist_/params.nDx)))';
    vOnes_=ones(length(vDist_),1);
    mPolygon=vSecLim1(1)*ones(length(vDist_),1);
    mPolygon(:,2)=vSecLim1(2)*ones(length(vDist_),1);
    vAzimuth_=azimuth_*vOnes_;
    [params.vY, params.vX]=reckon('gc',mPolygon(:,2),mPolygon(:,1),vDist_,vAzimuth_(:));
    vDepth_=[40:2:120]';
    params.mPolygon=reshape(ones(length(vDepth_),1)*params.vX',length(vDepth_)*length(mPolygon),1);
    params.mPolygon(:,2)=reshape(ones(length(vDepth_),1)*params.vY',length(vDepth_)*length(mPolygon),1);
    params.mPolygon(:,3)=reshape(vDepth_*ones(1,size(mPolygon,1)),size(mPolygon,1)*size(vDepth_,1),1);


    parmas.mValueGrid=params.mPolygon(:,3);
    params.mValueGrid(isnan(params.mPolygon(:,3)),:)=nan;
    params.mX=reshape(params.mPolygon(:,1),length(vDepth_),size(params.mPolygon,1)/length(vDepth_));
    params.mY=reshape(params.mPolygon(:,2),length(vDepth_),size(params.mPolygon,1)/length(vDepth_));
    params.mZ=reshape(params.mPolygon(:,3),length(vDepth_),size(params.mPolygon,1)/length(vDepth_));
    [Nx,Ny,Nz]=surfnorm(params.mY,params.mX,-params.mZ);
    params.mT=reshape(Nx,size(params.mPolygon,1),1);
    params.mT(:,2)=reshape(Ny,size(params.mPolygon,1),1);
    params.mT(:,3)=reshape(Nz,size(params.mPolygon,1),1);


    params.mValueGrid=params.mPolygon(:,3);

    params.vUsedNodes=ones(size(params.mPolygon,1),1);
    Name=cellstr('Cylindrical Volume Sampling');
    for ii=1:length(Name)
        if strcmp(Name(ii),'Cylindrical Volume Sampling')
            disp(Name(ii));
            params.sComment=strcat(Name(ii),' Cross-Section Vertical');
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


        % Calculation of bValue
        for i=1:length(params.mPolygon)
            if ~isempty(params.mCatalog(params.caNodeIndices2{i},:))
                % function [fBValue, fStdDev, fAValue, fMeanMag] =  calc_bvalue(mCatalog, fBinning)
                [params.mValueGrid(i,2),params.mValueGrid(i,3),params.mValueGrid(i,4),params.mValueGrid(i,5),] =  calc_bvalue(params.mCatalog(params.caNodeIndices2{i},:));
                params.mValueGrid(i,6)=max(params.vResolution2{i});
            else
                % create NaN's in mValueGrid, where strike is not defined
                params.mValueGrid(i,1:6)=nan;
            end

        end





        params.vcsGridNames(1:6) = cellstr(char(...
            'Depth Level',...               %   1
            'b-Value',...                   %   2
            'Standard Deviation',...        %   3
            'A-Value',...                   %   4
            'Mean Magnitude',...            %   5
            'Resolution [km]'));            %   6

        % define position of gridpoint along cross section
        vAlongCS=deg2km(distance(ones(size(params.mPolygon,1),1)*params.mPolygon(1,2),...
            ones(size(params.mPolygon,1),1)*params.mPolygon(1,1),...
            params.mPolygon(:,2), params.mPolygon(:,1)));

        % Create Result Matrix
        params.mResultMatrix{nCs}=[params.mPolygon vAlongCS params.mValueGrid];
        params.vCS=deg2km(distance(ones(size(params.vY,1),1)*params.vY(1),...
            ones(size(params.vX,1),1)*params.vX(1),...
            params.vY, params.vX));

        % prepare for pcolor
        params.vZ=-params.mZ(:,1);
        [X,Y]=meshgrid(params.vCS,params.vZ);
%         vTmp=params.mResultMatrix{nCs}(:,6); % bValue
        vTmp=params.mResultMatrix{nCs}(:,10); % resolution
        vTmp((params.mResultMatrix{nCs}(:,10) > 20))=nan;
        Z=reshape(vTmp,size(X,1),size(X,2));
        % subplot
        figure_w_normalized_uicontrolunits(findobj('Name','cs'));
        subplot(3,2,nCs)
        pcolor(X,Y,Z);
%         set(gca,'CLim',[0.8,1.4]); % for b-Values
        set(gca,'CLim',[0, 40]); % for resolution
        colorbar('Location','East');
        str=sprintf('%s/%s to %s/%s ',num2str(vSecLim1(2)),num2str(vSecLim1(1)),num2str(vSecLim2(2)),num2str(vSecLim2(1)));
        title(str);
%         xlabel('Distance along Cross Section [km]');
%         ylabel('Depth [km]');
        % plot earthquakes
        % Select eq that belong to the sampling volume of this plane
        vTmp=[1:size(params.mCatalog,1)]';
        vEq=[params.caNodeIndices2{:}];
        vEq=reshape(vEq,size(vEq,1)*size(vEq,2),1);
        vIdxEq=ismember(vTmp,vEq);IdxEq=ismember(vTmp,vEq); % indices of the eqs that belong to this sampling volumes
        % determine the distance of the quakes in km from the origin of the cross section
        vXkm=deg2km(distance(ones(sum(vIdxEq),1)*vSecLim1(2),ones(sum(vIdxEq),1)*vSecLim1(1),ones(sum(vIdxEq),1)*vSecLim1(2),...
            params.mCatalog(vIdxEq,1)).*sign(ones(sum(vIdxEq),1)*vSecLim1(1)-params.mCatalog(vIdxEq,1)) )*(-1);
        vYkm=deg2km(distance(ones(sum(vIdxEq),1)*vSecLim1(2),ones(sum(vIdxEq),1)*vSecLim1(1),params.mCatalog(vIdxEq,2),...
            ones(sum(vIdxEq),1)*vSecLim1(1))).*sign(ones(sum(vIdxEq),1)*vSecLim1(2)-params.mCatalog(vIdxEq,2)) *(-1);
        % azimuth of cross section (multiplied by -1 to get right angle for transformation
        vPhi=-azimuth(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1));
        % calculate transformation matrix
        vTransf(:,:)=([[cosd(vPhi(:)), sind(vPhi(:)), -sind(vPhi(:)), cosd(vPhi(:))]]);
        vCS=([[vTransf(1,1) vTransf(1,2)];[vTransf(1,3) vTransf(1,4)]]*[vXkm(:) vYkm(:)]')';
        % plot earthquakes to the cross section
        hold on; plot(vCS(:,2),-params.mCatalog(vIdxEq,7),'.k','MarkerSize',0.5);
        shading interp

        params.bMap=2;
    end
end

save CrossSections.mat params;
