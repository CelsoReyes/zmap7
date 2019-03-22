function [mRandomCatalog, okPressed] = syn_invoke_random_dialog(mCatalog)
    % permutes/generates a catalog based on interactive choices
    %
    %  [randCatalog, ok] = SYN_INVOKE_RANDOM_DIALOG(catalog) allows permutation of longitude,
    %  latitude, depth, dates, and magnitudes.  randCatalog contains the permutated catalog
    %
    %  if user cancels, then randCatalog is the incoming catalog, and ok is false
    %
    report_this_filefun();
    mRandomCatalog=[];
    % Open figure
    
    zdlg = ZmapDialog();
    choices = {'Leave magnitudes unchanged', 'Create new magnitudes', 'Permute magnitudes'};
    zdlg.AddPopup('permutation_option','Do This:',choices,1,'tooltip');
    zdlg.AddHeader('options for "create new magnitudes"')
    zdlg.AddEdit('fBValue', 'b-value', 1, 'tooltip');
    zdlg.AddEdit('fMc', 'Magnitude of completeness', 1, 'tooltip');
    zdlg.AddEdit('fInc', 'Increment', 0.1, 'bins into which magnitudes will fall');
    zdlg.AddHeader('Permute these fields');
    zdlg.AddCheckbox('bLon','Permute Longitudes',false,[],'tooltip');
    zdlg.AddCheckbox('bLat','Permute Latitudes',false,[],'tooltip');
    zdlg.AddCheckbox('bDepth','Permute Depths',false,[],'tooltip');
    zdlg.AddCheckbox('bTimes','Permute Times',false,[],'tooltip');
    [results, okPressed] = zdlg.Create('Name','Synthetic Catalog Choices');
    if ~okPressed
        return
    end
    switch results.permutation_option
        case 1
            disp('catalog is unchanged')
            mRandomCatalog =  copy(mCatalog);
        case 2
            mRandomCatalog = syn_randomize_catalog(mCatalog, results.bLon, results.bLat,...
                results.bDepth, results.bTimes, 'create', results.fBValue, results.fMc, results.fInc);
            
        case 3
            mRandomCatalog = syn_randomize_catalog(mCatalog, results.bLon, results.bLat,...
                results.bDepth, results.bTimes, 'perturb');
    end
    disp(mRandomCatalog)
end
