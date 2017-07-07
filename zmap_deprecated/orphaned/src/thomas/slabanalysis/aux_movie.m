function aux_parkfield(vResult, hParentFigure)

hSets = gui_result2('GetDatasetsHandle', hParentFigure, [], guidata(hParentFigure));
sList = get(hSets, 'String');
nLen = length(sList);
vResults = gui_result2('GetResults', hParentFigure, [], guidata(hParentFigure));


nCS=[[-154.01 60.88 -150.50 60.37];
    [-153.45 61.68 -149.81 61.21]];

for nCnt = 1:size(nCS,1)  % nLen

    vResults(nLen+nCnt)=aux_cs2(vResults(nCnt),nCS(nCnt,:));

    hPlot = gui_result2('GetFigureHandle', hParentFigure, [], guidata(hParentFigure));
    %   exportfig(hPlot, [num2str(nCnt) '.eps'], 'Color', 'cmyk');

end

save vResults_CS.mat vResults -mat

disp('Calc of CS finished: vResults_CS.mat')
