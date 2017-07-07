function [params] = sr_calcZ2(params)
% function [params] = sr_calcZ(params)
% -------------------------------------
% Calculation of seismic rate changes
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon          Polygon (defined by ex_selectgrid)
%   params.vX                      X-vector (defined by ex_selectgrid)
%   params.vY                      Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes      Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.bRandom           Perform random simulation (=1) or real calculation (=0)
%   params.nCalculation      Number of random simulations
%   params.bMap                 Calculate a map (=1) or a cross-section (=0)
%   params.bNumber           Use constant number (=1) or constant radius (=0)
%   params.nNumberEvents Number of earthquakes if bNumber == 1
%   params.fMaxRadius       Maximum Radius using a constant number of events; works only with bNumber == 1
%   params.fRadius              Radius of gridnode if bNumber == 0
%   params.vResolution       Resolution as Sampling Radius or No. of Events per sample
%   params.fCylinderLength Length of Cylinder used for cross-section
%   params.nMinimumNumber     Minimum number of earthquakes per node for determining a b-value
%   params.fMinMag            Lower limit of magnitude range for testing
%   params.fMaxMag           Upper limit of magnitude range for testing
%   params.bTimePeriod      Calculate seismicity difference for 2 periods (0) until start and end of catalog or
%                             a specific time period before and after fSplitTime (1)
%   params.fTimePeriod       Length of time periods
%   params.bTstart              Check for starting time of temporal mapping
%   params.fTstart               Starting time for temporal mapping
%   params.bBstnum            Check for boostrap sampling
%   params.fBstnum             Number of bootstrap samples
%   params.fBinning             Bin size for magnitude binning
%   params.sComment         Comment on calculation
%   params.fTimeCut            Time cut of years
%   params.fTwLength          Time Window length in years
%   params.fStartTime          Start Time for z-Value calculation
%   params.fTimeSteps         Time steps in days
%   params.mNumDeclus     Assignment matrix for Declustering
%   params.nSimul               Number of MonteCarlo Simulations


% Output parameters:
%   Same as input parameters including
%   params.mValueGrid         Matrix of calculated values
%   params.vcsGridNames       Names of parameters calculated
%   Check sv_NodeCalcMc.m for a list of variables!!
%
% Th. van Stiphout vanstiphout@sed.ethz.ch
% last update: 15.8.2005

% global bDebug;
% if bDebug
report_this_filefun(mfilename('fullpath'));
% end

% Initialize
vResults = [];
% params.sComment = [];
if isempty(params.fBinning)
    params.fBinning = 0.1;
