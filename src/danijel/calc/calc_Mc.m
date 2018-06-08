function [fMc, mc_calculator] = calc_Mc(mCatalog, nMethod, fBinning, fMcCorrection)
    % CALC_MCCalculates the magnitude of completeness for a given catalog
    %
    % [fMc] = CALC_MC(mCatalog, nMethod, fBinning, fMcCorrection)
    % [fMc, mc_calculator]=CALC_MC(...) will return a function handle to the calculation
    % method, so it can be reused in heavy loops.  MC_CALCULATOR hs the form:
    %    fMc =  MY_CALCULATOR(catalog, bins, correction);
    %
    % --------------------------------------------------------------------
    %
    %
    % Input parameters:
    %   mCatalog       Earthquake catalog for determing the magnitude of completeness
    %   nMethod        Method to determine the magnitude of completeness
    %                  1: Maximum curvature
    %                  2: Fixed Mc = minimum magnitude (Mmin)
    %                  3: Mc90 (90% probability)
    %                  4: Mc95 (95% probability)
    %                  5: Best combination (Mc95 - Mc90 - maximum curvature)
    %                  6: Mc using EMR-method
    %                  7: Mc due b using Shi & Bolt uncertainty
    %                  8: Mc due b using bootstrap uncertainty
    %                  9: Mc due b Cao-criterion
    %   fBinning       Binning of catalog's magnitudes (default 0.1)
    %   fMcCorrection  Correction term to be added to fMc (default 0)
    %
    % Output parameters:
    %   fMc            Magnitude of completeness
    %
    % Special function
    %   If called without any parameters, calc_Mc returns a string containing the names
    %   of all available Mc-determination routines
    %
    %
    %
    % Copyright (C) 2004 by Danijel Schorlemmer, Jochen Woessner
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
    
    report_this_filefun(0);
    
    if nargin==1 && ( ischar(mCatalog) || isstring(mCatalog) )&& mCatalog=="getoptions"
        fMc = ['1: Maximum curvature|' ...
            '2: Fixed Mc = minimum magnitude (Mmin)|' ...
            '3: Mc90 (90% probability)|' ...
            '4: Mc95 (95% probability)|' ...
            '5: Best combination (Mc95 - Mc90 - maximum curvature)|' ...
            '6: EMR-method|' ...
            '7: Mc due b using Shi & Bolt uncertainty|' ...
            '8: Mc due b using bootstrap uncertainty|' ...
            '9: Mc due b Cao-criterion'];
        return;
    end
    
    % Magnitude binning
    if ~exist('fBinning', 'var') || isempty(fBinning)
        fBinning = 0.1;
    end
    
    % Correction
    if ~exist('fMcCorrection', 'var') || isempty(fMcCorrection)
        fMcCorrection = 0;
    end
    
    if nMethod == 1
        % Maximum curvature
        methodFun = @(C)calc_McMaxCurvature(C);
    elseif nMethod == 2
        % Fixed Mc (Mc = Mmin)
        methodFun = @(C) min(C.Magnitude);
    elseif nMethod == 3
        % Automatic Mc90
        methodFun = @(C)method_mc90(C,fBinning);
    elseif nMethod == 4
        % Automatic Mc95
        methodFun = @(C)method_mc95(C,fBinning);
    elseif nMethod == 5
        % Best combination (Mc95 - Mc90 - maximum curvature)
        methodFun = @(C)method_bestcombo(C,fBinning);
    elseif nMethod == 6
        % EMR-method
        methodFun = @(C)calc_McEMR(C,fBinning);
    elseif nMethod == 7
        % Mc due b using Shi & Bolt uncertainty
        methodFun = @(C)calc_Mcdueb(C,fBinning);
    elseif nMethod == 8
        % Mc due b using bootstrap uncertainty
        nSample = 500;
        nWindowSize = 5;
        nMinEvents = 50;
        methodFun = @(C) calc_McduebBst(C, fBinning, nWindowSize, nMinEvents,nSample);
    else % nMethod == 9
        % Mc due b Cao-criterion
        methodFun = @(C, ~)calc_McduebCao(C);
    end
    % lock the method into this calculation
    mc_calculator = @(C) do_calculation(methodFun, C, fMcCorrection);

    % do the calculation
    fMc = mc_calculator(mCatalog);
    
end

function fMc=do_calculation(methodFun, mCatalog, fMcCorrection)
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
    fMc = fMc + fMcCorrection;
end

% functions to return that all have same signature
function fMc = method_mc90(mCatalog, fBinning)
    [~, ~, fMc] = calc_McBest(mCatalog, fBinning);
end
function fMc = method_mc95(mCatalog, fBinning)
    [~, fMc] = calc_McBest(mCatalog, fBinning);
end
function fMc = method_bestcombo(mCatalog, fBinning)
        [~, Mc95, Mc90] = calc_McBest(mCatalog, fBinning);
        if ~isnan(Mc95)
            fMc = Mc95;
        elseif ~isnan(Mc90)
            fMc = Mc90;
        else
            fMc = calc_McMaxCurvature(mCatalog);
        end
end


