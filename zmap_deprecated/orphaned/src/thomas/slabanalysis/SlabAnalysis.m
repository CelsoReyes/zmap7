function SlabAnalysis(mCatalog,vCoastlines,vFaults,vVolcano)
% % Example: SlabAnalysis(a,coastline,faults,vo)
% -------------------------------------------------------------------------------------------------------------
% Creates a cell-array with subcatalogs for every grid node defined by mPolygon. These subcatalogs
%   contain only indices to the earthquake "rows" in mCatalog.
%
% Input parameters:
%   params.mCatalog             Earthquake catalog
%   params.vCoastlines          Coastlines
%   params.vFaults              Faults
%   params.vVolcano             Volcano
%
% Output parameters:
%   none
%
% Thomas van Stiphout
% February 28, 2006
% -------------------------------------------------------------------------------------------------------------
%


if ~strcmp(get(gcf,'name'),'3DResult plot')
% Launch GUI
hMenuFig = gui_slab;
handles = guidata(hMenuFig);

% Analyze Output
if ~ishandle(hMenuFig)
    %     handles.answer = 0;
elseif (handles.answer==0)
    disp('Canceled SlabAnalysis - Goodbye');
elseif (handles.answer==1)
    % define equidistance btw gridpoints
    params.nDx=str2double(get(handles.nDx,'String'));
    params.nDy=params.nDx;
    % Define the percentile of the depth values
    params.vPercentiles=str2double(get(handles.vPerc,'String'));
    % Radius for Map-Gridding for Columns
    params.fColRadius=str2double(get(handles.fRadius,'String'));
    % Minimum number of events that have to be in the column
    params.nColMinEvents=str2double(get(handles.nMinColEvents,'String'));
    % Volume sampling is cylindrical
    params.bCylSmp=get(handles.chkCylSmp,'Value');
    params.bCylSmpModeN=get(handles.radCylSmpModeN,'Value');
    params.bCylSmpModeR=get(handles.radCylSmpModeR,'Value');
    params.fCylSmpValue=str2double(get(handles.fCylSmpValue,'String'));
    params.fCylSmpBnd=str2double(get(handles.fCylSmpBnd,'String'));
    if ((params.bCylSmpModeN==1) && (params.bCylSmpModeR==0))
        params.nGriddingMode=1; % constant numbers
        params.nNumberEvents=params.fCylSmpValue;
    elseif ((params.bCylSmpModeN==0) && (params.bCylSmpModeR==1))
        params.nGriddingMode=0; % constant radius
    else
        disp('Something is going wrong');
    end
    % Volume sampling is 3D-spherical
    params.b3DSmp=get(handles.chk3DSmp,'Value');
    params.b3DSmpModeN=get(handles.radCylSmpModeN,'Value');
    params.b3DSmpModeR=get(handles.radCylSmpModeR,'Value');
    params.f3DSmpValue=str2double(get(handles.fCylSmpValue,'String'));
    params.f3DSmpBnd=str2double(get(handles.fCylSmpBnd,'String'));
    if ((params.bCylSmpModeN==1) && (params.bCylSmpModeR==0))
        params.n3DGriddingMode=3; % constant numbers
        params.nNumberEvents=params.fCylSmpValue;
    elseif ((params.bCylSmpModeN==0) && (params.bCylSmpModeR==1))
        params.n3DGriddingMode=4; % constant radius
    else
        disp('Something is going wrong');
    end
    %     close(get(handles.figure1,'Name'));

    if (params.bCylSmp==1)
        if ~exist('Name')
            Name=cellstr('Cylindrical Volume Sampling');
        else
            Name(size(Name,1)+1,1)=cellstr('Cylindrical Volume Sampling');
        end
    end
    if params.b3DSmp
        if ~exist('Name')
            Name=cellstr('3D-Spherical Volume Sampling');
        else
            Name(size(Name,1)+1,1)=cellstr('3D Spherical Volume Sampling');
        end
    end

    params.Name=Name;
    params.mCatalog=mCatalog;
    params.vCoastline=vCoastlines;
    params.vFaults=vFaults;
    params.vVolcanoes=vVolcano;
    params.chkVolcanoes=1;

    clear mCatalog vCoastlines vFaults vVolcano
    % Create grid
    params.bMap=1;
    params.nGriddingMode=1;
    params.fSizeRectHorizontal=nan;
    params.fSizeRectDepth=nan;
    params.fSizeRectHorizontal=nan;
    params.fSizeRectDepth=nan;


    % Create map-gridding
    % by defining equidistance btw gridpoints


    % Short distance conversion
    params.fDLon=km2deg(params.nDx);
    params.fDLat=km2deg(params.nDy);
    %
    hFigure=gcf;

    % Select grid from seismicity map
    [params.mPolygon, params.vX, params.vY, params.vUsedNodes] = ex_selectgrid(hFigure, params.fDLon, params.fDLat, 0);

    % Sampling Radius is set equally to the grid raster; indices for each grid point
    [params.caNodeIndices params.vResolution] = ex_CreateIndexCatalog2(params.mCatalog, params.mPolygon, 1, 1, ...
        [], params.fColRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);

    % preparing the matrix containing the depth-levels according to the
    % percentiles defined
    params.mDepths=ones(length(params.mPolygon),length(params.vPercentiles))*nan;
    params.mValueGrid=ones(length(params.mPolygon),1)*nan;

    % calculation the depths-levels according to the percentiles for each gridpoint
    for i=1:length(params.mPolygon)
        params.mDepths(i,:)=prctile(params.mCatalog(params.caNodeIndices{i},7),params.vPercentiles) ;
        %     params.mValueGrid(i)=length(params.mCatalog(params.caNodeIndices{i}));
    end


    % Take only depth values that are well constrained,
    % i.e. with at least 50 earthquakes per map-node; set others to NaN
    params.mDepths((params.vResolution <= params.nColMinEvents),:)=nan;
    % Create polygon with with slab-surface values x,y,z
