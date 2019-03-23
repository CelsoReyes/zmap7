function [synthCat, ok] = syn_invoke_dialog(catalog)
% SYN_INVOKE_DIALOG interactive creation of a synthetic catalog
%
% [newCat, ok] = syn_invoke_dialog(catalog) uses an existing dialog to create default values

    synthCat = [];
    if nargin==0
        catalog = struct();
        catalog.Count = 10000;
        catalog.Date = [datetime(1980,1,1) datetime(1990,1,1)];
        catalog.Longitude = [-118 -116];
        catalog.Latitude = [30 35];
        catalog.Depth = [0 25];
    end
    zdlg = ZmapDialog();
    zdlg.AddHeader('Create a Synthetic Catalog');
    zdlg.AddEdit('nEvents', 'Number of events', catalog.Count, 'number of events in complete catalog');
    zdlg.AddHeader('Temporal Properties');
    zdlg.AddEdit('minTime','Earliest possible date', min(catalog.Date), 'First possibledate in catalog');
    zdlg.AddEdit('maxTime','Latest possible date', max(catalog.Date), 'Last possible date in catalog');
    zdlg.AddHeader('Positional Properties');
    zdlg.AddNumericRange('Lons','Longitude Bounds (deg)', bounds2(catalog.Longitude),[-180 180],'[]', 'Longitudes');
    zdlg.AddNumericRange('Lats','Latitude Bounds (deg)', bounds2(catalog.Latitude),[-90 90],'[]', 'Latitudes');
    zdlg.AddNumericRange('Depths','Depth Bounds (km)', bounds2(catalog.Depth),[-6 6000],'[]', 'Depth');
    zdlg.AddHeader('Magnitude Properties');
    zdlg.AddEdit('fBValue', 'b-value', 1, 'tooltip');
    zdlg.AddEdit('fMc', 'Magnitude of completeness', 1, 'tooltip');
    zdlg.AddEdit('fInc', 'Bin spacing', 0.1, 'bins into which magnitudes will fall');

    [res, ok] = zdlg.Create('Name', 'Create a synthetic catalog');
    if ~ok
        return
    end
    
    synthCat = syn_catalog(res.nEvents, res.fBValue, res.fMc, res.fInc, ...
        res.Lats(1), res.Lats(2), res.Lons(1), res.Lons(2), res.Depths(1), res.Depths(2),...
        res.minTime, res.maxTime);
    
    return
end