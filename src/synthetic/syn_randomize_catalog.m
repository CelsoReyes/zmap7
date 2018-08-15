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
    
    report_this_filefun();
    
    if isnumeric(mCatalog)
        %% do the old thing
        randCat = mCatalog;
        
        % Permute longitudes
        if bLon
            randCat(:,1) = randCat(randperm(length(randCat)), 1);
        end
        
        % Permute latitudes
        if bLat
            randCat(:,2) = randCat(randperm(length(randCat)), 2);
        end
        
        % Permute depths
        if bDepth
            randCat(:,7) = randCat(randperm(length(randCat)), 7);
        end
        
        % Permute times
        % Get free column
        nNumberColumns = size(randCat, 2);
        % Create the single-value date
        randCat(:,(nNumberColumns + 1)) = datenum(floor(randCat(:,3)), randCat(:,4), randCat(:,5), randCat(:,8), randCat(:,9), 0);
        % Permute these dates
        randCat(:,(nNumberColumns + 1)) = randCat(randperm(length(randCat)), (nNumberColumns + 1));
        % Reassign them to the existing fields
        [randCat(:,3) randCat(:,4) randCat(:,5) randCat(:,8) randCat(:,9)] = datevec(randCat(:,(nNumberColumns + 1)));
        [randCat(:,3)] = decyear([randCat(:,3) randCat(:,4) randCat(:,5) randCat(:,8) randCat(:,9)]);
        % Delete the new column
        randCat = randCat(:,1:nNumberColumns);
        
        % What's up with the magnitudes?
        if nMagnitudes == 3
            randCat(:,6) = randCat(randperm(length(randCat)), 6);
        elseif nMagnitudes == 2
            [randCat] = syn_create_magnitudes(randCat, fBValue, fMc, fInc);
        end
    else
        %% do the new thing
        randCat = mCatalog;
        
        % Permute longitudes
        if bLon
            randCat=copy(mCatalog);
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
        
        randCat.Date = randCat.Date(randperm(randCat.Count));
        
        
        % What's up with the magnitudes?
        if nMagnitudes == 3
            randCat.Magnitude = randCat.Magnitude(randperm(randCat.Count));
        elseif nMagnitudes == 2
            [randCat] = syn_create_magnitudes(randCat, fBValue, fMc, fInc);
        end
    end
    
    