end
delete(hMenuFig);

elseif strcmp(get(gcf,'name'),'3DResult plot')
    disp('here we go for a cross section');
    view(0,90);
    vSecLim1 = ginput(1)
    vSecLim2 = ginput(1)
    dist_=deg2km(distance(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1)));
    azimuth_=azimuth(vSecLim1(2),vSecLim1(1),vSecLim2(2),vSecLim2(1));




    view(3);
end
for nLayer=1:length(params.vPercentiles);
    params.mPolygon(:,3)=params.mDepths(:,nLayer);
    % overgive depth values to the result-matrix
    params.mValueGrid(:,1)=params.mDepths(:,nLayer);

    for i=1:length(params.vY)
        params.mX(i,:)=params.vX;
    end
    for i=1:length(params.vX)
        params.mY(:,i)=params.vY;
    end


    params.mValueGrid(isnan(params.mPolygon(:,3)),:)=nan;

    % prepare 3D figure by reshaping
    params.mX=reshape(params.mX,length(params.vUsedNodes),1);
    params.mY=reshape(params.mY,length(params.vUsedNodes),1);
    params.mZ=ones(length(params.vUsedNodes),1)*nan;
    params.mZ(params.vUsedNodes)=params.mValueGrid(:,1);
    params.mX=reshape(params.mX,length(params.vY),length(params.vX));
    params.mY=reshape(params.mY,length(params.vY),length(params.vX));
    params.mZ=reshape(params.mZ,length(params.vY),length(params.vX));

    % transform spherical coordinates to xyz-coordinates
    % by applying distances-command

    % center of data as reference/origin point
    fOriginX_=(max(max(params.mX))+min(min(params.mX)))./2;
    fOriginY_=(max(max(params.mY))+min(min(params.mY)))./2;
    mOriginX_=ones(size(params.mX))*fOriginX_;
    mOriginY_=ones(size(params.mX))*fOriginY_;

    mYkm=deg2km(distance(params.mY,mOriginX_,mOriginY_,mOriginX_)).*sign(params.mY-mOriginY_);
    mXkm=deg2km(distance(mOriginY_,params.mX,mOriginY_,mOriginX_))*sin(deg2rad(fOriginY_)).*sign(params.mX-mOriginX_);

    % mZkm=ones(size(params.mZ))*50
    mZkm=params.mZ;

    % mZkm=ones(size(params.mZ))*50
    % mZkm(isnan(params.mZ))=nan
    % surfnorm(mXkm,mYkm,-mZkm);

    [mNxkm,mNykm,mNzkm]=surfnorm(mXkm,mYkm,-mZkm);

    % make figure
    % figure;
    % surf(params.mX,params.mY,-params.mZ);
    % surf(params.mX,params.mY,-params.mZ);
    % colorbar;
    % set(gca,'CLim',[0.6 1.4]);
    % box on
    % hold on; plot3(params.mPolygon(:,1),params.mPolygon(:,2),-params.mPolygon(:,3),'s','MarkerSize',5);
    [mNx,mNy,mNz]=surfnorm(params.mX,params.mY,-params.mZ);
    [mNxkm,mNykm,mNzkm]=surfnorm(mXkm,mYkm,-mZkm);
    % determin the gradient of the slab at each grid point
    [mGx,mGy]=gradient(params.mZ);
    [mGxkm,mGykm]=gradient(params.mZ);
    mGz=zeros(size(mGx,1),size(mGx,2));
    mGzkm=zeros(size(mGxkm,1),size(mGxkm,2));
    % take only valid gridpoints
    % mGx(isnan(mNx))=nan; mGy(isnan(mNx))=nan; mGz(isnan(mNx))=nan;

    vGx=reshape(mGx,size(mGx,1)*size(mGx,2),1);vGy=reshape(mGy,size(mGy,1)*size(mGy,2),1);vGz=reshape(mGz,size(mGz,1)*size(mGz,2),1);
    vNx=reshape(mNx,size(mNx,1)*size(mNx,2),1);vNy=reshape(mNy,size(mNy,1)*size(mNy,2),1);vNz=reshape(mNz,size(mNz,1)*size(mNz,2),1);
    % same for kmgrid
    vGxkm=reshape(mGxkm,size(mGxkm,1)*size(mGxkm,2),1);vGykm=reshape(mGykm,size(mGykm,1)*size(mGykm,2),1);vGzkm=reshape(mGzkm,size(mGzkm,1)*size(mGzkm,2),1);
    vNxkm=reshape(mNxkm,size(mNxkm,1)*size(mNxkm,2),1);vNykm=reshape(mNykm,size(mNykm,1)*size(mNykm,2),1);vNzkm=reshape(mNzkm,size(mNzkm,1)*size(mNzkm,2),1);

    mask=(~isnan(vGx) .* ~isnan(vGy) .* ~isnan(vGz) .* ~isnan(vNx) .* ~isnan(vNy) .* ~isnan(vNy));
    vGx(~mask)=nan;vGy(~mask)=nan;vGz(~mask)=nan;vNx(~mask)=nan;vNy(~mask)=nan;vNz(~mask)=nan;
    % same for km-grid
    mask=(~isnan(vGxkm) .* ~isnan(vGykm) .* ~isnan(vGzkm) .* ~isnan(vNxkm) .* ~isnan(vNykm) .* ~isnan(vNykm));
    vGxkm(~mask)=nan;vGykm(~mask)=nan;vGzkm(~mask)=nan;vNxkm(~mask)=nan;vNykm(~mask)=nan;vNzkm(~mask)=nan;
    % create a vector perpendicular to the surface define by the normal and the
    % gradient, mT is tangent and represents the axes of the sampling cylinder.
    params.mT=cross([vGx vGy vGz],[vNx vNy vNz]);
    % same for km-grid
    mTkm=cross([vGxkm vGykm vGzkm],[vNxkm vNykm vNzkm]);
