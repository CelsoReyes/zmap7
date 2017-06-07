function plot_PointInfo(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% ginput(nPoints);

fYear=params.fTstart;
fMc=params.fMc;
fMc=2.0
[fLon0,fLat0]=ginput(1);
hold on;plot(fLon0,fLat0,'kx','MarkerSize',10);

%calculate nearest grid point
mDistance=distance(repmat(fLat0,size(params.mPolygon,1),1),...
    repmat(fLon0,size(params.mPolygon,1),1),...
    params.mPolygon(:,2),params.mPolygon(:,1));
[Xi,Ni]=sort(mDistance);
nCenter=Ni(1)
vPoly0=params.mPolygon(nCenter,:)
hold on;plot(vPoly0(1),vPoly0(2),'r*','MarkerSize',10);

for i=1:size(params.mNumDeclus,2)
    nIndices=params.caNodeIndices{nCenter}(logical(params.mNumDeclus(:,i)));
    nIndices2=params.caNodeIndices{nCenter};
%     nIndices=params.caNodeIndices{nCenter};
    mSample=params.mCatalog(nIndices,:);
    mSample2=params.mCatalog(nIndices2,:);
    vSel=((mSample(:,3)>=fYear) & (mSample(:,6)>=fMc));
    vSel2=((mSample2(:,3)>=fYear) & (mSample2(:,6)>=fMc));
    mSample=mSample(vSel,:);
    mSample2=mSample2(vSel2,:);
    mSample=mSample(1:params.vN,:);
    mSample2=mSample2(1:params.vN,:);
    % hold on;plot(mSample(:,1),mSample(:,2),'w*')

    if i==1
        figure;
    else
        hold on;
    end
i;
    plot(sort(mSample(:,3)),(1:size(mSample,1)),'LineWidth',2);
    if i==1
        hold on;plot(sort(mSample2(:,3)),(1:size(mSample,1)),...
        'r','LineWidth',2);
    end
end

    plotshape;

   function plotshape
        xlabel('Time [Yrs]','FontSize',14);
        ylabel('Cum # of Earthquakes','FontSize',14);
        set(gca,'FontSize',12);
%         set(gcf,'Renderer','zbuffer');
%         shading interp;

%
%
% for i=1:size(params.mNumDeclus,2)
%     vSel=( (params.mCatalog(:,3)>=fYear) & ...
%     (params.mCatalog(:,6)>=fMc) & ...
%     (params.mNumDeclus(:,i)==1) );
%     if i==1
%         figure;
%         plot(params.mCatalog(vSel,3),...
%             cumsum(params.mNumDeclus(vSel,i)),...
%             '-','LineWidth',1,'Color',[.8 .8 .8]);
%     else
%         hold on;
%         plot(params.mCatalog(vSel,3),...
%             cumsum(params.mNumDeclus(vSel,i)),...
%             '-','LineWidth',1,'Color',[.8 .8 .8]);
%     end
% end
%
% set(gca,'FontSize',16)
% xlabel('Years','fontsize',20)
% ylabel('Cum # Earthquakes','fontsize',20)
% % legend('Reasenberg 1985, Xmeff=3.0',...
% %     'Reasenberg (Helmstetter 2007), Xmeff=3.0',...
% %     'Reasenberg 1985, Xmeff=2.5',...
% %     'Reasenberg 1985, Xmeff=2.0',...
% %     'Reasenberg 1985, Xmeff=1.5',...
% %     'Gardner & Knopoff 1974',...
% %     'Utsu 2002',...
% %     'Uhrhammer 1986');
