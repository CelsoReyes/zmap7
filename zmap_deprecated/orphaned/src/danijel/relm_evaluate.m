function relm_evaluate(vResults)

figure

vIndex = [1:vResults.vRelmTest(1).nNumberSimulation]/vResults.vRelmTest(1).nNumberSimulation;
vBlueX = [0,0];
vBlueY = [0,1];

vPatch1Y = [1 1 0.975 0.975];
vPatch2Y = [0.025 0.025 0 0];

for nCnt = 1:7
  subplot(3, 3, nCnt)
  LLR1 = vResults.vRelmTest(nCnt).LLR_H;
  LLR2 = vResults.vRelmTest(nCnt).LLR_N;
  plot(LLR1, vIndex, 'g', LLR2, vIndex, 'r' , vBlueX, vBlueY, 'b', 'linewidth', 1)';
  xlabel('LLR (Var. b/Const. b)')';
  ylabel('Fraction of cases');
  vXLim = xlim;
  vPatch1X = [vXLim(1) 0 0 vXLim(1)];
  vPatch2X = [0 vXLim(2) vXLim(2) 0];
  hold on
  patch(vPatch1X, vPatch1Y, 'y', 'facealpha', 0.9);
  patch(vPatch2X, vPatch2Y, 'y', 'facealpha', 0.9);
  title(['MagThres = ' num2str(vResults.vRelmTest(nCnt).fMagThreshold) ', \alpha = ' num2str(vResults.vRelmTest(nCnt).fAlpha) ', \beta = ' num2str(vResults.vRelmTest(nCnt).fBeta)]);
end
