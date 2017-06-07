function[depCat,indCat] = FindDecLoc()

load /Users/matt/MonteDeclus/results/DeclusResRfact.mat

[lCat, numCats] = size(decResult);

countCat = zeros(1,10);

for catLoop = 1:numCats
    decCat = decResult{catLoop};
    is5 = decCat(:,6) >= 5;
    decCat = decCat(is5,:);
    [lDC, wDC] = size(decCat);
    for cLoop = 1:lDC
        isIn = decCat(cLoop,1) == countCat(:,1) & decCat(cLoop,2) == countCat(:,2) & decCat(cLoop,3) == countCat(:,3);
        %isIn = decCat(cLoop,:) == countCat(:,:);
        if sum(isIn) > 0
            countCat(isIn,10) = countCat(isIn,10) + 1;
        else
            dCat = [decCat(cLoop,:) 1];
            countCat = [countCat;dCat];
        end
    end
end

independent = countCat(:,10) == numCats;
indCat = (countCat(independent,:));
countCat(independent,:) = [];
depCat = countCat;
