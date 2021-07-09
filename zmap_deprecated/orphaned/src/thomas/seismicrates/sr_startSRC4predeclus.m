function [ params ]= sr_startSRC4predeclus
% example sr_startZ
% -------------------------------------------------------------------------
% Function starts toolbox for analysing rate changes. The function
% get_parameter acts as a control file that contains most of the
% parameters.
%
%
% Th. van Stiphout; vanstiphout@sed.ethz.ch
% last update: 7.4.2008

% global bDebug;
% if bDebug
report_this_filefun(mfilename('fullpath'));
% end
% go to directory
cd ~/zmap/src/thomas;
% load path's
initialize

% load parameter
[params, vDeclus]=get_parameterSRC4;

% set local parameter
% nMode=params.nMode;             % 0:MCS, 1:rates, 2:MCS+rates
% bDeclus=params.bDeclus;       % 0:Load Declusterd Catalog, 1:no declustering

% figure;

%% no of simulations
nJ=params.nMCS;
nLimit=10;
TT0=clock;

% take only one grid node at location of PSQ
% params.mPolygon=params.mPSQ(1,1:2);

% create grid
[params.mPolygon,params.vX,params.vY,params.vUsedNodes]=calc_Polygon([params.vRegion(1) params.vRegion(2)], ...
    [params.vRegion(3) params.vRegion(4)],0.05,0.05);

