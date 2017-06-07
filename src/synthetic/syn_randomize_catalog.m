function [mRandomCatalog] = syn_randomize_catalog(mCatalog, bLon, bLat, bDepth, bTimes, nMagnitudes, fBValue, fMc, fInc)
    % function [mRandomCatalog] = syn_randomize_catalog(mCatalog, bLon, bLat, bDepth,
    %                                                   bTimes, nMagnitudes, fBValue, fMc, fInc)
    % ------------------------------------------------------------------------------------------
    % Randomizes a given catalog.
    %
    % Input parameters:
    %   mCatalog          Catalog for randomizing
    %   bLon              Perturb longitudes (=1) or leave longitudes unchanged (=0)
    %   bLat              Perturb latitudes (=1) or leave latitudes unchanged (=0)
    %   bDepth            Perturb depths (=1) or leave depths unchanged (=0)
    %   bTimes            Perturb focal times (=1) or leave focal times unchanged (=0)
    %   nMagnitudes       Magnitude switch
    %                     1: Leave magnitudes unchanged
    %                     2: Generate new magnitudes according to parameters fBValue, fMc, fInc
    %                     3: Perturb magnitudes
    %   fBValue           b-value for new magnitudes
    %   fMc               magnitude of completeness for new magnitudes
    %   fInc              magnitude increment for new magnitudes
    %
    % Output parameters:
    %   mRandomCatalog     Randomized catalog
    %
    % Danijel Schorlemmer
    % April 29, 2002

    global bDebug
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end

    mRandomCatalog = mCatalog;

    % Permute longitudes
    if bLon
        mRandomCatalog(:,1) = mRandomCatalog(randperm(length(mRandomCatalog)), 1);
    end

    % Permute latitudes
    if bLat
        mRandomCatalog(:,2) = mRandomCatalog(randperm(length(mRandomCatalog)), 2);
    end

    % Permute depths
    if bDepth
        mRandomCatalog(:,7) = mRandomCatalog(randperm(length(mRandomCatalog)), 7);
    end

    % Permute times
    % Get free column
    nNumberColumns = size(mRandomCatalog, 2);
    % Create the single-value date
    mRandomCatalog(:,(nNumberColumns + 1)) = datenum(floor(mRandomCatalog(:,3)), mRandomCatalog(:,4), mRandomCatalog(:,5), mRandomCatalog(:,8), mRandomCatalog(:,9), 0);
    % Permute these dates
    mRandomCatalog(:,(nNumberColumns + 1)) = mRandomCatalog(randperm(length(mRandomCatalog)), (nNumberColumns + 1));
    % Reassign them to the existing fields
    [mRandomCatalog(:,3) mRandomCatalog(:,4) mRandomCatalog(:,5) mRandomCatalog(:,8) mRandomCatalog(:,9)] = datevec(mRandomCatalog(:,(nNumberColumns + 1)));
    [mRandomCatalog(:,3)] = decyear([mRandomCatalog(:,3) mRandomCatalog(:,4) mRandomCatalog(:,5) mRandomCatalog(:,8) mRandomCatalog(:,9)]);
    % Delete the new column
    mRandomCatalog = mRandomCatalog(:,1:nNumberColumns);

    % What's up with the magnitudes?
    if nMagnitudes == 3
        mRandomCatalog(:,6) = mRandomCatalog(randperm(length(mRandomCatalog)), 6);
    elseif nMagnitudes == 2
        [mRandomCatalog] = syn_create_magnitudes(mRandomCatalog, fBValue, fMc, fInc);
    end


