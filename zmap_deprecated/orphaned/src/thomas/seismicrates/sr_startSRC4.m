function [ params ]= sr_startSRC4
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
params=get_parameterSRC4;

% set local parameter
% nMode=params.nMode;             % 0:MCS, 1:rates, 2:MCS+rates
% bDeclus=params.bDeclus;       % 0:Load Declusterd Catalog, 1:no declustering

% figure;

%% no of simulations
nJ=params.nMCS;
nLimit=20;
% preallocations


% take only one grid node at location of PSQ
% params.mPolygon=params.mPSQ(1,1:2);

% create grid
[params.mPolygon,params.vX,params.vY,params.vUsedNodes]=calc_Polygon([params.vRegion(1) params.vRegion(2)], ...
    [params.vRegion(3) params.vRegion(4)],0.05,0.05);
% [params.mPolygon,params.vX,params.vY,params.vUsedNodes]=calc_Polygon([params.mPolygon(1) params.mPolygon(1)], ...
%     [params.mPolygon(2) params.mPolygon(2)],0.25,0.25);
% create synthetic catalog
if params.nSynCat>0
    mCatalog=[];
    while (size(mCatalog,1)>params.nMaxCatSize) || isempty(mCatalog) % keep catalog with etas low
        [mCatalog, vMain] = calc_SynCatSRC(params.nSynCatSize,...
            params.vSynCat,params.nSynCat,params.nSynMode,...
            params.vAfter, params.vEtas,params.mSynCatRef,...
            params.bPSQ,params.vPSQ,params.mPSQ);
        %             [mCatalog, vMain] = calc_SynCat(params.nSynCatSize,2.5,2.5,8,100,...
        %                 'January 1,1975','December 31,1990',6.5,params.nSynCat,...
        %                 params.nSynMode,params.mCatalog,params.vPSQ);
        [Ntmp,Xi]=sort(mCatalog(:,3));
        mCatalog=mCatalog(Xi,:);clear Xi Ntmp;
        params.mCatalog=mCatalog;
        %             [pathstr, name, ext, versn] = fileparts(params.sFile);
        %             clear ext versn;
        %             eval(sprintf('!mkdir %s',name));
        %             eval(sprintf('save %s/%s%04.0f.mat mCatalog -mat',name,'mCatalog',jj));
        %             eval(sprintf('save %s/%s%04.0f.mat vMain -mat',name,'vMain',jj));
    end
    % associate error
    mHypo=params.mHypo;
    params.mCatalog(:,11:12)=repmat(mHypo(2:3),size(params.mCatalog,1),1);
    mMag=params.mMag;
    params.mCatalog(:,13)=repmat(mMag,size(params.mCatalog,1),1);

else
    vMain=true(size(params.mCatalog,1),1);
end% create grid

%% loop MCS

% preallocation of mSamples
mSamples=nan(nJ,size(params.mPolygon,1));
mZ=nan(nJ,size(params.mPolygon,1));
mB=mZ;

for jj=1:nJ
    disp(sprintf('Simulation (nMCS)  No. %d', jj));

    %% include hypocenter uncertainties
    mCat=params.mCatalog;
    % Hypocenter shift
    if params.bHypo
        % create first mDelta
        if isempty(params.mDeltaHypo)
            mDelta=params.mHypo;
            mDelta=repmat(mDelta,size(mCat,1),1);
        else
            %             mDelta=params.mDeltaHypo;
            mDelta=[params.mCatalog(:,11) params.mCatalog(:,11) params.mCatalog(:,12)];
        end
        [mCat]=calc_hyposhift(mCat,mDelta,true);
    end
    % include magnitude uncertainties
    if params.bMag
        % create first mDeltaMag
        if isempty(params.mDeltaMag)
            mDeltaMag=params.mMag;
            mDeltaMag=repmat(mDeltaMag,size(mCat,1),1);
        else
            %             mDeltaMag=params.mDeltaMag;
            mDeltaMag=params.mCatalog(:,13);
        end
        [mCat]=calc_magerr(mCat,mDeltaMag);
    end

    %% decluster catalog
    if params.nSynCat==0
        if params.nMode~=1
            vSel=(mCat(:,6)>=params.fMc-0.2);
            [declusCat] = MonteDeclus(mCat(vSel,:),...
                params.nSimul,params.nDeclusMode,params.mReasenParam);
            mCat=declusCat;
            vMain=true(size(mCat,1),1);
        end
    end

    % Cut Mc
    vSel=(mCat(:,6)>=params.fMc);
    mCat=mCat((logical(vMain)&vSel),:);
    %     disp(sprintf('The clustered catalog consists of %6.0f with M>= %3.1f',size(mCat,1),params.fMc));

    % Create Index Catalog (only for 1 grid node => params.mPolygon)
    [caNodeIndices, vResolution] = ex_CreateIndexCatalog(mCat,...
        [params.mPolygon(:,1) params.mPolygon(:,2)], 1, params.nGriddingMode,...
        params.fResolution,params.fRadius, 0.2, 0.2);

    vResolution_=cell2mat(vResolution);

    caNodeIndices_=nan(max(vResolution_),size(caNodeIndices,1));
    for ii=1:size(caNodeIndices,1)
        caNodeIndices_(1:vResolution_(ii),ii)=caNodeIndices{ii};
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

mSamples_=round(nanmean(mSamples)');
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
mZmedian=nanmedian(mZ,1);
mSynZmedian=nanmedian(mSynZ,1);
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
mBmedian=nanmedian(mB,1);
mSynBmedian=nanmedian(mSynB,1);
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
            vPolZ(i)=nanmean([vY1i(nI) vY2i(nI)]);
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
            vPolB(i)=nanmean([vY1i(nI) vY2i(nI)]);
            vXolB(i)=vX(nI);
        catch
            vPolB(i)=nan;vXolB(i)=nan;
        end

        % calculate mean and std of Z and B
        vMeanZ(i)=nanmean(mZ(:,i),1);
        vMeanB(i)=nanmean(mB(:,i),1);
        vStdZ(i)=nanstd(mZ(:,i),1);
        vStdB(i)=nanstd(mB(:,i),1);
    end
end


%% prepare saving of results
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
params.vPolB=vPolB;
params.vXolZ=vXolZ;
params.vXolB=vXolB;
params.mSamples=mSamples;
params.mSamples_=mSamples_;


sString=sprintf('save %s params -mat',params.sFile);
eval(sString);
sString=sprintf('Results saved in  %s',params.sFile);
disp(sString);

%% plot results
plot_Maps4(params.sFile)
