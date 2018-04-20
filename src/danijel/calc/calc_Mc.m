function [fMc] = calc_Mc(mCatalog, nMethod, fBinning, fMcCorrection)
    % function [fMc] = calc_Mc(mCatalog, nMethod, fBinning, fMcCorrection)
    % --------------------------------------------------------------------
    % Calculates the magnitude of completeness for a given catalog
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
    
    if nargin == 0
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
        fMc = calc_McMaxCurvature(mCatalog);
    elseif nMethod == 2
        % Fixed Mc (Mc = Mmin)
        fMc = min(mCatalog.Magnitude);
    elseif nMethod == 3
        % Automatic Mc90
        [~, ~, fMc] = calc_McBest(mCatalog, fBinning);
    elseif nMethod == 4
        % Automatic Mc95
        [~, fMc, ~] = calc_McBest(mCatalog, fBinning);
    elseif nMethod == 5
        % Best combination (Mc95 - Mc90 - maximum curvature)
        [~, Mc95, Mc90] = calc_McBest(mCatalog, fBinning);
        if ~isnan(Mc95)
            fMc = Mc95;
        elseif ~isnan(Mc90)
            fMc = Mc90;
        else
            fMc = calc_McMaxCurvature(mCatalog);
        end
    elseif nMethod == 6
        % EMR-method
        fMc = calc_McEMR(mCatalog, fBinning);
    elseif nMethod == 7
        % Mc due b using Shi & Bolt uncertainty
        fMc = calc_Mcdueb(mCatalog);
    elseif nMethod == 8
        % Mc due b using bootstrap uncertainty
        nSample = 500;
        fMc = calc_McduebBst(mCatalog, fBinning, 5, 50,nSample);
    else % nMethod == 9
        % Mc due b Cao-criterion
        fMc = calc_McduebCao(mCatalog);
    end
    
    % Check fMc
    if isempty(fMc)
        fMc = nan;
    end
    
    % Apply correction
    fMc = fMc + fMcCorrection;
end
