function [ params ]= sr_startZ
% example sr_startZ
% -------------------------------------------------------------------------
% Function starts toolbox for analysing rate changes. The function
% get_parameter acts as a control file that contains most of the
% parameters.
%
%
% Th. van Stiphout; vanstiphout@sed.ethz.ch
% updated: 17.08.2005


report_this_filefun();

% go to directory
cd ~/zmap/src/thomas;
% load path's
initialize

% load parameter
params=get_parameter;

% set local parameter
nMode=params.nMode;             % 0:MCS, 1:rates, 2:MCS+rates
bDeclus=params.bDeclus;       % 0:Load Declusterd Catalog, 1:no declustering

bSaveIt=0;              % save results 0:no, 1:yes
bDisplayIt=0;          % display results 0: no, 1: yes
% Add coastline
if exist('vCoastline','var')    params.vCoastline = vCoastline; end
% Add faults
if exist('vFaults','var')       params.vFaults = vFaults;       end


% Validate polygonsize
if length(params.vX) < 4 || length(params.vY) < 4
    errordlg('Selection is too small. Please select a larger polygon.');
    return;
end


nJ=params.nMCS;
for jj=1:nJ
    disp(sprintf('Simulation (nMCS)  No. %d', jj));

    % create synthetic catalog
    if params.nSynCat>0
        mCatalog=[];
        while (size(mCatalog,1)>params.nMaxCatSize) || isempty(mCatalog) % keep catalog with etas low
            [mCatalog, vMain] = calc_SynCat(params.nSynCatSize,...
                params.vSynCat,params.nSynCat,params.nSynMode,...
                params.vAfter, params.vEtas,params.mSynCatRef,...
                params.bPSQ,params.vPSQ,params.mPSQ);
            %             [mCatalog, vMain] = calc_SynCat(params.nSynCatSize,2.5,2.5,8,100,...
            %                 'January 1,1975','December 31,1990',6.5,params.nSynCat,...
            %                 params.nSynMode,params.mCatalog,params.vPSQ);
            [Ntmp,Xi]=sort(mCatalog.Date);
            mCatalog=mCatalog.subset(Xi);clear Xi Ntmp;
            params.mCatalog=mCatalog;
            [pathstr, name, ext, versn] = fileparts(params.sFile);
            clear ext versn;
            eval(sprintf('!mkdir %s',name));
            eval(sprintf('save %s/%s%04.0f.mat mCatalog -mat',name,'mCatalog',jj));
            eval(sprintf('save %s/%s%04.0f.mat vMain -mat',name,'vMain',jj));
        end
    end

    if params.nSynCat>0
        mCatalog=params.mCatalog;
    else
        mCatalog=params.mCatRef;
    end

    % Hypocenter shift
    if params.bHypo
        % create first mDelta
        if isempty(params.mDeltaHypo)
            mDelta=params.mHypo;
            mDelta=repmat(mDelta,size(mCatalog,1),1);
        else
            mDelta=params.mDeltaHypo;
        end
        [mCatalog1, mHyposhift]=calc_hyposhift(mCatalog,mDelta,logical(1));
    else
        mCatalog1=mCatalog;
    end

    % Magnitude uncertainties
    if params.bMag
        % create first mDeltaMag
        if isempty(params.mDeltaMag)
            mDeltaMag=params.mMag;
            mDeltaMag=repmat(mDeltaMag,size(mCatalog1,1),1);
        else
            mDeltaMag=params.mDeltaMag;
        end
        [mCatalog2, mMagShift]=calc_magerr(mCatalog1,mDeltaMag);
    else
        mCatalog2=mCatalog1;
    end

    params.mCatalog=mCatalog2;
    clear mCatalog1 mCatalog2;

    switch nMode
        %                 0 : only MCS of declustering +saving of mDeclus&mCatalog
        %                 1 : only calculation of rates
        %                 2 : both 0 + 1
        case 0 % Perform Monte Carlo Simulation for declustering
            mNumDeclus_=zeros(size(params.mCatalog,1),1);
            vSel=(params.mCatalog.Magnitude>=params.fMc);
            [declusCat,mNumDeclus_(vSel)] = MonteDeclus(params.mCatalog.subset(vSel),...
                params.nSimul,params.nDeclusMode,params.mReasenParam);
            if params.nSynCat~=2
                if jj==1
                    params.mNumDeclus=mNumDeclus_;
                else
                    params.mNumDeclus(:,end+1)=mNumDeclus_;clear mNumDeclus_;
                end
            else
                params.mNumDeclus=mNumDeclus_;
                eval(sprintf('save %s/%s%04.0f.mat mNumDeclus_ -mat',name,'vDeclusMain',jj));
            end
            %             save mDeclusNum.mat mDeclusNum
            %             save mDeclusCatOut.mat declusCat
            %             clear mDeclusCatOut mDeclusNum;
        case 1
            switch bDeclus
                case 0  % load declustered catalog
                    declusCat=load('mDeclusCatOut.mat');
                    load mDeclusNum.mat;
                    params.mNumDeclus=mDeclusNum;
                    disp('Calculation of rates / load MC Declustered Catalog')
                case 1 % no declustering / using original catalog with nSimul=1
                    params.mNumDeclus=ones(size(params.mCatalog,1),1);
                    declusCat=[params.mCatalog params.mNumDeclus];
                    params.nSimul=1;
            end
            [params] = sr_calcZ(params);
        case 2
            mNumDeclus_=zeros(size(params.mCatalog,1),1);
            vSel=(params.mCatalog.Magnitude>=params.fMc);
            [declusCat,mNumDeclus_(vSel)] = MonteDeclus(params.mCatalog.subset(vSel),...
                params.nSimul,params.nDeclusMode,params.mReasenParam);
            if params.nSynCat==0
                if jj==1
                    params.mNumDeclus=mNumDeclus_;
                else
                    params.mNumDeclus(:,end+1)=mNumDeclus_;clear mNumDeclus_;
                end
            else
                params.mNumDeclus=mNumDeclus_;
                eval(sprintf('save %s/%s%04.0f.mat mNumDeclus_ -mat',name,'vDeclusMain',jj));
            end

            if params.nLimit<size(params.mPolygon,1)
                % do not calculate all nodes at a time,
                %  split it up to params.nLimit-size
                params.vResolution=[];
                params.mResult_=[];
                params.m1=[];params.m2=[];
                params.m3=[];params.m4=[];

                % use params_ as tmp-variable
                params_=params;

                for nCC=1:ceil(size(params.mPolygon,1)/params.nLimit)
                    [nIdx]=[(nCC-1)*params.nLimit+1, nCC*params.nLimit];
                    if nIdx(2)>size(params.mPolygon,1)
                        nIdx(2)=size(params.mPolygon,1);
                    end
                    % prepare subparts
                    params_.mPolygon=params_.mPolygon(nIdx(1):nIdx(2),:);
                    params_.vUsedNodes=params_.vUsedNodes(nIdx(1):nIdx(2),:);
                    % calculate subpart
                    [params_tmp]=sr_calcZ(params_);

                    params.vResolution=[params.vResolution;params_tmp.vResolution];
                    params.mResult_=[params.mResult_;params_tmp.mResult_];
                    params.mVar=params_tmp.mVar;
                    params.m1=[params.m1;params_tmp.m1];
                    params.m2=[params.m2;params_tmp.m2];
                    params.m3=[params.m3;params_tmp.m3];
                    params.m4=[params.m4;params_tmp.m4];
                    clear params_tmp;
                    params_=params;
                end
            else
                % calculate all nodes at a time,
                [params]=sr_calcZ(params);
            end
    end
    % prelocate mResult*
    if jj==1
        mResult1=nan(size(params.mPolygon,1),5,params.nMCS);
        mResult2=mResult1;
        mResult3=mResult1;
        mResult4=mResult1;
    end

    if (nMode > 0)
        mResult1(:,:,jj)=params.m1;
        mResult2(:,:,jj)=params.m2;
        mResult3(:,:,jj)=params.m3;
        mResult4(:,:,jj)=params.m4;
        disp(sprintf('End of Simulations %d / %d',jj,params.nMCS));
    end
    params.mResult1=mResult1;
    params.mResult2=mResult2;
    params.mResult3=mResult3;
    params.mResult4=mResult4;
    %     bChk=logical(0);
    %     if bChk
    %         figure_w_normalized_uicontrolunits('Position',[100 25 750 600]);
    %         subplot(2,2,1) % plot z(lta)
    %         pcolor(reshape(params.mPolygon(:,1),39,30),reshape(params.mPolygon(:,2),39,30),reshape(params.mResult1(:,1,jj),39,30));colorbar;
    %         title('Z-value');
    %         subplot(2,2,2) % plot z(lta)
    %         pcolor(reshape(params.mPolygon(:,1),39,30),reshape(params.mPolygon(:,2),39,30),reshape((params.mResult2(:,1,jj)),39,30));colorbar;
    %         %         h=colorbar;set(h,'YScale', 'log')
    %         title('Probability of Z-value');
    %         subplot(2,2,3) % plot beta
    %         pcolor(reshape(params.mPolygon(:,1),39,30),reshape(params.mPolygon(:,2),39,30),reshape(params.mResult3(:,1,jj),39,30));colorbar;
    %         title('\beta - value');
    %         subplot(2,2,4) % plot beta
    %         pcolor(reshape(params.mPolygon(:,1),39,30),reshape(params.mPolygon(:,2),39,30),reshape(params.mResult4(:,1,jj),39,30));colorbar;
    %         %         h=colorbar;set(h,'YScale', 'log')
    %         title( 'Probability of \beta - value');
    %     end
end

sString=sprintf('save %s params -mat',params.sFile);
eval(sString);
sString=sprintf('Results saved in  %s',params.sFile);
disp(sString);
% save test_sr_UniformRate.mat params -mat
if (nMode>0)
    if bSaveIt
        vResults=params;
        sString=sprintf('save %s_N%s_Rmax%s_nSim%s_nMode%s.mat vResults',...
            rContainer,num2str(params.vN),...
            num2str(params.fMaxRadius),...
            num2str(params.nSimul),...
            num2str(params.nDeclusMode) );
        eval(sString)
        disp(sString)
    end
    if bDisplayIt
        gui_result(params);
    end
end
