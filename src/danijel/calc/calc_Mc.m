function [fMc, mc_calculator] = calc_Mc(mCatalog, calcMethod, binInterval, mcCorrectionFactor)
    % CALC_MC Calculates the magnitude of completeness for a given catalog
    %
    % [fMc] = CALC_MC(mCatalog, nMethod, binInterval, mcCorrectionFactor)
    % [fMc, mc_calculator]=CALC_MC(...) will return a function handle to the calculation
    % method, so it can be reused in heavy loops.  MC_CALCULATOR hs the form:
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
    assert(isa(calcMethod,'McMethods'),'Expected an actual method (McMethods) but received something else');
    
    % Correction
    if ~exist('mcCorrectionFactor', 'var') || isempty(mcCorrectionFactor)
        mcCorrectionFactor = 0;
    end
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
            methodFun = @(C)calc_Mcdueb(C,binInterval);
            
        case McMethods.McDueB_Bootstrap
            nSample = 500;
            nWindowSize = 5;
            nMinEvents = 50;
            methodFun = @(C) calc_McduebBst(C.Magnitude, binInterval, nWindowSize, nMinEvents,nSample);

        case McMethods.McDueB_Cao 
            methodFun = @(C, ~)calc_McduebCao(C);

        otherwise
            error('unknown Mc method');
    end
    % lock the method into this calculation
    mc_calculator = @(C) do_calculation(methodFun, C, mcCorrectionFactor);

    % do the calculation
    fMc = mc_calculator(mCatalog);
    
end

function fMc=do_calculation(methodFun, mCatalog, mcCorrectionFactor)
    if isempty(mCatalog) 
        fMc=nan;
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


