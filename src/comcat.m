function combined=comcat(cat1, cat2) 
    % combine two catalogs.
    % returned catalog is sorted by date
    
    if ~exist('cat2','var')
        cat2=my_loadcatalog('Second');
    end
        
    combined=cat(cat1,cat2);
    combined.sort('Date');
end


function outcat = my_loadcatalog(desc)            %% load first catalog
    outcat=ZmapCatalog();
    [file1,path1] = uigetfile( '*.mat',[desc, ' catalog in *.mat format']);
    if isempty(file1)
        warningdlg('Cancelled');
        return;
    end
    tmp=load(fullfile(path1,file1),'a'); % assume catalog in variable a
    assert(isfield('a','tmp'),'file does not contain expected variable name');
    if ~isa(tmp.primeCatalog,'ZmapBaseCatalog')
        outcat=ZmapCatalog(tmp.primeCatalog);
    else
        outcat=tmp.primeCatalog;
    end
end