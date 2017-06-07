function [params] = sr_calcZ(params)
% function [params] = sr_calcZ(params)
% -------------------------------------
% Calculation of seismic rate changes. This function calculates the rates
% for all grid points together.
%
% Input parameters:
% please see function ~/zmap/src/thomas/seismicrates/get_parameter.m
%
% Output parameters:
%   Same as input parameters including but additionally
%   params.mResult_    z,probability of z, beta, probability of beta, and
%                      resolution. This data will be stored into
%                      params.mResult{n}, where n is the number of runs
%                      (see sr_startZ.m)
%   params.mVar        List of all combinations of parameters used for
%                      searching the parameter space ([N, Tw, Tbin]).
%   params.m1          Max. value for z ([z,Resolution,N,Tw,Tbin])
%   params.m2          Max. value for p(z) ([z,Resolution,N,Tw,Tbin])
%   params.m3          Max. value for beta ([z,Resolution,N,Tw,Tbin])
%   params.m4          Max. value for p(beta) ([z,Resolution,N,Tw,Tbin])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Th. van Stiphout vanstiphout@sed.ethz.ch
% last update: 16.08.2005
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


report_this_filefun(mfilename('fullpath'));

% Initialize
bChk=logical(0);    % for debugging the code

% Determine time period of catalog
params.fTminCat = min(params.mCatalog(:,3));
params.fTmaxCat = max(params.mCatalog(:,3));
% Adjust to decimal years
% fTimePeriod =params.fTimePeriod/365;
mCat=params.mCatalog(:,3);
mLoc=[params.mCatalog(:,1) params.mCatalog(:,2) params.mCatalog(:,7) ];
% Init result matrix
mValueGrid_ = [];
%  Selection criteria for subcatalog (between StartTime and
% TimeCut + WindowLength

% Create Indices of the catalog for each Node and select quakes in time
[params.caNodeIndices, params.vResolution] = ex_CreateIndexCatalog(params.mCatalog,...
    params.mPolygon, params.bMap, 0, size(params.mCatalog,1),...
    params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);

% prepare input parameter matrix  [ vN   vTw   vTbin ]
mVar(:,1)=repmat(params.vN,size(params.vTw,1)*size(params.vTbin,1),1);
mVar(:,2)=reshape(repmat(params.vTw',size(params.vN,1)*size(params.vTbin,1),1),...
    size(params.vTw,1)*size(params.vN,1)*size(params.vTbin,1),1);
mVar(:,3)=repmat(reshape(repmat(params.vTbin',size(params.vN,1),1),...
    size(params.vTbin,1)*size(params.vN,1),1),size(params.vTw,1),1);

% loop over all input parameters
for i=1:size(mVar,1)

    % get input parameters
    fTstart=params.fTstart;
    fT=params.fT;
    fTw=mVar(i,2);
    nN=mVar(i,1);
    nTbin=mVar(i,3);
    mNumDeclus_=params.mNumDeclus(:,end);
%     sum(params.mNumDeclus  )
    % vSelMag=(params.mCatalog(:,6)>=params.fMc)

    % create vectors for time periods
    vSelR0_=(params.mCatalog(:,3) > fTstart);
    vSelR1_=(params.mCatalog(:,3) <= fT);
    vSelR2_=(params.mCatalog(:,3) >= fT-fTw);
    vSelR3_=(params.mCatalog(:,3)  <= fT-fTw);

    % combine time periods with decluster info's
    mSelD0_=repmat(vSelR0_,1,size(mNumDeclus_,2)) & mNumDeclus_;
    mSelD1_=repmat(vSelR1_,1,size(mNumDeclus_,2)) & mNumDeclus_;
    mSelD2_=repmat(vSelR2_,1,size(mNumDeclus_,2)) & mNumDeclus_;
    mSelD3_=repmat(vSelR3_,1,size(mNumDeclus_,2)) & mNumDeclus_;

    % only events during certain period
    mSelD00=( mSelD0_ & mSelD1_);   % whole period
    mSelD10=( mSelD0_ & mSelD3_);   % 1st period
    mSelD20=( mSelD1_ & mSelD2_);   % 2nd period

    % events in whole period  (us it for calculating probabilities of z and beta)
    mCat=params.mCatalog(mSelD00,3);

    % repeat matrix for multiplication with grid node distance-ranking
    aSelD02=repmat(mSelD00,1,size(params.mPolygon,1));
    % if gridding is based on radius
    if params.nGriddingMode==1
        for pp=1:size(params.mPolygon,1)
            vNaN(:,pp)=params.vResolution{pp}>params.fRadius;
%             params.caNodeIndices{pp}(vNaN(:,pp))=NaN;
            vResolutionN_(pp)=sum(not(vNaN(:,pp)));
        end
        nN=max(vResolutionN_);
    end
    % transform cells of node indices to matrix (column wise)
    caNodeIndices_=cell2mat(params.caNodeIndices');   % distance-ranking of each event from each grid node

    % create help matrices
    tmp=zeros(size(aSelD02));
    tmp1=(0:1:size(aSelD02,2)-1)*size(params.mCatalog,1);
    tmp2=repmat(tmp1,size(aSelD02,1),1);  %

    % sort rankings for each grid node
    [X1, I1] =sort(caNodeIndices_);
    % do reverse "sort ranking" for each grid node
    [X2, I2] =sort(I1);

    I1=I1+tmp2;I2=I2+tmp2;
    bSelD02=aSelD02(I2); % resort 1-0 matrix
    cSelD02=cumsum(bSelD02);
    dSelD02=logical(bSelD02.*(cSelD02<=nN)); % only the first nN events
    mSelRes=dSelD02;  % copy for the first nN events
    dSelD02=dSelD02(I1); % transform back  / nN Events over whole catalog per grid node
    % transformation back of NaN's-list for event that are not in a certain params.fRadius
    if params.nGriddingMode==1
        vNaN1=vNaN(I1);
    end
    %     eSelD02=bSelD02(I1); % transform back
    %     Checkpoint
    if bChk
        ii=ceil(rand(1)*length(params.mPolygon));
        figure;plot(mLoc(:,1),mLoc(:,2),'.c');
        hold on;plot(params.mPolygon(ii,1),params.mPolygon(ii,2),'ok');
        %  hold on;plot(mLoc(I2(1:nN,ii)-(ii-1)*size(mLoc,1),1),mLoc(I2(1:nN,ii)-(ii-1)*size(mLoc,1),2),'dr')
    end

    % reshape resolution matrix
    vResolution_=cell2mat(params.vResolution');

    % prepare catalog (origin times) - copy them column-wise for each
    % grid point
    mCat0=params.mCatalog(:,3);
    mCat0=(repmat(mCat0,1,size(dSelD02,2)));

    if bChk
        % and for latitude and longitude aswell
        mLon0=params.mCatalog(:,1);
        mLon0=(repmat(mLon0,1,size(dSelD02,2)));
        mLat0=params.mCatalog(:,2);
        mLat0=(repmat(mLat0,1,size(dSelD02,2)));
    end

    % for gridding mode 1 (radius)
    if params.nGriddingMode==1
        adder=repmat(0:size(caNodeIndices_,1):size(caNodeIndices_,1)*(size(caNodeIndices_,2)-1),size(caNodeIndices_,1),1);
        caNodeIndices2_=caNodeIndices_+adder;
        caNodeIndices3_=caNodeIndices2_(~isnan(caNodeIndices2_));
        caNodeIndices4_=zeros(size(caNodeIndices_));
        caNodeIndices4_(caNodeIndices3_)=1;
        caNodeIndices4_=logical(caNodeIndices4_);
%         hold on;plot(params.mCatalog(caNodeIndices4_(:,ii),1),...
%                                  params.mCatalog(caNodeIndices4_(:,ii),2),'sr')
         mCat0(not(caNodeIndices4_))=NaN;
         mLon0(not(caNodeIndices4_))=NaN;
         mLat0(not(caNodeIndices4_))=NaN;

         clear caNodeIndices2_ caNodeIndices3_
    end

    % prepare matrices for subset of catalog
    gSelD02=ones(size(dSelD02))*NaN;
    mCat00=gSelD02; % whole catalog
    mCat10=gSelD02; % 1st period
    mCat20=gSelD02; % 2nd period
    mLon00=gSelD02; mLon00_=mLon00;
    mLat00=gSelD02;    mLat00_=mLat00;
    % put the times in the NaN's matrix
    gSelD02(dSelD02)=(mCat0(dSelD02));


    % whole catalog
    mSelD00=repmat(mSelD00,1,size(dSelD02,2));
    mSelD01=(dSelD02&mSelD00);
    mCat00(mSelD01)=(mCat0(mSelD01));
    if params.nGriddingMode==1
        mCat00(vNaN1)=NaN;
    end
    % Checkpoint
    if bChk
        % figure;histogram(mCat00(:,1),100)
        % Checkpoint plot location
        mLon00=mLon00_;mLat00=mLat00_;
        mLon00(mSelD01)=(mLon0(mSelD01));
        mLat00(mSelD01)=(mLat0(mSelD01));
%         hold on;plot(mLon00(:,ii),mLat00(:,ii),'xk','MarkerSize',10);
        hold on;plot(mLon00(not(vNaN1(:,ii)),ii),mLat00(not(vNaN1(:,ii)),ii),'xk','MarkerSize',10);
    end

    % 1st period
    mSelD10=repmat(mSelD10,1,size(dSelD02,2));
    mSelD11=(dSelD02&mSelD10);
    mCat10(mSelD11)=(mCat0(mSelD11));
    if params.nGriddingMode==1
        mCat10(vNaN1)=NaN;
    end
    % Checkpoint
    if bChk
        % figure;histogram(mCat10(:,1),100)
        % Checkpoint plot location
        mLon10=mLon00_;mLat10=mLat00_;
        mLon10(mSelD11)=(mLon0(mSelD11));
        mLat10(mSelD11)=(mLat0(mSelD11));
%         hold on;plot(mLon10(:,ii),mLat10(:,ii),'dr','MarkerSize',10);
        hold on;plot(mLon10(not(vNaN1(:,ii)),ii),mLat10(not(vNaN1(:,ii)),ii),'dr','MarkerSize',10);
    end


    % 2nd period
    mSelD20=repmat(mSelD20,1,size(dSelD02,2));
    mSelD21=(dSelD02&mSelD20);
    mCat20(mSelD21)=(mCat0(mSelD21));
    if params.nGriddingMode==1
        mCat20(vNaN1)=NaN;
    end
    % Checkpoint
    if bChk
        % figure;histogram(mCat20(:,1),100)
        % Checkpoint plot location
        mLon20=mLon00_;mLat20=mLat00_;
        mLon20(mSelD21)=(mLon0(mSelD21));
        mLat20(mSelD21)=(mLat0(mSelD21));
%         hold on;plot(mLon20(:,ii),mLat20(:,ii),'sb','MarkerSize',10);
        hold on;plot(mLon20(not(vNaN1(:,ii)),ii),mLat20(not(vNaN1(:,ii)),ii),'sb','MarkerSize',10);
    end

    %  lta
    [mLTA, mLTAprob] =calc_zlta(mCat,mCat00,mCat20,params.fTstart, fT,...
        fTw,nTbin, nN);
    % mBeta
    [mBeta, mBetaprob] =calc_beta(mCat,mCat00,mCat20,params.fTstart, fT,...
        fTw,nTbin, nN);
    %      mBeta(:,kk)=calc_beta(mCat10,mCat20,params.fStartTime,...
    %          params.fTimeCut,params.fTwLength,params.fTimeSteps);

    if params.nGriddingMode==1
        % Resolution by No.of Events in a certain distance from grid node,
        % defined by params.fRadius .
        mResolution=vResolutionN_';
    else
        % Resolution by N-th event in radii-vector
        mResolution=max(vResolution_.*mSelRes)';
    end
    % preallocation of mResult_
    if i==1
        mResult_=ones(size(params.mPolygon,1),5,params.nMCS).*NaN;
    end
    mResult_(:,:,i)=[mLTA mLTAprob mBeta mBetaprob double(mResolution)];

    sString=sprintf('End loop %d with N=  %d  Tw=  %d   Tbin=  %d   ',i,...
        mVar(i,1),mVar(i,2),mVar(i,3));
    disp(sString);
end % end loop variation over input parameter

% params.mResult_=mResult_;
% saving parameter space
params.mVar=mVar;

% Maxima search
[mMaxValue, mMaxIndices]=max(mResult_,[],3);
% ask for parameter settings (parameter settings for max for each  grid
% point)
% nMax=2; % (i.e. 1: z, 2:prob(z), 3:beta, 4:prob(beta),5:radius)
mParamax1=mVar(mMaxIndices(:,1),1:3);
mParamax2=mVar(mMaxIndices(:,2),1:3);
mParamax3=mVar(mMaxIndices(:,3),1:3);
mParamax4=mVar(mMaxIndices(:,4),1:3);

% plotting preliminary results / data
if bChk
    % plot results for grid points with contour lines that indicate z,
    % prob(z), beta, prob(beta)
    %     figure;pcolor( params.mPolygon(:,1), params.mPolygon(:,2), mResult_(:,1))
    figure;
    XX_=repmat(params.vN,1,size(params.vTw,1));
    YY_=repmat(params.vTw,1,size(params.vN,1))';
    for ii_=1:10
        ngp_=ceil(rand(1,1)*1170);
        for kk_=1:4
            subplot(2,2,kk_);
            contour(XX_,YY_,reshape(squeeze(mResult_(ngp_,kk_,:)),...
                size(params.vN,1),size(params.vTw,1)));
            colorbar;
        end
        pause
    end
    %     pcolor(reshape(squeeze(mResult_(1,1,:)),size(params.vN,1),size(params.vTw,1)));
end

% Prepare mResult_
% vSel=find(mResult_(:,5) > params.fMaxRadius);
% mResult_(vSel,1:4)=NaN';

% Pre Result matrix (result for 1
params.m1=[mMaxValue(:,1) double(mResolution) mParamax1];
params.m2=[mMaxValue(:,2) double(mResolution) mParamax2];
params.m3=[mMaxValue(:,3) double(mResolution) mParamax3];
params.m4=[mMaxValue(:,4) double(mResolution) mParamax4];
% figure;pcolor(reshape(params.mPreResult(:,1),39,30));
% colorbar