%     hold on;quiver3(mXkm(:),mYkm(:),-mZkm(:),mTkm(:,1),mTkm(:,2),mTkm(:,3),2,'r');
    % hold on;quiver3(params.mX(:),params.mY(:),-params.mZ(:),params.mT(:,1),params.mT(:,2),params.mT(:,3),2,'r');
    % params.mT=params.mT(params.vUsedNodes,:)

    % we only want to have horizontal cylinder axis
    params.mT(~isnan(params.mT(:,3)),3)=0;

    for ii=1:length(Name)
        if strcmp(Name(ii),'Cylindrical Volume Sampling')
            disp(Name(ii));
            params.sComment=strcat(Name(ii),' Depth=',num2str(params.vPercentiles(nLayer)));
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
                params.mValueGrid(i,:)=nan;
            end

        end





        params.vcsGridNames(1:5) = cellstr(char(...
            'Depth Level',...               %   1
            'b-Value',...                   %   2
            'Standard Deviation',...        %   3
            'A-Value',...                   %   4
            'Mean Magnitude'));             %   5

        params.bMap=2;
        params.mValueGrid(isnan(params.mValueGrid(:,1)),:)=nan;
        vResults((nLayer-1)*length(Name)+ii)=params;

    end
end
save vResults
gui_result2(vResults);
disp('surf done');


% % plot the gradient on the slab
% hold on;quiver3(params.mX(:),params.mY(:),-params.mZ(:),mGx(:),mGy(:),0,2);
% % plot strike
% hold on;quiver3(params.mX(:),params.mY(:),-params.mZ(:),params.mT(:,1),params.mT(:,2),params.mT(:,3),3,'r');


% prepare Value that will be illustrated on the 3D surface defined above
% params.mC=ones(length(params.vUsedNodes),1)*nan;
% params.mC(params.vUsedNodes)=params.mValueGrid(:,2);
% params.mC(params.mC == 0)=nan;
% params.mC=reshape(params.mC,length(params.vY),length(params.vX));
% params.mZ(isnan(params.mC))=nan;

% make figure
% figure;
% surf(params.mX,params.mY,-params.mZ);
% surf(params.mX,params.mY,-params.mZ,params.mC);
% colorbar;
% set(gca,'CLim',[0.6 1.4]);
% box on
% shading interp
