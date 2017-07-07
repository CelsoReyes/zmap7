function [nMisfit_H, nMisfit_N] = relm_TotalMisfitNTest(rRelmTest)

nMisfit_H = sum(abs(rRelmTest.vSimValues_H - rRelmTest.fObservedData));
nMisfit_N = sum(abs(rRelmTest.vSimValues_N - rRelmTest.fObservedData));
