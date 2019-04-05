function [fMc, mcCalculator] = calc_Mc(mCatalog, calcMethod, binInterval, mcCorrectionFactor)
    % CALC_MC Calculates the magnitude of completeness for a given catalog
    %
    % fMc = CALC_MC(mCatalog, nMethod, binInterval, mcCorrectionFactor)
    % [fMc, mc_calculator] = CALC_MC(...) returns a function handle to the calculation
    % method, so it can be reused in heavy loops.  MC_CALCULATOR has the form:
    %    fMc =  MY_CALCULATOR(catalog, bins, correction);
    %
    % --------------------------------------------------------------------
    %
    %
    % Input parameters:
    %   mCatalog       Earthquake catalog for determing the magnitude of completeness
    %   calcMethod        Method to determine the magnitude of completeness
    %                     see: McMethods for a list of valid values
    %   binInterval       Binning of catalog's magnitudes (default 0.1)
    %   mcCorrectionFactor  Correction term to be added to fMc (default 0)
    %
    % Output parameters:
    %   fMc            Magnitude of completeness
    %   mc_calculator
    %
    %
    % Copyright (C) 2004 by Danijel Schorlemmer, Jochen Woessner
    
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
    
    % Magnitude binning
    if ~exist('binInterval', 'var') || isempty(binInterval)
        binInterval = 0.1;
    end
    if ~isa(calcMethod,'McMethods')
        error('Expected an actual method (McMethods) but received something else.\n See McMethods');
    end
    % Correction
    if ~exist('mcCorrectionFactor', 'var') || isempty(mcCorrectionFactor)
        mcCorrectionFactor = 0;
    end
    useNumeric = isnumeric(mCatalog) || (ischarlike(mCatalog) && mCatalog == "AsMagnitudes");
    if useNumeric
        switch calcMethod
            case McMethods.MaxCurvature
                methodFun = @calc_McMaxCurvature;
                
            case  McMethods.FixedMc
                methodFun = @min;
                
            case  McMethods.Mc90
                methodFun = @(C)method_mc90(C,binInterval);
                
            case  McMethods.Mc95
                methodFun = @(C)method_mc95(C,binInterval);
                
            case McMethods.McBestCombo
                methodFun = @(C)method_bestcombo(C,binInterval);
                
            case  McMethods.McEMR
                error('this only works with full catalogs')
                %methodFun = @(C)calc_McEMR(C,binInterval); %requires catalog Magnitude AND Date
                
            case  McMethods.McDueB_ShiBolt
                methodFun = @(C)calc_Mcdueb(C, binInterval);
                
            case McMethods.McDueB_Bootstrap
                nSample     = 500;
                nWindowSize = 5;
                nMinEvents  = 50;
                methodFun   = @(C) calc_McduebBst(C, binInterval, nWindowSize, nMinEvents,nSample);
                
            case McMethods.McDueB_Cao
                methodFun = @(C, ~)calc_McduebCao(C);
                
            otherwise
                error('unknown Mc method');
        end
    else % catalog object
        switch calcMethod
            case McMethods.MaxCurvature
                methodFun = @(C)calc_McMaxCurvature(C.Magnitude);
                
            case  McMethods.FixedMc
                methodFun = @(C) min(C.Magnitude);
                
            case  McMethods.Mc90
                methodFun = @(C)method_mc90(C.Magnitude,binInterval);
                
            case  McMethods.Mc95
                methodFun = @(C)method_mc95(C.Magnitude,binInterval);
                
            case McMethods.McBestCombo
                methodFun = @(C)method_bestcombo(C.Magnitude,binInterval);
                
            case  McMethods.McEMR
                methodFun = @(C)calc_McEMR(C,binInterval); %requires catalog Magnitude AND Date
                
            case  McMethods.McDueB_ShiBolt
                methodFun = @(C)calc_Mcdueb(C.Magnitude, binInterval);
                
            case McMethods.McDueB_Bootstrap
                nSample     = 500;
                nWindowSize = 5;
                nMinEvents  = 50;
                methodFun   = @(C) calc_McduebBst(C.Magnitude, binInterval, nWindowSize, nMinEvents,nSample);
                
            case McMethods.McDueB_Cao
                methodFun = @(C, ~)calc_McduebCao(C.Magnitude);
                
            otherwise
                error('unknown Mc method');
        end
    end
    
    % lock the method into this calculation
    mcCalculator = @(C) do_calculation(methodFun, C, mcCorrectionFactor);

    if ~isempty(mCatalog)
        % do the calculation
        fMc = mcCalculator(mCatalog);
    else
        fMc = [];
    end
    
end

function fMc = do_calculation(methodFun, mCatalog, mcCorrectionFactor)
    if isempty(mCatalog) || ischarlike(mCatalog)
        fMc = nan;
        return
    end
    
    fMc = methodFun(mCatalog);
    
    % Check fMc
    if isempty(fMc)
        fMc = nan;
    end
    
    % Apply correction
    fMc = fMc + mcCorrectionFactor;
end

% functions to return that all have same signature
function fMc = method_mc90(mags, binInterval)
    [~, ~, fMc] = calc_McBest(mags, binInterval);
end

function fMc = method_mc95(mags, binInterval)
    [~, fMc] = calc_McBest(mags, binInterval);
end

function fMc = method_bestcombo(mags, binInterval)
        [~, Mc95, Mc90] = calc_McBest(mags, binInterval);
        if ~isnan(Mc95)
            fMc = Mc95;
        elseif ~isnan(Mc90)
            fMc = Mc90;
        else
            fMc = calc_McMaxCurvature(mags);
        end
end


