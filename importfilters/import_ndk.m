function [result, ok] = import_ndk(nFunction, sFilename)
    % import NDK formatted catalog Global Centroid-Moment-Tensor (CMT) catalog,
    % formarly the Harvard CMT catalog
    %
    % see also NDK
    
    ok=false;
    if nFunction == 0
        % respond with brief summary of function, used in selection box
        result = 'Centroid-Moment-Tensor (CMT) Catalog, NDK file (formerly Harvard CMT catalog)';
    elseif nFunction == 2
        % respond with an html file that should help
        % website last accessed 18-July-2018
        result = 'https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_explained';
    else
        ndk = NDK.read(sFilename);
        result = ndk.toZmapCatalog();
        ok=true;
    end
end