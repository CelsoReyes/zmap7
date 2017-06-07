function plot_catalog(mCatalog, vMain,bFaults)

if bFaults
    load ~/data/faults/mCA-faults.mat
end
figure
plot(mCatalog(:,1),mCatalog(:,2),'k.');
hold on;plot(mCatalog(~vMain,1),mCatalog(~vMain,2),'r.');
xlim([-118.2 -115]);
ylim([32 36]);
set(gca,'FontSize',16);
if bFaults
    hold on; plot(mFaults(:,1),mFaults(:,2),'k-','LineWidth',1);
end

figure
plot(mCatalog(:,3),cumsum(ones(size(mCatalog,1),1)),'r',...
    'LineWidth',2);
hold on;plot(mCatalog(:,3),cumsum(vMain),'k',...
    'LineWidth',2);
set(gca,'FontSize',16);

