function relm_PaintSet(vRelm_LTest, vRelm_RTest)

figure

nLen = length(vRelm_LTest);
for nCnt = 1:nLen
  H = subplot(nLen, 2, (nCnt*2)-1);
  relm_PaintCumPlot(vRelm_LTest(nCnt), 'Log-Likelihood', H);
  H = subplot(nLen, 2, (nCnt*2));
  relm_PaintCumPlot(vRelm_RTest(nCnt), 'Log-Likelihood Ratio', H);
end

