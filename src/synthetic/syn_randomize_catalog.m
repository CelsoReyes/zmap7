function [randCat] = syn_randomize_catalog(mCatalog, bLon, bLat, bDepth, bTimes, nMagnitudes, fBValue, fMc, fInc)
    %  Randomizes a given catalog.
    %
    %  [randCat] = syn_randomize_catalog(mCatalog, bLon, bLat, bDepth,
    %                                                   bTimes, nMagnitudes, fBValue, fMc, fInc)
    %
    %
    % Input parameters:
    %   mCatalog          Catalog for randomizing
    %   bLon              Perturb longitudes (true) or leave longitudes unchanged (false)
    %   bLat              Perturb latitudes (true) or leave latitudes unchanged (false)
    %   bDepth            Perturb depths (true) or leave depths unchanged (false)
    %   bTimes            Perturb focal times (true) or leave focal times unchanged (false)
    %   nMagnitudes       Magnitude switch
    %                     1: Leave magnitudes unchanged
    %                     2: Generate new magnitudes according to parameters fBValue, fMc, fInc
    %                     3: Perturb magnitudes
    %   fBValue           b-value for new magnitudes
    %   fMc               magnitude of completeness for new magnitudes
    %   fInc              magnitude increment for new magnitudes
    %
    % Output parameters:
    %   randCat     Randomized catalog
    %
    % Danijel Schorlemmer
    % April 29, 2002
    
    randCat = copy(mCatalog);
    if isnumeric(nMagnitudes)
        if nMagnitudes == 3
            nMagnitudes = 'perturb';
        else
            nMagnitudes = 'create';
        end
    end
    % Permute longitudes
    if bLon
        randCat.Longitude = randCat.Longitude(randperm(randCat.Count));
    end
    
    % Permute latitudes
    if bLat
        randCat.Latitude = randCat.Latitude(randperm(randCat.Count));
    end
    
    % Permute depths
    if bDepth
        randCat.Depth = randCat.Depth(randperm(randCat.Count));
    end
    
    % Permute times
    if bTimes
        randCat.Date = randCat.Date(randperm(randCat.Count));
    end
    
    if nMagnitudes == "perturb"  %perturb magnitudes
        randCat.Magnitude = randCat.Magnitude(randperm(randCat.Count));
    elseif nMagnitudes == "create" % create new magnitudes
        randCat.Magnitude= syn_create_magnitudes(randCat.Count, fBValue, fMc, fInc);
    end
end


