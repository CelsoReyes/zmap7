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
    % Danijel Schorlemmer, Thomas van Stiphout, Celso Reyes
    % 2002, 2007, 2019
    
    % If other options for catalog creation are requested, then create_synthetic_catalog subfunction
    % (below) can be activated and wired up.  Default behavior is "homogenous"
    
    report_this_filefun();
    
    tb = table;
    
    rng('shuffle');
    getRandomVals = @(minv,maxv) rand(nEvents,1) * (maxv - minv) + minv;
    
    tb.Date = dateshift(getRandomVals(fMinTime, fMaxTime),'start','minute');
    tb.Magnitude = syn_create_magnitudes(nEvents, fBValue, fMc, fInc);
    tb.Longitude = getRandomVals(fMinLon, fMaxLon);
    tb.Latitude  = getRandomVals(fMinLat, fMaxLat);
    tb.Depth     = getRandomVals(fMinDepth, fMaxDepth);
    
    synCat = ZmapCatalog.fromTable(tb);
    synCat.Name = 'synthetic';
    synCat.sort('Date','ascend');
    return
    
    %% code salvaged from thomas/synthetic/syn_catalog
    
    function synCat = create_synthetic_catalog(synMode)
        % allowing some choices in the catalog creation method
        % nSynMode          Type of synthetic catalog 0:homogeneous distr; 1:based
        % on real catalog 2:hypocenter based on real catalog, magnitude and focal
        % time is randomly computed
        % mCatalog          declustered catalog needed only for nSynMode=1
        %
        % Output parameters:
        %   mNewCatalog       Synthetic catalog
        %
        % Danijel Schorlemmer
        % April 17, 2002
        % Updates
        % Mai  9, 2007  van Stiphout, Thomas     replaced datevec.m by decyear2mat.m
        
        if isnumeric(synMode)
            switch synMode
                case 0
                    synMode = "homogeneous"; % homogenous distribution
                case 1
                    synMode = "catalog-based"; % based on real catalog"
                case 2
                    synMode = "hypocenter-based"; % magnitude and focal time is randomly computed.
            end
        end
        
        rng('shuffle');
        getRandomVals = @(minv,maxv) rand(nEvents,1) * (maxv - minv) + minv;
        
        tb = table;
                
        switch synMode
            case "homogeneous"
                tb.Date = dateshift(getRandomVals(fMinTime, fMaxTime),'start','minute');
                tb.Magnitude = syn_create_magnitudes(nEvents, fBValue, fMc, fInc);
                tb.Longitude = getRandomVals(fMinLon,fMaxLon);
                tb.Latitude  = getRandomVals(fMinLat,fMaxLat);
                tb.Depth     = getRandomVals(fMinDepth, fMaxDepth);
                
                
            case"catalog-based"
                % take from real catalog hypocenters and magnitudes  ....
                dates = dateshift(getRandomVals(fMinTime, fMaxTime),'start','minute');
                [tb.Date, idx] = sort(dates);
                tb.Magnitude = mCatalog.Magnitude(idx);
                tb.Longitude = mCatalog.Longitude(idx);
                tb.Latitude = mCatalog.Latitude(idx);
                tb.Depth = mCatalog.Depth(idx);
                
            case "hypocenter-based"
                
                hypoShift = 5; % initial shift of hypocenter from reference eevent.
                dates = dateshift(getRandomVals(fMinTime, fMaxTime),'start','minute');
                [tb.Date, idx] = sort(dates);
                tb.Magnitude = syn_create_magnitudes(nEvents, fBValue, fMc, fInc);
                
                vTmp = km2deg(rand(nNumberEvents,2).* hypoShift - hypoShift/2);
                
                tb.Longitude = mCatalog.Longitude(idx)+vTmp;
                tb.Latitude = mCatalog.Latitude(idx)+vTmp;
                tb.Depth = mCatalog.Depth(idx);
                
            otherwise
                error('unknown synthetic catalog creation mode, should be one of "homogenous", "catalog-based", "hypocenter-based"')
        end
        
        synCat = ZmapCatalog.fromTable(tb);
        synCat.Name = 'synthetic';
    end
end
