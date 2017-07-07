function plot_GrdPntAnalysis4(sFilename1,sFilename2, fLon0, fLat0, fDepth)
%  plot_GrdPntAnalysis4('08072601-Mc16-Reasen.mat','mDeclus08072601.mat',-116.4, 34.2,  5)
%
%

% load map information
load(sFilename1);
% load declustering information
vDeclus=load(sFilename2);

if isempty(fLon0) || isempty(fLat0)
    [fLon0, fLat0]=ginput(1);
end

if isempty(fDepth);
    fDepth=0;
end

disp(sprintf('Lon=%8.3f, Lat=%7.3f, Depth=%4.0f',fLon0,fLat0,fDepth));

hold on;plot(fLon0,fLat0,'kx','MarkerSize',10);

% prepare mVar
% prepare input parameter matrix  [ vN   vTw   vTbin ]
vTw=[2 2.5 3 3.5 4 4.5 5 5.5 6 7]';
vRadius=[5 10 15 20 25 30 40 50 60]';
params.fRadius=vRadius;
mVar=nan(size(vTw,1)*size(vRadius,1),2);
mVar(:,1)=repmat(vTw,size(vRadius,1),1);
mVar(:,2)=reshape(repmat(vRadius,1,size(vTw,1))',size(vTw,1)*size(vRadius,1),1);

% preallocate variables
mSamples_=nan(params.nMCS,1);
mZ=nan(params.nMCS,size(mVar,1));
mB=nan(params.nMCS,size(mVar,1));
mSynZ=nan(params.nMCS,size(mVar,1));
mSynB=nan(params.nMCS,size(mVar,1));


% FOR EACH mVar
for ii=1:size(mVar,1)
    mVar(ii,:)
    for jj=1:params.nMCS % no. of simulations
        nSim=ceil(rand(1,1)*size(vDeclus.mNumDeclus,2));
        vSelDeclus=vDeclus.mNumDeclus(:,nSim);
        vSelDeclus(isnan(vSelDeclus))=0;
        vSelDeclus=logical(vSelDeclus);
        mCat=vDeclus.mCatalog(vSelDeclus,:);
        if exist('mDeclusLon')
            mCat(:,1)=vDeclus.mDeclusLon(vSelDeclus);
        end
        if exist('mDeclusLat')
            mCat(:,2)=vDeclus.mDeclusLat(vSelDeclus);
        end
        if exist('mDeclusMag')
            mCat(:,6)=vDeclus.mDeclusMag(vSelDeclus);
        end
        % Cut Mc
        vSel=(mCat(:,6)>=params.fMc);
        mCat=mCat(vSel,:);
        % Distances to grid point for catalog with uncertainties
        [vDistances] = ex_MapDist3D(mCat, [fLon0 fLat0], fDepth);

        % take only events for this Radius
        mCat=mCat(vDistances<mVar(ii,2),:);

        % select events withing Tstart and Tend
        vSel1=((mCat(:,3)>params.fTstart)&( mCat(:,3) <= params.fT ) );
        mCat=mCat(vSel1,3);
        mSamples_(jj)=sum(vSel1);
        % calculate real z-values
        [mZ(jj,ii)]=calc_zlta4(mCat,params.fTstart,params.fT,mVar(ii,1),...
               params.vTbin);
        % calculate real z-values
        [mB(jj,ii)]=calc_beta4(mCat,params.fTstart,params.fT,mVar(ii,1),...
                params.vTbin);
    end


    %% loop over grid nodes to create synthetic catalogs
    for jj=1:params.nMCS
        % create synthetic catalogs to estimate significance level
        % reset random number generator
        rand('twister',sum(100*clock));
        % rand('seed');
        if mSamples_(jj)>=0
            mSyn=rand(ceil(mSamples_(jj)),1).*(params.fT-params.fTstart)+params.fTstart;
            % calculate z(lta)-values for synthetic catalog
            [mSynZ(jj,ii)]=calc_zlta4(mSyn,params.fTstart,params.fT,mVar(ii,1),...
                params.vTbin);
            % calculate beta-values for synthetic catalog
            [mSynB(jj,ii)]=calc_beta4(mSyn,params.fTstart,params.fT,mVar(ii,1),...
                params.vTbin);
            % calculate z(lta) values for synthetic catalog
            %        [mSynBeta(ii,:)]=calc_zlta4(mSyn,mSyn,params);
        else
            mSynZ(jj,ii)=nan;
            mSynB(jj,ii)=nan;
        end
    end

%     mSynZ=mSynZ';
%     mSynB=mSynB';

end
% END FOR EACH mVar
    %% prepare statistics

    % sort mZ und mSynZ
    mZs=sort(mZ,1);
    mSynZs=sort(mSynZ,1);
    % prepare mZ and mSynZ for cdf
    mInf=repmat([-25; 25],1,size(mZ,2));
    mZs=[mInf(1,:); mZs; mInf(end,:)];
    mSynZs=[mInf(1,:); mSynZs; mInf(end,:)];
    % recorrect for gridnodes with not enough data
    vSelNoZ=(sum(isnan(mSynZs))==params.nMCS);
    mSynZs(:,vSelNoZ)=nan(size(mSynZs,1),sum(vSelNoZ));
    % Preallocate Vectors and Matrices for Z
    vPolZ=nan(size(mZ,2),1);
    vXolZ=vPolZ;

    % sort mB und mSynB
    mBs=sort(mB,1);
    mSynBs=sort(mSynB,1);
    % prepare mZ and mSynZ for cdf
    mInf=repmat([-25; 25],1,size(mB,2));
    mBs=[mInf(1,:); mBs; mInf(end,:)];
    mSynBs=[mInf(1,:); mSynBs; mInf(end,:)];
    % recorrect for gridnodes with not enough data
    vSelNoB=(sum(isnan(mSynBs))==params.nMCS);
    mSynBs(:,vSelNoB)=nan(size(mSynBs,1),sum(vSelNoB));
    % Preallocate Vectors and Matrices for Z
    vPolB=nan(size(mB,2),1);
    vXolB=vPolB;

 %% statistics - calc probability values
    for i=1:size(mZ,2);
        if ~vSelNoZ(i) && ~vSelNoB(i)
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
%             % calculate mean and std of Z and B
%             vMeanZ(i)=nanmean(mZ(:,i),1);
%             vMeanB(i)=nanmean(mB(:,i),1);
%             vStdZ(i)=nanstd(mZ(:,i),1);
%             vStdB(i)=nanstd(mB(:,i),1);
        end
    end

mParvar.X=vRadius;
mParvar.Y=vTw;
mParvar.mPolZ=reshape(vPolZ',size(mParvar.Y,1),size(mParvar.X,1));
save mParavar.mat mParvar -mat
[pathstr, name, ext, versn] = fileparts(sFilename1);
eval(sprintf('save %s-Lon%08.3f-Lat%07.3f-Z%03.0f.mat mParvar -mat',...
    name,fLon0, fLat0, fDepth))
figure;pcolor(mParvar.X,mParvar.Y,calc_ProbColorbar2Value(1-mParvar.mPolZ));
cmin=-4;cmax=4;
plot_ProbColorbar2(cmin, cmax);
shading interp;


