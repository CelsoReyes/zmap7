function [randomizedCatalog, okPressed] = syn_invoke_random_dialog(catalog)
    % permutes/generates a catalog based on interactive choices
    %
    %  [randCatalog, ok] = SYN_INVOKE_RANDOM_DIALOG(catalog) allows permutation of longitude,
    %  latitude, depth, dates, and magnitudes.  randCatalog contains the permutated catalog
    %
    %  if user cancels, then ok is false and no catalog is returend.
    
    randomizedCatalog=[];
    % Open figure
    
    zdlg = ZmapDialog();
    zdlg.AddHeader('Spatio-temporal permutations');
    zdlg.AddCheckbox('bTimes', 'Permute Times', false, [], 'tooltip');
    zdlg.AddCheckbox('bLon', 'Permute Longitudes', false, [], 'tooltip');
    zdlg.AddCheckbox('bLat', 'Permute Latitudes', false, [], 'tooltip');
    zdlg.AddCheckbox('bDepth', 'Permute Depths', false, [], 'tooltip');
    zdlg.AddHeader('Magnitude Options')
    zdlg.AddCheckbox('bMags', 'Permute Magnitudes', false, [], 'has no effect if new magnitudes are created');
    zdlg.AddCheckbox('createMags', 'Create New magnitudes', false, {'fBValue', 'fMc', 'fInc'}, 'tooltip');
    zdlg.AddEdit('fBValue', 'b-value', 1, 'tooltip');
    zdlg.AddEdit('fMc', 'Magnitude of completeness', 1, 'tooltip');
    zdlg.AddEdit('fInc', 'Bin spacing', 0.1, 'bins into which magnitudes will fall');
    
    passes = false;
    while ~passes
        [res, okPressed] = zdlg.Create('Name', 'Synthetic Catalog Choices');
        if ~okPressed
            return
        end
        passes = validate_choices(res);        
    end
    
    if res.createMags
        randomizedCatalog = syn_randomize_catalog(catalog, res.bLon, res.bLat,...
            res.bDepth, res.bTimes, 'create', res.fBValue, res.fMc, res.fInc);
    else
        randomizedCatalog = syn_randomize_catalog(catalog, res.bLon, res.bLat,...
            res.bDepth, res.bTimes, 'perturb');
    end
    msg.infodisp(randomizedCatalog, 'permutated catalog')
end

function ok = validate_choices(res)
    ttl = 'permuted catalog';
    ok = true;
    wasChanged = res.bLon || res.bMags || res.bLat || res.bTimes || res.bDepth || res.createMags;
    if ~wasChanged
        msgtxt = 'No changes were specified';
        ok = false;
    elseif res.createMags
        if res.fInc <= 0.1
            msgtxt = 'bin spacing must be greater than 0';
            ok = false;
        end

        if res.fInc <= 0
            msgtxt = 'b-value must be positive';
            ok = false;
        end
    end
    if ~ok
        msg.errordisp(msgtxt, ttl);
        mdlg = errordlg(msgtxt, ttl);
        waitfor(mdlg);
    end
end
