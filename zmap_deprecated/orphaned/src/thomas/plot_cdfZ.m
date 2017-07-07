function plot_cdfZ(vResults)

figure;i=1;cdfplot(reshape(vResults(i).mValueGrid,size(vResults(i).mValueGrid,1)*size(vResults(i).mValueGrid,2),1))
hold on;i=2;cdfplot(reshape(vResults(i).mValueGrid,size(vResults(i).mValueGrid,1)*size(vResults(i).mValueGrid,2),1))
hold on;i=3;cdfplot(reshape(vResults(i).mValueGrid,size(vResults(i).mValueGrid,1)*size(vResults(i).mValueGrid,2),1))

legend('a','b','c')
h=get(gca,'Children');

set(h(3),'Color',[0.8 0.8 0.8],'LineWidth',4)
set(h(2),'Color',[0 0 1],'LineWidth',2)
set(h(1),'Color',[1 0 0],'LineWidth',1)
set(gca,'YLim',[-0.05 1.05])
