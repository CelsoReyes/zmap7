function [synCat] = syn_catalog(nEvents, fBValue, fMc, fInc, fMinLat, fMaxLat, fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime)
    % SYN_CATALOG Creates a synthetic catalog.
    % 
    % [mNewCatalog] = SYNCATALOG(nNumberEvents, fBValue, fMc, fInc, fMinLat, fMaxLat,
    %                                      fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime)
    % ------------------------------------------------------------------------------------------------
    %
    % Input parameters:
    %   nEvents     Number of events in the catalog
    %   fBValue           b-value of the catalog
    %   fMc               Magnitude of completeness of the catalog (= minimum magnitude)
    %   fInc              Magnitude increment (usually 0.1)
    %   fMinLat           Minimum latitude value of events in the catalog
    %   fMaxLat           Maximun latitude value of events in the catalog
    %   fMinLon           Minimum longitude value of events in the catalog
    %   fMaxLon           Maximun longitude value of events in the catalog
    %   fMinDepth         Minimum depth of events in the catalog (positive value)
    %   fMaxDepth         Maximun depth of events in the catalog (positive value)
    %   fMinTime          Minimum date/time of events in the catalog (decimal year: e.g. 1983.5)
    %   fMaxTime          Maximun date/time of events in the catalog (decimal year: e.g. 1987.9)
    %
    % Output parameters:
    %   synCat       Synthetic catalog
    %
    % Danijel Schorlemmer
    % April 17, 2002
    % Updates
    % Mai  9, 2007  van Stiphout, Thomas     replaced datevec.m by decyear2mat.m


    global bDebug
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end

    % Create empty catalog
    synCat = ZmapCatalog(nan(nEvents,10),'synthetic');

    % Create magnitudes
    [synCat] = syn_create_magnitudes(synCat, fBValue, fMc, fInc);

    % Randomize
    rng('shuffle');
    getRandomVals=@(minv,maxv) rand(nEvents,1) * (maxv - minv) + minv;
    % Create location
    synCat.Longitude =  getRandomVals(fMinLon,fMaxLon);
    synCat.Latitude = getRandomVals(fMinLat,fMaxLat);
    synCat.Depth = getRandomVals(fMinDepth, mFaxDepth);

    % Create focal times
    synCat.Date = dateshift(getRandomVals(fMinTime, fMaxTime),'start','minute');