% prepare mVar
% prepare input parameter matrix  [ vN   vTw   vTbin ]
vTw=[4]';
vRadius=[10]';params.fRadius=vRadius;
mVar=nan(size(vTw,1)*size(vRadius,1),2);
mVar(:,1)=repmat(vTw,size(vRadius,1),1);
mVar(:,2)=reshape(repmat(vRadius,1,size(vTw,1))',size(vTw,1)*size(vRadius,1),1);

% preallocation of mSamples
mSamples=nan(nJ,size(params.mPolygon,1));
mZ=nan(nJ,size(params.mPolygon,1));
mB=mZ;
mPolZ=nan(size(params.mPolygon,1),size(mVar,1));

%% loop over mVar
for vv=1:size(mVar,1)
    params.vTw=mVar(vv,1);
    params.fRadius=mVar(vv,2);

    disp(sprintf('No. %d of %d', vv,size(mVar,1)));
    %% loop MCS
    for jj=1:nJ
        disp(sprintf('Simulation (nMCS)  No. %d', jj));


        nSim=ceil(rand(1,1)*size(vDeclus.mNumDeclus,2));
        vSelDeclus=vDeclus.mNumDeclus(:,nSim);
        vSelDeclus(isnan(vSelDeclus))=0;
        vSelDeclus=logical(vSelDeclus);
        mCat=vDeclus.mCatalog(vSelDeclus,:);
        if vDeclus.bHypo
            mCat(:,1)=vDeclus.mDeclusLon(vSelDeclus,nSim);
            mCat(:,2)=vDeclus.mDeclusLat(vSelDeclus,nSim);
        end
        if vDeclus.bMag
            mCat(:,6)=vDeclus.mDeclusMag(vSelDeclus,nSim);
        end

        % Cut Mc
        vSel=(mCat(:,6)>=params.fMc);
        mCat=mCat(vSel,:);
        size(mCat)

        if params.nGriddingMode==1

            % Create Index Catalog (only for 1 grid node => params.mPolygon)
            [caNodeIndices, vResolution] = ex_CreateIndexCatalog(mCat,...
                [params.mPolygon(:,1) params.mPolygon(:,2)], 1, params.nGriddingMode,...
                params.fResolution,params.fRadius, 0.1, 0.1);
        elseif params.nGriddingMode==0
            %         Create Index Catalog (only for 1 grid node => params.mPolygon)
            [caNodeIndices, vResolution] = ex_CreateIndexCatalog(mCat,...
                [params.mPolygon(:,1) params.mPolygon(:,2)], 1, params.nGriddingMode,...
                params.vN,params.fRadius, 0.1, 0.1);
        end

        vResolution_=cell2mat(vResolution);
        if params.nGriddingMode==1 % constant R
            caNodeIndices_=nan(max(vResolution_),size(caNodeIndices,1));
            for ii=1:size(caNodeIndices,1)
                caNodeIndices_(1:vResolution_(ii),ii)=caNodeIndices{ii};
            end
        elseif params.nGriddingMode==0  %constant N
            caNodeIndices_=cell2mat(caNodeIndices');
        end

        for ii=1:size(params.mPolygon,1)
            % Select event for this particular node
            % mark non-nan's
            vOK1=~isnan(caNodeIndices_(:,ii));
            % select events withing Tstart and Tend
            vSel1=((mCat(caNodeIndices_(vOK1,ii),3)>params.fTstart)&(mCat(caNodeIndices_(vOK1,ii),3)<=params.fT));
            % getting indices out of these events
            caNo1=caNodeIndices_(vSel1,ii);
            mSamples(jj,ii)=size(caNo1,1);

            % calculate real z-values
            [mZ(jj,ii)]=calc_zlta4(mCat(caNo1,3),params.fTstart,params.fT,params.vTw,...
                params.vTbin);
            % calculate real z-values
            [mB(jj,ii)]=calc_beta4(mCat(caNo1,3),params.fTstart,params.fT,params.vTw,...
                params.vTbin);

        end % loop over each node

    end

    mSamples_=round(mean(mSamples,1,'omitnan')');
    % preallocate matrices
    mSynZ=nan(size(mSamples_,1),nJ);
    mSynB=mSynZ;

    %% loop over grid nodes to create synthetic catalogs
    for ii=1:size(params.mPolygon,1)
        % create synthetic catalogs to estimate significance level
        % reset random number generator
        rand('twister',sum(100*clock));
        % rand('seed');
        if mSamples_(ii)>nLimit
            mSyn=rand(mSamples_(ii),nJ)*(params.fT-params.fTstart)+params.fTstart;
            % calculate z(lta)-values for synthetic catalog
            [mSynZ(ii,:)]=calc_zlta4(mSyn,params.fTstart,params.fT,params.vTw,...
                params.vTbin);
            % calculate beta-values for synthetic catalog
            [mSynB(ii,:)]=calc_beta4(mSyn,params.fTstart,params.fT,params.vTw,...
                params.vTbin);
            % calculate z(lta) values for synthetic catalog
            %        [mSynBeta(ii,:)]=calc_zlta4(mSyn,mSyn,params);
        else
            mSynZ(ii,:)=nan(1,size(mZ,1));
            mSynB(ii,:)=nan(1,size(mB,1));
        end
    end

    mSynZ=mSynZ';
    mSynB=mSynB';

    %% prepare statistics

    % sort mZ und mSynZ
    mZs=sort(mZ,1);
    mSynZs=sort(mSynZ,1);
    % prepare mZ and mSynZ for cdf
    mInf=repmat([-25; 25],1,size(mZ,2));
    mZs=[mInf(1,:); mZs; mInf(end,:)];
    mSynZs=[mInf(1,:); mSynZs; mInf(end,:)];
    % recorrect for gridnodes with not enough data
    vSelNoZ=(sum(isnan(mSynZs))==nJ);
    mSynZs(:,vSelNoZ)=nan(size(mSynZs,1),sum(vSelNoZ));
    % calculate median
    mZmedian=median(mZ,1, 'omitnan');
    mSynZmedian=median(mSynZ,1, 'omitnan');
    % Preallocate Vectors and Matrices for Z
    vPcrZ=nan(size(mZ,2),1);
    vPolZ=nan(size(mZ,2),1);
    vXolZ=vPolZ;
    vMeanZ=nan(size(mZ,2),1);
    vStdZ=nan(size(mZ,2),1);

    % sort mB und mSynB
    mBs=sort(mB,1);
    mSynBs=sort(mSynB,1);
    % prepare mZ and mSynZ for cdf
    mInf=repmat([-25; 25],1,size(mB,2));
    mBs=[mInf(1,:); mBs; mInf(end,:)];
    mSynBs=[mInf(1,:); mSynBs; mInf(end,:)];
    % recorrect for gridnodes with not enough data
    vSelNoB=(sum(isnan(mSynBs))==nJ);
    mSynBs(:,vSelNoB)=nan(size(mSynBs,1),sum(vSelNoB));
    % calculate median
    mBmedian=median(mB,1, 'omitnan');
    mSynBmedian=median(mSynB,1, 'omitnan');
    % Preallocate Vectors and Matrices for Z
    vPcrB=nan(size(mB,2),1);
    vPolB=nan(size(mB,2),1);
    vXolB=vPolB;
    vMeanB=nan(size(mB,2),1);
    vStdB=nan(size(mB,2),1);

    %% statistics - calc probability values
    for i=1:size(mZ,2);
        if ~vSelNoZ(i) && ~vSelNoB(i)
            % Probability of Z by cross-comparison
            vP(1)=interp1q(mSynZs(:,i),[0:1/(size(mSynZs(:,i),1)-1):1]',mZmedian(i));
            vP(2)=interp1q(mZs(:,i),[0:1/(size(mZs(:,i),1)-1):1]',mSynZmedian(i));
            if vP(1)<vP(2)
                % Increase rate
                vP(1)=1-vP(1);
                vPcrZ(i)=min(vP);
            else
                % decrease rate
                vP(1)=1-vP(1);
                vPcrZ(i)=max(vP);
            end

            % probability of B by cross-comparison
            vP(1)=interp1q(mSynBs(:,i),[0:1/(size(mSynBs(:,i),1)-1):1]',mBmedian(i));
            vP(2)=interp1q(mBs(:,i),[0:1/(size(mBs(:,i),1)-1):1]',mSynBmedian(i));
            if vP(1)<vP(2)
                % Increase rate
                vP(1)=1-vP(1);
                vPcrB(i)=min(vP);
            else
                % decrease rate
                vP(1)=1-vP(1);
                vPcrB(i)=max(vP);
            end


            % probability by overlap for Z
            try
                vX1=mSynZs(:,i);vY1=(1:-1/(size(vX1,1)-1):0)';
                vX2=mZs(:,i);vY2=(0:1/(size(vX2,1)-1):1)';
                vX=(-25:0.01:25)';
                vY1i=interp1q(vX1,vY1,vX);vY2i=interp1q(vX2,vY2,vX);
                [tmp,nI]=min((vY1i-vY2i).^2);
                vPolZ(i)=mean([vY1i(nI) vY2i(nI)],'omitnan');
                vXolZ(i)=vX(nI);
            catch
                vPolZ(i)=nan;vXolZ(i)=nan;
            end

            % probability by overlap for B
            try
                vX1=mSynBs(:,i);vY1=(1:-1/(size(vX1,1)-1):0)';
                vX2=mBs(:,i);vY2=(0:1/(size(vX2,1)-1):1)';
                vX=(-25:0.01:25)';
                vY1i=interp1q(vX1,vY1,vX);vY2i=interp1q(vX2,vY2,vX);
                [tmp,nI]=min((vY1i-vY2i).^2);
                vPolB(i)=mean([vY1i(nI) vY2i(nI)],'omitnan');
                vXolB(i)=vX(nI);
            catch
                vPolB(i)=nan;vXolB(i)=nan;
            end

            % calculate mean and std of Z and B
            vMeanZ(i)=mean(mZ(:,i),1,'omitnan');
            vMeanB(i)=mean(mB(:,i),1,'omitnan');
            vStdZ(i)=std(mZ(:,i),1, 'omitnan');
            vStdB(i)=std(mB(:,i),1, 'omitnan');
        end
    end

    mPolZ(:,vv)=vPolZ;
end
%% prepare saving of results
% figure;cmin=-4;cmax=4;
% for i=1:size(mVar)
%     hold on;pcolor(params.vX,params.vY,...
%     reshape(calc_ProbColorbar2Value(mPolZ(:,i)),...
%     size(params.vY,1),size(params.vX,1)));
% plot_ProbColorbar2(cmin, cmax);
% xlabel('longitude');
% xlabel('latitude');
% shading interp;
%     str=sprintf('Tw=%d , Radius=%d km',mVar(i,1),mVar(i,2));
%     title(str);
%
%     pause
% end
params.mZ=mZ;
params.mB=mB;
params.vMeanZ=vMeanZ;
params.vMeanB=vMeanB;
params.vStdZ=vStdZ;
params.vStdB=vStdB;
params.mSynZ=mSynZ;
params.mSynB=mSynB;
params.vPcrZ=vPcrZ;
params.vPcrB=vPcrB;
params.vPolZ=vPolZ;
params.mPolZ=mPolZ;
params.vPolB=vPolB;
params.vXolZ=vXolZ;
params.vXolB=vXolB;
params.mSamples=mSamples;
params.mSamples_=mSamples_;
params.mVar=mVar;


sString=sprintf('save %s params -mat',params.sFile);
eval(sString);
sString=sprintf('Results saved in  %s',params.sFile);
disp(sString);
TT1=clock;
etime(TT1,TT0)

%% plot results
plot_Maps4(params.sFile)
