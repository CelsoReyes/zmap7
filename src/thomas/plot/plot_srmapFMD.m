function plot_srmapFMD
%%
%
%
%
%% Defining the gridpoints that have to be plotted
mGrdPnt=[[-116.4 34.3];...
    [-116.85 34.2];...
    [-116.5 33.5];...
    [-116.95 34.85]];
fYear=1981;
fMc=2;
R=[1500 1500 1500 1500];
% R=[10 10 5 30];
bRadius=true;


%% Getting Data from Result Matrices
clear params
% Load catalogs
cFile=[cellstr(char('08021305-Landers20-reasen-MCS1.mat')),...
    cellstr(char('08021302-Landers-M20-GK2-MCS1.mat')),...
    cellstr(char('08011701-Landers20-misd-MCS1.mat')),...
%     cellstr(char('08021306-Landers20-MCS1.mat')),...
%     cellstr(char('08011401-Landers20-reasen-MCS100.mat')),...
%     cellstr(char('08021305-Landers20-reasen-MCS1.mat')),...
%     cellstr(char('08021302-Landers-M20-GK2-MCS1.mat')),...
%     cellstr(char('08011701-Landers20-misd-MCS1.mat')),...
    ];

for cc=1:size(cFile,2)
    % load result matrice
    clear params
    sString=sprintf('load %s',char(cFile(cc)));
    eval(sString)

    for j=1:size(mGrdPnt,1)
    %calculate nearest grid point
        mDistance=distance(repmat(mGrdPnt(j,2),size(params.mPolygon,1),1),...
            repmat(mGrdPnt(j,1),size(params.mPolygon,1),1),...
            params.mPolygon(:,2),params.mPolygon(:,1));
        [Xi,Ni]=sort(mDistance);
        nCenter(j)=Ni(1)
        vPoly0(j,:)=params.mPolygon(nCenter(j),:)
        %         hold on;plot(vPoly0(1),vPoly0(2),'r*','MarkerSize',10);

        for i=1:size(params.mResult1,3)
            % get indices
            nIndices=params.caNodeIndices{nCenter(j)}(logical(params.mNumDeclus(:,i)));
            nIndices2=params.caNodeIndices{nCenter(j)};

            if bRadius
            vResolution=params.vResolution{nCenter(j)}(logical(params.mNumDeclus(:,i)));
            vResolution2=params.vResolution{nCenter(j)};
%             vRes=vResolution(:);
%             vRes2=vResolution2(:);
            else
                vRes=ones(size(nIndices,1),1);
                vRes2=ones(size(nIndices2,1),1);
            end
            %     nIndices=params.caNodeIndices{nCenter};
            mSample=params.mCatalog(nIndices,:);
%             vRes=vResolution2(nIndices);
            mSample2=params.mCatalog(nIndices2,:);
%             vRes2=vResolution2(nIndices2);
if cc==3
    cc
end
            vSel=((mSample(:,3)>=fYear) & (mSample(:,6)>=fMc)  & (vResolution<=R(j)));
            vSel2=((mSample2(:,3)>=fYear) & (mSample2(:,6)>=fMc) & (vResolution2<=R(j)));
            mSample=mSample(vSel,:);
            mSample2=mSample2(vSel2,:);
            mP(cc).mG(j).mS1(i).R=mSample(:,3);
            mP(cc).mG(j).mS2(i).R=mSample2(:,3);
            % hold on;plot(mSample(:,1),mSample(:,2),'w*')

        end
    end

end

save mP1500.mat mP -mat

%% Plotting Result- FMD's

% plot clustered catalog
figure_w_normalized_uicontrolunits('Position',[0 0 1200 300]);
% loop over selected grid points
for n=1:size(mP(1).mG,2)
    % loop over different result matrices
    for c=1:size(mP,2)
        subplot(1,size(mP(c).mG,2),n)
%         YLim([0 140]);
        XLim([1980 1993]);
        set(gca,'FontSize',14);
        xlabel('Years','fontsize',16);
        if n==1
        ylabel('Cum # Earthquakes','fontsize',16);
        end
        % loop over calculations for each MCS in declus algorithm
        for nS=1:size(mP(c).mG(n).mS1,2)
            hold on;
            h=plot(sort(mP(c).mG(n).mS1(nS).R),...
                (1:size(mP(c).mG(n).mS1(nS).R,1)));
            switch c
                case 1 % clustered catalog
                    set(h,'LineWidth',2,...
                        'Color',[1 0 0],...
                        'LineStyle','-');
                case 2 % reasenberg simulation
                    set(h,'LineWidth',1,...
                        'Color',[.7 .7 .7],...
                        'LineStyle','-');
                case 3 % reasenberg standard
                    set(h,'LineWidth',2,...
                        'Color',[0 0 0],...
                        'LineStyle','-');
                case 4 % GK2
                    set(h,'LineWidth',2,...
                        'Color',[0 0 1],...
                        'LineStyle','-');
                case 5 % MISD
                    set(h,'LineWidth',2,...
                        'Color',[0 0.5 0],...
                        'LineStyle','-');
            end
%             gca;
        end
    end
end
