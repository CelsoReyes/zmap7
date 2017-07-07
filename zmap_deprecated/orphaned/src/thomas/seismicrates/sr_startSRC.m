function [ params ]= sr_startSRC
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
TT0=clock;
% go to directory
cd ~/zmap/src/thomas;
% load path's
initialize

% load parameter
params=get_parameterSRC;

% set local parameter
% nMode=params.nMode;             % 0:MCS, 1:rates, 2:MCS+rates
% bDeclus=params.bDeclus;       % 0:Load Declusterd Catalog, 1:no declustering

% figure;

%% no of simulations
nJ=params.nMCS;
% preallocations
vNAN=nan(nJ,1);
vZMain=vNAN;
vProbMain=vNAN;
vZComp=vNAN;
vProbComp=vNAN;
vZDeclus=vNAN;
vProbDeclus=vNAN;

for jj=1:nJ
    disp(sprintf('Simulation (nMCS)  No. %d', jj));
    %% calculate Polygon

%     if params.nSynCat>0
%         bNotInPoly=true;
%         %         mPolygon=[[-115.7314 33.9043];[-116.6239 35.0019];
%         %             [-116.9413 35.0110];[-116.9162 33.2759];[-115.7377 33.2349];
%         %               [-115.7314 33.9043]];
%
%         mPolygon=[[-116.9393 35.0193];[-116.9342 34.8028];[-116.6124 34.8183];
%             [-116.5255 34.6559];[-116.9342 34.6637];[-116.9189 33.2796];
%             [-115.8563 33.2564];[-116.5511 33.6817];[-116.4336 33.8595];
%             [-116.0147 33.6121];[-115.7695 33.6044];[-115.7695 33.9369];
%             [-115.9176 34.3853];[-116.4745 35.0425];[-116.9393 35.0193]];
%
%         %     figure;plot(mPolygon(:,1),mPolygon(:,2),'-');
%         while bNotInPoly
%             fLatmin=33;fLatmax=35.2;
%             fLonmin=-117.1;fLonmax=-115.6;
%             vLoc(:,jj)=rand(2,1).*([ fLonmax-fLonmin fLatmax-fLatmin]')+([fLonmin fLatmin ]');
%             params.mPSQ=[vLoc(2,jj) vLoc(1,jj) 500];
%             bInPoly=inpoly([vLoc(1,jj) vLoc(2,jj)],mPolygon);
%             bNotInPoly=~bInPoly;
%             if bNotInPoly
%                 hold on;plot(vLoc(1,jj),vLoc(2,jj),'rx');
%             else
%                 hold on;plot(vLoc(1,jj),vLoc(2,jj),'gx');
%             end
%
%         end
%         params.mPSQ=[vLoc(1,jj) vLoc(2,jj) 500];
%     else
        params.mPSQ=[-116.4 34.3 500];
        vLoc=[params.mPSQ(1) params.mPSQ(2)];