end
for i=1:size(params.mCatalog,1)
% Determine time period of catalog
params.fTminCat = min(params.mCatalog{i}(:,3));
params.fTmaxCat = max(params.mCatalog{i}(:,3));
% Adjust to decimal years
% fTimePeriod =params.fTimePeriod/365;
mCat=params.mCatalog{i}(:,3);
% Init result matrix
mValueGrid_ = [];
%  Selection criteria for subcatalog (between StartTime and
% TimeCut + WindowLength
%     vSel1=(params.mCatalog(:,3) <= params.fTimeCut+params.fTwLength);
%     vSel2=(params.mCatalog(:,3) > params.fStartTime);

% Create Indices of the catalog for each Node and select quakes in time
[params.caNodeIndices, params.vResolution] = ex_CreateIndexCatalog(params.mCatalog{i}, params.mPolygon, params.bMap, params.nGriddingMode, ...
    size(params.mCatalog{i},1), params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);
% create vectors for time periods
vSelR0_=(params.mCatalog{i}(:,3) > params.fStartTime);
vSelR1_=(params.mCatalog{i}(:,3) <= params.fTimeCut+params.fTwLength);
vSelR2_=(params.mCatalog{i}(:,3) >= params.fTimeCut);
vSelR3_=(params.mCatalog{i}(:,3)  <= params.fTimeCut);


% combine time periods with decluster info's
mSelD0_=repmat(vSelR0_,1,size(params.mNumDeclus{i},2)) & params.mNumDeclus{i};
mSelD1_=repmat(vSelR1_,1,size(params.mNumDeclus{i},2)) & params.mNumDeclus{i};
mSelD2_=repmat(vSelR2_,1,size(params.mNumDeclus{i},2)) & params.mNumDeclus{i};
mSelD3_=repmat(vSelR3_,1,size(params.mNumDeclus{i},2)) & params.mNumDeclus{i};

% only events during certain period
mSelD00=( mSelD0_ & mSelD1_);

% repeat matrix for multiplication with grid node distance-ranking
mSelD02=repmat(mSelD00,size(params.mPolygon,1),1);

% transform cells of node indices to matrix (column wise)
caNodeIndices_=cell2mat(params.caNodeIndices');
% reshape matrix for multiplication with 1-0-time matrix
caNodeIndices_2=reshape(caNodeIndices_,size(caNodeIndices_,1)*size(caNodeIndices_,2),1);
 vResolution_=cell2mat(params.vResolution');
%  vResolution_2=reshape(vResolution_,size(vResolution_,1)*size(vResolution_,2),1);


%% do it for one delcustered catalog %%%%%%%%%%%%%%%%
% for kk=1:1        % for kk=1:params.nSimul
    % multiply TD-selection (Time and Declustering-selection) with node indices
    % for the complete catalog
    mSelD02(:,1).*caNodeIndices_2;

    % get position of events that are not in declustered catalog
    % save this information in vSel001 (events not in catalog)
    % vSel=find(mSelD02 == 0);
% %     vSel001=zeros(size(mSelD02(:,kk)));
% %     vSel001(find(mSelD02(:,kk)==0),1)=1;
% %     vSel001=logical(vSel001);
% %     mSelD02(vSel001,kk);

    % resize catalog with TD info for each grid point
    mSelD03=reshape(mSelD02(:,1),size(params.mCatalog{i},1),size(params.mPolygon,1));
    % take only events from TD and and resize/reshape matrix
    mSelD04=reshape(caNodeIndices_(mSelD03),sum(mSelD03(:,1)),size(params.mPolygon,1));


    % clear mSelD02 mSelD03
    % sort ramaining catalog
%     [tmp, Xi] =sort(mSelD04,1);
%     clear tmp
    % vIndOrig=(1:1:size(Xi,1))';
    % mIndOrig=repmat(vIndOrig,1,size(params.mPolygon,1));
    % mIndOrig=mIndOrig(Xi); % original indices

    % take N first events
    nN=params.nNumberEvents;
    % indices of N nearest selected events per grid node
    mSelD05=mSelD04(1:nN,:);
    % determine resolution of grid node
    vRes=reshape(vResolution_(mSelD03),sum(mSelD03(:,1)),size(params.mPolygon,1));


    % prepare matrix for solution
    tmp=zeros(size(mSelD04));
    tmp1=(0:1:size(mSelD05,2)-1)*size(params.mCatalog{i},1);
    % bring matrix into same format
    tmp2=repmat(tmp1,size(mSelD05,1),1);
    % correct indices
    tmp3=mSelD05+tmp2;
    % assign events
    mSelD03_empty=zeros(size(params.mCatalog{i},1),size(params.mPolygon));
    mSelD03_empty(tmp3)=1;

%     tmp(tmp3)=1;
%     mSelD03_empty=zeros(size(mSelD04));
%     mSelD03_empty(not(vSel001))=tmp;
    mSelD03a=logical(mSelD03_empty);
    clear tmp tmp1 tmp2 tmp3 mSelD04 mSelD03_empty

%% for each time period %%%%%%%%%%%%%%%%%
    % for the whole period from start time to time cut+time window length
    vSelT1=logical(mSelD03a);
    % greater than Time cut
    vSelT2=mSelD03a;
    vSel=find(mSelD2_(:,1)==0);
    vSelT2(vSel,:)=0;

    % smaller than time cut
    vSelT3=mSelD03a;
    vSel=find(mSelD3_(:,1)==0);
    vSelT3(vSel,:)=0;


%% calculation of rate estimate value %%%%%%%%%%
    vSelT1=logical(vSelT1);
    vSelT2=logical(vSelT2);
    vSelT3=logical(vSelT3);

    % TEST
%     figure;histogram(mCat(find(sum(vSelT1')>0),1),100)
%     figure;histogram(mCat(find(sum(vSelT2')>0),1),100)
%     figure;histogram(mCat(find(sum(vSelT3')>0),1),100)
%    NODE_=100;
%    hold on;plot(params.mPolygon(NODE_,1),params.mPolygon(NODE_,2),'r^')
%    hold on;plot(params.mCatalog{i}(vSelT1(:,NODE_),1),params.mCatalog{i}(vSelT1(:,NODE_),2),'rs')
%    hold on;plot(params.mCatalog{i}(vSelT2(:,NODE_),1),params.mCatalog{i}(vSelT2(:,NODE_),2),'ks')
%    hold on;plot(params.mCatalog{i}(vSelT3(:,NODE_),1),params.mCatalog{i}(vSelT3(:,NODE_),2),'gs')


clear vR1 vR2 vR3 mean1 mean2 mean3 var1 var2 var3
     % calculate rate for bins over the whole catalog length
     mCat1=ones(size(vSelT1))*NaN;
     tmp=repmat(mCat,size(params.mPolygon,1),1);
     tmp=tmp(vSelT1);
     mCat1(vSelT1)=tmp;

     % calculate rate from TimeCut to TimeEnd
     mCat2=ones(size(vSelT2))*NaN;
     tmp=repmat(mCat,size(params.mPolygon,1),1);
     tmp=tmp(vSelT2);
     mCat2(vSelT2)=tmp;mCat(size(mCat,1));

     % calculate rate from begin to TimeCut
     mCat3=ones(size(vSelT3))*NaN;
     tmp=repmat(mCat,size(params.mPolygon,1),1);
     tmp=tmp(vSelT3);
     mCat3(vSelT3)=tmp;

     %  lta
     mLTA(:,i)=calc_zlta(mCat1,mCat2,params.fStartTime,...
         params.fTimeCut,params.fTwLength,params.fTimeSteps);
     % mBeta
     mBeta(:,i)=calc_beta(mCat1,mCat2,params.fStartTime,...
         params.fTimeCut,params.fTwLength,params.fTimeSteps);

     % Resolution by N-th event in radii-vector
     mResolution(:,i)=vRes(nN,:)';
     sString=sprintf('End loop %d of %d',i,params.nSimul);
     disp(sString);
% end % for kk=1:params.nSimul
%% end loop over simulated catalogs %%%%%%%%%%

end
disp('end');

if (params.nSimul==1)
    params.mValueGrid(:,1)=mLTA;
    params.mValueGrid(:,2)=ones(size(mLTA))*NaN;
    params.mValueGrid(:,3)=ones(size(mLTA))*NaN;;
    params.mValueGrid(:,4)=mBeta;
    params.mValueGrid(:,5)=ones(size(mLTA))*NaN;;
    params.mValueGrid(:,6)=ones(size(mLTA))*NaN;;
    params.mValueGrid(:,7)=mResolution;
else
    params.mValueGrid(:,1)=mean(mLTA')';
    params.mValueGrid(:,2)=std(mLTA')';
    params.mValueGrid(:,3)=var(mLTA')';
    params.mValueGrid(:,4)=mean(mBeta')';
    params.mValueGrid(:,5)=std(mBeta')';
    params.mValueGrid(:,6)=var(mBeta')';
    params.mValueGrid(:,7)=mean(mResolution');
end


% Radius Limit
vSel=find(params.mValueGrid(:,7) > params.fMaxRadius);
params.mValueGrid(vSel,1:6)=NaN';

params.vcsGridNames = cellstr(char(...
    'lta',...               %   1
    'std lta',...      %   2
    'var lta ',...   % 3
    'beta',...               %   4
    'std beta',...      %   5
    'var beta',...   % 6
    'Resolution [km]'));  % 7
