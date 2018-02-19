function [fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog, fBinning)
    % function [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog, fBinning)
    % ---------------------------------------------------------------------------------
    % Calculates the mean magnitute, the b-value based
    % on the maximum likelihood estimation, the a-value and the
    % standard deviation of the b-value
    %
    % Input parameters:
    %   mCatalog        vector of magnitudes
    %   fBinning        Binning of the earthquake magnitudes (default 0.1)
    %
    % Output parameters:
    %   fBValue         b-value
    %   fStdDev         Standard deviation of b-value
    %   fAValue        a-value
    %
    % Copyright (C) 2003 by Danijel Schorlemmer based on Stefan Wiemer's code,
    % now modified by CGReyes
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
    
    global bDebug;
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end
    
    
    % Set the default value if not passed to the function
    if ~exist('fBinning','var')
        fBinning = 0.1;
    end
    
    if isa(mCatalog,'ZmapCatalog')
        vMag = mCatalog.Magnitude;
    elseif isnumeric(mCatalog)
        vMag = mCatalog;
    else
        error('do not recognize mCatalog as vector of magnitudes or  as a ZmapCatalog');
    end
    
    if isempty(vMag)
        disp('No magnitude data available!');
        return
    end
    
    % Calculate the minimum and mean magnitude, length of catalog
    nLen = length(vMag);
    fMinMag = min(vMag);
    fMeanMag = mean(vMag);
    % Calculate the b-value (maximum likelihood)
    fBValue = (1/(fMeanMag-(fMinMag-(fBinning/2))))*log10(exp(1));
    
    if nargout >1
        % Calculate the standard deviation
        fStdDev = (sum((vMag-fMeanMag).^2))/(nLen*(nLen-1));
        fStdDev = 2.30 * sqrt(fStdDev) * fBValue^2;
    end
    
    if nargout>2
        % Calculate the a-value
        fAValue = log10(nLen) + fBValue * fMinMag;
    end
end