%     end



    params.vN=params.mPSQ(3);
    [params.mPolygon,params.vX,params.vY,params.vUsedNodes]=calc_Polygon([params.mPSQ(1) params.mPSQ(1)], ...
        [params.mPSQ(2) params.mPSQ(2)],0.1,0.1);
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
    else
        vMain=true(size(params.mCatalog,1),1);
    end


    %% only mainshocks;
    if params.nSynCat>0
        vSel=(params.mCatalog(:,6)>=params.fMc);
        mCat=params.mCatalog((logical(vMain)&vSel),:);

        % Create Index Catalog (only for 1 grid node => params.mPolygon)
        [caNodeIndices, vResolution_] = ex_CreateIndexCatalog(mCat,...
            [params.mPolygon(1) params.mPolygon(2)], 1, params.nGriddingMode,...
            params.fResolution,params.fRadius, 0.1, 0.1);
        caNodeIndices_=cell2mat(caNodeIndices);
        %     vResolution_1=cell2mat(vResolution_);

        % Select event for this particular node
        vSel=((mCat(caNodeIndices_,3)>params.fTstart) & (mCat(caNodeIndices_,3)<=params.fT));
        caNo=caNodeIndices_(vSel);
        mMain{jj}=sort(mCat(caNo,3));
        mCat=mMain{jj};
        mCat1=mCat((mCat<(params.fT-params.vTw)) & (mCat>params.fTstart));
        mCat2=mCat((mCat>(params.fT-params.vTw)) & (mCat<params.fT));

        % calculate z-value
        try % catch error if there are to many events for calc_zlta within radius around node
            [vZMain(jj) vProbMain(jj)]=calc_zlta(mCat,mCat1,mCat2,params.fTstart,params.fT,...
                params.vTw,params.vTbin,size(mCat,1));
        catch ME
            % set nN to 10,000
            [vZMain(jj) vProbMain(jj)]=calc_zlta(mCat,mCat1,mCat2,params.fTstart,params.fT,...
                params.vTw,params.vTbin,10000);
        end
        %     figure;plot(params.mPolygon(:,1),params.mPolygon(:,2),'rx');
        %     hold on;plot(mCat(caNodeIndices_(1:params.vN),1),mCat(caNodeIndices_(1:params.vN),2),'.');
        %     hold on;plot(mCat(caNo(1:params.vN),1),mCat(caNo(1:params.vN),2),'ko');
        %     hold on;plot(sort(mCat),1:size(mCat),'-','Color',[0.7 0.7 0.7]);
        clear mCat
    end

    %% complete catalog;
    vSel=(params.mCatalog(:,6)>=params.fMc);
    mCat=params.mCatalog(vSel,:);

    % Create Index Catalog (only for 1 grid node => params.mPolygon)
    [caNodeIndices, vResolution_] = ex_CreateIndexCatalog(mCat,...
        [params.mPolygon(1) params.mPolygon(2)], 1, params.nGriddingMode,...
        params.fResolution,params.fRadius, 0.1, 0.1);
    caNodeIndices_=cell2mat(caNodeIndices);
    %     vResolution_1=cell2mat(vResolution_);

    % Select event for this particular node
    vSel=((mCat(caNodeIndices_,3)>params.fTstart) & (mCat(caNodeIndices_,3)<=params.fT));
    caNo=caNodeIndices_(vSel);
    mComp{jj}=sort(mCat(caNo,3));
    mCat=mComp{jj};
    mCat1=mCat((mCat<(params.fT-params.vTw)) & (mCat>params.fTstart),:);
    mCat2=mCat((mCat>(params.fT-params.vTw)) & (mCat<params.fT),:);

    % calculate z-value
    try % catch error if there are to many events for calc_zlta within radius around node
        [vZComp(jj) vProbComp(jj)]=calc_zlta(mCat,mCat1,mCat2,params.fTstart,params.fT,...
            params.vTw,params.vTbin,size(mCat,1));
    catch ME
        % set nN to 10,000
        [vZComp(jj) vProbComp(jj)]=calc_zlta(mCat,mCat1,mCat2,params.fTstart,params.fT,...
            params.vTw,params.vTbin,10000);
    end
    %     figure;plot(params.mPolygon(:,1),params.mPolygon(:,2),'rx');
    %     hold on;plot(mCat(caNodeIndices_(1:params.vN),1),mCat(caNodeIndices_(1:params.vN),2),'.');
    %     hold on;plot(mCat(caNo(1:params.vN),1),mCat(caNo(1:params.vN),2),'ko');
    %     hold on;plot(sort(mCat),1:size(mCat),'-','Color',[0 0.5 0.5]);
    clear mCat

    %% decluster catalog
    mCat=params.mCatalog;
    % Hypocenter shift
    if params.bHypo
        % create first mDelta
        if isempty(params.mDeltaHypo)
            mDelta=params.mHypo;
            mDelta=repmat(mDelta,size(mCat,1),1);
        else
            mDelta=params.mDeltaHypo;
        end
        [mCat, mHyposhift]=calc_hyposhift(mCat,mDelta,true);
    end

    % Magnitude uncertainties
    if params.bMag
        % create first mDeltaMag
        if isempty(params.mDeltaMag)
            mDeltaMag=params.mMag;
            mDeltaMag=repmat(mDeltaMag,size(mCat,1),1);
        else
            mDeltaMag=params.mDeltaMag;
        end
        [mCat, mMagShift]=calc_magerr(mCat,mDeltaMag);
    end

    % Cut Mc
    vSel=(mCat(:,6)>=params.fMc);
    mCat=mCat(vSel,:);
    disp(sprintf('The clustered catalog consists of %6.0f with M>= %3.1f',size(mCat,1),params.fMc));

    % decluster
    if params.nMode==2
        mNumDeclus_=zeros(size(mCat,1),1);
        [declusCat,mNumDeclus_] = MonteDeclus(mCat,...
            params.nSimul,params.nDeclusMode,params.mReasenParam);
        %            params.mNumDeclus=mNumDeclus_;
        %                 eval(sprintf('save %s/%s%04.0f.mat mNumDeclus_ -mat',name,'vDeclusMain',jj));
        mCat=declusCat;
    end

    % Create Index Catalog (only for 1 grid node => params.mPolygon)
    [caNodeIndices, vResolution_] = ex_CreateIndexCatalog(mCat,...
        [params.mPolygon(1) params.mPolygon(2)], 1, params.nGriddingMode,...
        params.fResolution,params.fRadius, 0.1, 0.1);
    caNodeIndices_=cell2mat(caNodeIndices);
    %     vResolution_1=cell2mat(vResolution_);

    % Select events for this particular node
    vSel=((mCat(caNodeIndices_,3)>params.fTstart) & (mCat(caNodeIndices_,3)<=params.fT));
    caNo=caNodeIndices_(vSel);
    mDeclus{jj}=sort(mCat(caNo,3));
    if size(mDeclus{jj},1)==0
        mDeclus{jj}
    end
    mCat=mDeclus{jj};
    mCat1=mCat((mCat<(params.fT-params.vTw)) & (mCat>params.fTstart),:);
    mCat2=mCat((mCat>(params.fT-params.vTw)) & (mCat<params.fT),:);

    % calculate z-value
    try % catch error if there are to many events for calc_zlta within radius around node
        [vZDeclus(jj) vProbDeclus(jj)]=calc_zlta(mCat,mCat1,mCat2,params.fTstart,params.fT,...
            params.vTw,params.vTbin,size(mCat,1));
    catch ME
        % set nN to 10,000
        [vZDeclus(jj) vProbDeclus(jj)]=calc_zlta(mCat,mCat1,mCat2,params.fTstart,params.fT,...
            params.vTw,params.vTbin,10000);
    end

    %     figure;plot(params.mPolygon(:,1),params.mPolygon(:,2),'rx');
    %     hold on;plot(mCat(caNodeIndices_(1:params.vN),1),mCat(caNodeIndices_(1:params.vN),2),'.');
    %     hold on;plot(mCat(caNo(1:params.vN),1),mCat(caNo(1:params.vN),2),'ko');
    %     hold on;plot(sort(mCat),1:size(mCat),'-','Color',[0.5 0 0.5]);
    clear mCat
end
R.params=params;
if params.nSynCat>0
    R.mMain=mMain;
    R.vZMain=vZMain;
    R.vProbMain=vProbMain;
    R.vLoc=vLoc;
end

R.mComp=mComp;
R.vZComp=vZComp;
R.vProbComp=vProbComp;

R.mDeclus=mDeclus;
R.vZDeclus=vZDeclus;
R.vProbDeclus=vProbDeclus;
% R.mLoc=vLoc;

R.fMinutes=etime(clock,TT0)/60 ;
sString=sprintf('save %s R -mat',params.sFile);
eval(sString);
sString=sprintf('Results saved in  %s',params.sFile);
disp(sString);
TT1=clock;
etime(TT1,TT0)
