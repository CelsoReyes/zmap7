function s = import_ndk(nFunction, sFilename)
    % import NDK formatted catalog Global Centroid-Moment-Tensor (CMT) catalog,
    % formarly the Harvard CMT catalog
    %
    % see also NDK
    
    if nFunction == 0
        % respond with brief summary of function, used in selection box
        s = 'Centroid-Moment-Tensor (CMT) Catalog, NDK file (formerly Harvard CMT catalog)';
    elseif nFunction == 2
        % respond with an html file that should help
        % website last accessed 18-July-2018
        s = 'https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_explained';
    else
        ndk = NDK.read(sFilename);
        s = ndk.toZmapCatalog();
    end
end