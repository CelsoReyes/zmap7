function [rRelmTest] = relm_LTest4(vRatesH, vRatesN, nNumberSimulation, fMagThreshold, bNormalized, bTestBoth, bDrawFigure)
    % Computation of the R-test for the RELM framework
    %
    % [rRelmTest] = relm_RTest4(vRatesH, vRatesN, nNumberSimulation, fMagThreshold, bNormalized, bTestBoth, bDrawFigure)
    % --------------------------------------------------------------------------------------------------------------------------
    %
    %
    % Input parameters:
    %   vRatesH                       Matrix with rates of the test hypothesis
    %   vRatesN                       Matrix with rates of the null hypothesis
    %   nNumberSimulation             Number of random simulations
    %   fMagThreshold                 Magnitude threshold (Use only bins with magnitude >= threshold
    %   bNormalized                   0 (default): compute likelihoods, 1: compute normalized likelihoods
    %   bTestBoth                     0 (default): simulate only based on the null hypothesis, 1: simulate based on both hypotheses
    %   bDrawFigure                   Draw the cumulative density plot after testing (default: off)
    %
    % Output parameters:
    %   rRelmTest.fAlpha              Alpha-value of the cumulative density
    %   rRelmTest.fBeta               Beta-value of the cumulative density
    %   rRelmTest.vSimValues_H        Vector containing the sorted simulated numbers of events for the test hypothesis
    %   rRelmTest.vSimValues_N        Vector containing the sorted simulated numbers of events for the null hypothesis
    %   rRelmTest.nNumberSimulation   Number of random simulations
    %   rRelmTest.fObservedData       Observed total number of events
    %   rRelmTest.vSimNLike_H         Likelihood of test hypothesis based on simulations of null hypothesis (normalized if bNormalized = true)
    %   rRelmTest.vSimNLike_N         Likelihood of null hypothesis based on simulations of null hypothesis (normalized if bNormalized = true)
    %   rRelmTest.vSimHLike_H         Likelihood of test hypothesis based on simulations of test hypothesis (normalized if bNormalized = true)
    %   rRelmTest.vSimHLike_N         Likelihood of null hypothesis based on simulations of test hypothesis (normalized if bNormalized = true)
    %
    % Copyright (C) 2002-2006 by Danijel Schorlemmer
    %
    % This program is free software; you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation; either version 2 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with this program; if not, write to the
    % Free Software Foundation, Inc.,
    % 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
    
    % Exit on empty rate matrices
    if isempty(vRatesH)  ||  isempty(vRatesN)
        rRelmTest.fAlpha = nan;
        rRelmTest.fBeta = nan;
        rRelmTest.vSimValues_H = nan;
        rRelmTest.vSimValues_N = nan;
        rRelmTest.nNumberSimulation = nan;
        rRelmTest.fObservedData = nan;
        return;
    end
    
    if ~exist('bDrawFigure')
        bDrawFigure = false;
    end
    
    if ~exist('bTestBoth')
        bTestBoth = false;
    end
    
    if ~exist('bNormalized')
        bNormalized = false;
    end
    
    % Randomize
    rng('shuffle');
    
    % Get the necessary data from the rate matrices and weight them properly
    [vLambdaH, vLambdaN, vNumberQuake] = relm_PrepareData(vRatesH, vRatesN, fMagThreshold);
    nNumberQuake = sum(vNumberQuake);
    
    fLikelihood_H = sum(calc_logpoisspdf(vNumberQuake, vLambdaH));
    fLikelihood_N = sum(calc_logpoisspdf(vNumberQuake, vLambdaN));
    
    % Get the number of bins (rows)
    [nRow, nColumn] = size(vLambdaH);
    
    % Create empty vectors for the likelihoods
    vSimLLR_H = [];
    vSimLLR_N = [];
    vSimNLike_H = [];
    vSimNLike_N = [];
    vSimHLike_H = [];
    vSimHLike_N = [];
    
    % Loop over the simulations
    for nCnt = 1:nNumberSimulation
        % Create the random numbers for the simulation
        vRandom = rand(nRow, 1);
        % Compute the simulated number of events and sum them up
        vNum_N = poissinv(vRandom, vLambdaN);
        fSimLike_H = (sum(calc_logpoisspdf(vNum_N, vLambdaH)));
        fSimLike_N = (sum(calc_logpoisspdf(vNum_N, vLambdaN)));
        vSimNLike_H = [vSimNLike_H; fSimLike_H];
        vSimNLike_N = [vSimNLike_N; fSimLike_N];
        vSimLLR_N = [vSimLLR_N; (fSimLike_N - fSimLike_H)];
        if bTestBoth
            % Create the random numbers for the simulation
            vRandom = rand(nRow, 1);
            % Compute the simulated number of events and sum them up
            vNum_H = poissinv(vRandom, vLambdaH);
            fSimLike_H = (sum(calc_logpoisspdf(vNum_H, vLambdaH)));
            fSimLike_N = (sum(calc_logpoisspdf(vNum_H, vLambdaN)));
            vSimHLike_H = [vSimHLike_H; fSimLike_H];
            vSimHLike_N = [vSimHLike_N; fSimLike_N];
            vSimLLR_H = [vSimLLR_H; (fSimLike_N - fSimLike_H)];
        end
    end
    
    if bNormalized
        vSimLLR_N = vSimLLR_N - fLikelihood_N + fLikelihood_H;
        vSimNLike_H = vSimNLike_H - fLikelihood_H;
        vSimNLike_N = vSimNLike_N - fLikelihood_N;
    end
    
    if ~bTestBoth
        vSimLLR_H = vSimLLR_N;
        vSimHLike_H = vSimNLike_H;
        vSimHLike_N = vSimNLike_N;
    else
        if bNormalized
            vSimLLR_H = vSimLLR_H - fLikelihood_N + fLikelihood_H;
            vSimHLike_H = vSimHLike_H - fLikelihood_H;
            vSimHLike_N = vSimHLike_N - fLikelihood_N;
        end
    end
    
    % Sort them for the cumulative density plot
    rRelmTest.vSimValues_H = sort(vSimLLR_H);
    rRelmTest.vSimValues_N = sort(vSimLLR_N);
    
    % Compute Alpha and Beta and store the important parameters
    rRelmTest.fLikelihood_H = fLikelihood_H;
    rRelmTest.fLikelihood_N = fLikelihood_N;
    if bNormalized
        rRelmTest.fObservedData = 0;
    else
        rRelmTest.fObservedData = fLikelihood_N - fLikelihood_H;
    end
    rRelmTest.fAlpha = sum(rRelmTest.vSimValues_N <= rRelmTest.fObservedData)/nNumberSimulation;
    rRelmTest.fBeta = sum(rRelmTest.vSimValues_H >= rRelmTest.fObservedData)/nNumberSimulation;
    rRelmTest.nNumberSimulation = nNumberSimulation;
    rRelmTest.vSimNLike_H = vSimNLike_H;
    rRelmTest.vSimNLike_N = vSimNLike_N;
    rRelmTest.vSimHLike_H = vSimHLike_H;
    rRelmTest.vSimHLike_N = vSimHLike_N;
    rRelmTest.fDeltaSigma = pt_CalcDeltaSig(rRelmTest.vSimValues_N, rRelmTest.fObservedData);
    rRelmTest.fDeltaSigma_H = pt_CalcDeltaSig(rRelmTest.vSimValues_H, rRelmTest.fObservedData);
    
    if bDrawFigure
        relm_PaintCumPlot(rRelmTest, 'Log-likelihood');
    end
end