% function plot_srErrorOrigin
% %
% %
% %
% % Author: van Stiphout, Thomas, vanstiphout@sed.ethz.ch

fRes=10000;
vEdges=[-9.9:0.2:9.9];

% Plot-list
sPlotList=['mCompose.m05';...
           'mCompose.m06';...
           'mCompose.m07';...
           'mCompose.m08';...
%            'mCompose.m12';...
           'mCompose.m13'];


mColorLine=lines(size(sPlotList,1));

figure;
for i=1:size(sPlotList,1)
    if i==1
       subplot(2,1,1)
    else
        hold on;
    end
    eval(sprintf('mPlotit=%s.mResult1;',sPlotList(i,:)));
    vVal=reshape(squeeze(mPlotit(:,1,:)),...
    size(mPlotit,1)*size(mPlotit,3),1);
vRes=reshape(squeeze(mPlotit(:,2,:)),...
    size(mPlotit,1)*size(mPlotit,3),1);
% vSel=(vRes<fRes);
N=histc(vVal,vEdges);
plot(vEdges,N,'Color',mColorLine(i,:),'LineWidth',2);
clear X N mPlotit vVal vRes
end
legend(sPlotList,'location','NW');


% % probZ
% for i=1:size(sPlotList,1)
%     if i==1
%                 subplot(2,2,2)
%     else
%         hold on;
%     end
%     eval(sprintf('mPlotit=%s.mResult2;',sPlotList(i,:)));
%     vVal=reshape(squeeze(mPlotit(:,1,:)),...
%     size(mPlotit,1)*size(mPlotit,3),1);
% vRes=reshape(squeeze(mPlotit(:,2,:)),...
%     size(mPlotit,1)*size(mPlotit,3),1);
% vSel=(vRes<fRes);
% [N,X]=histogram(calc_ProbColorbar2Value(vVal(vSel)),20);
% plot(X,N,'Color',mColorLine(i,:),'LineWidth',2);
% clear X N;
% end


% % cdf plots Z
% for i=1:size(sPlotList,1)
%     if i==1
%                 subplot(2,2,3)
%     else
%         hold on;
%     end
%     eval(sprintf('mPlotit=%s.mResult1;',sPlotList(i,:)));
%     vVal=reshape(squeeze(mPlotit(:,1,:)),...
%     size(mPlotit,1)*size(mPlotit,3),1);
% vRes=reshape(squeeze(mPlotit(:,2,:)),...
%     size(mPlotit,1)*size(mPlotit,3),1);
% vSel=(vRes<fRes);
% [h,stats(i)] = cdfplot(vVal(vSel));
% set(h,...
%     'Color',mColorLine(i,:),'LineWidth',2);
% end
% sLegend=[];
% for i=1:size(sPlotList,1)
%     sTmp=sprintf('mean=%s,std=%s',...
%         num2str(stats(i).mean,'%6.4f'),num2str(stats(i).std));
%     sLegend=[sLegend;sTmp]
% end
% legend(sLegend,'location','NW');

% cdf prob Z
for i=1:size(sPlotList,1)
    if i==1
       subplot(2,1,2)
    else
        hold on;
    end
    eval(sprintf('mPlotit=%s.mResult2;',sPlotList(i,:)));
    vVal=reshape(squeeze(mPlotit(:,1,:)),...
    size(mPlotit,1)*size(mPlotit,3),1);
vRes=reshape(squeeze(mPlotit(:,2,:)),...
    size(mPlotit,1)*size(mPlotit,3),1);
% vSel=(vRes<fRes);
[h,stats(i)] = cdfplot(calc_ProbColorbar2Value(vVal));
set(h,...
    'Color',mColorLine(i,:),'LineWidth',2);
end

% sLegend=[];
% for i=1:size(sPlotList,1)
%     sTmp=sprintf('mean=%s,std=%smin=%s,max=%s',...
%         num2str(stats(i).mean,'%010.5f'),num2str(stats(i).std,'%010.5f'),...
%         num2str(stats(i).min,'%010.5f'), num2str(stats(i).max,'%010.5f'));
%     sLegend=[sLegend;sTmp];
% end
% legend(sLegend,'location','NW');

