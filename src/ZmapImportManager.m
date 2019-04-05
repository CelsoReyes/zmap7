function [ok,catalog] = ZmapImportManager(fun, funArguments, varargin)
    % ZMAPIMPORTMANAGER - handles the import of zmap catalogs.
    %
    % OK = ZMAPIMPORTMANAGER( FUN ) provide the import function as a parameter. Catalog will replace
    % the primary catalog in ZmapGlobal.Data.  OK indicates whether a catalog was successfully
    % loaded
    %
    % [OK, CATALOG] = ZMAPIMPORTMANAGER( FUN ) return the catalog as output INSTEAD of updating the
    % primary catalog.
    %
    % ZMAPIMPORTMANAGER( FUN , ARGS ) ARGS is a cell of arguments that will be 
    % passed to the import function FUN
    %
    % The ZMAPIMPORTMANAGER exists to do cleanup and shutdown as necessary of other catalogs in
    % memory. this includes the creation of maps and timeplots.
    %
    % catalogs imported throught he ZmapImportManager will be sorted in ascending Date order
    
    % yes, the argument fun expects the return arguments in reverse order from the ZmapImportManager
    % this is purely practical.
    assert(nargout(fun)==2,'import function must have two output arguments : [catalog, ok]');
    if exist('funArguments','var')
        assert(iscell(funArguments),...
            'Second argument should be a CELL containing arguments to be passed to fun');
        [catalog,ok] = fun(funArguments{:});
    else
        [catalog,ok] = fun();
    end
    if ok
        sort(catalog,'Date','ascend')
    end
    
    returnTheCatalog = nargout==2;
    if returnTheCatalog
        % do not assume we are modifying the primary catalog. This might be some other load
        if ~ok
            catalog = ZmapCatalog();
        end
    else
        % assume we replace the primary catalog
        if ok
            post_load();
        end
    end
    
    % save this catalog
    saveFile = fullfile(ZmapGlobal.Data.Directories.working, ZmapGlobal.Data.CatalogOpts.LastCatalogFilename);
    [pathstr,name,ext] = fileparts(saveFile);
    if isempty(ext)
        ext='.mat';
    end
    saveFile=fullfile(pathstr,[name ext]);
    if ~exist(pathstr,'dir')
        mkdir(pathstr);
    end
    try
        save(saveFile, 'catalog');
    catch ME
        warning('ZMAP:unableToSaveCatalog','unable to save the catalog');
        warning(ME.message);
    end
    
    function post_load()
        disp('post load')
        ZG = ZmapGlobal.Data;
        ZG.primeCatalog = catalog; % since a catalog is a handle, they point to same thing
        
        % ZG.mainmap_plotby='depth';
        
        setDefaultValues(catalog);
        ZG.maepi=catalog.subset(catalog.Magnitude > ZG.CatalogOpts.BigEvents.MinMag);
        
        % OPTIONALLY CLEAR SHAPE
        if ~isempty(ShapeGeneral.ShapeStash)
            % ask whether to keep shape
            switch questdlg('Keep current shape?','SHAPE','yes','no','no')
                case 'no'
                    ShapeGenreal.ShapeStash(ShapeGeneral)
                case 'yes'
                    % do nothing
            end
        end
        
        % OPTIONALLY CLEAR GRID
        if ~isempty(ZG.Grid)
            switch questdlg('Keep curent grid?','GRID','yes','no','no')
                case 'no'
                    ZG.Grid.delete()
                case 'yes'
                    % do nothing
            end
        end
        
        uimemorize_catalog();
        
    end
    
end

function setDefaultValues(A)
    % SETDEFAULTVALUES sets certain Zmap Global values based on catalog.
    ZG=ZmapGlobal.Data; % get zmap globals
    
    %  default values
    [t0b, teb] = bounds(A.Date) ;
    ttdif = days(teb - t0b);
    if ~exist('bin_dur','var')
        ZG.bin_dur = days(ceil(ttdif/100));
    elseif ttdif<=10  &&  ttdif>1
        ZG.bin_dur = days(0.1);
    elseif ttdif<=1
        ZG.bin_dur = days(0.01);
    end
    ZG.CatalogOpts.BigEvents.MinMag = max(A.Magnitude) -0.2;
end