function add_topo(varargin)
    % add topography to an axes
    % ADD_TOPO(AX) add world topography to axes, cropping based on current axes limits
    % ADD_TOPO(..., 'locale', choice) add specific topograph (or, if not found, world topography) to axes.
    %     current choices are: 'CH' (switzerland)
    % ADD_TOPO(..., 'colormap', COLORSCHEME) sets the colormap. Default is 'demcmap', a topographic
    % colormap. colorscheme may be any colormap, or [ Nx3] rgb value matrix
    %
    % see also demcmap
    
    RootFolder = 'dem';
    
    % create a MAP that contains all the necessary detail for each region of interest
    
    DEM_Details = containers.Map;
    
    %% define all the details for the swiss DEM
    s.Name          = 'Switzerland';
    s.SourceUrl     = 'https://opendata.swiss/en/dataset/das-digitale-hohenmodell-der-schweiz-mit-einer-maschenweite-von-200-m';
    s.DataUrl       = 'http://data.geo.admin.ch/ch.swisstopo.digitales-hoehenmodell_25/data.zip';
    s.LastChecked   = datetime(2018,11,21);
    s.Tag           = 'topographic_map_switzerland';
    s.FileName      = 'DHM200.asc';
    s.DisplayName   = 'Swiss topography';
    s.PutIntoCorrectFolder  = @move_to_correct_folder_CH;
    s.ZipFileName   = 'chdata.zip';
    s.Locale        = 'CH';
       
    DEM_Details(s.Locale) = s;
    
    
    s(:)=[]; % start on next detail
    
    %% define all the details for the world DEM
    s(1).Name       = 'World';
    s.SourceUrl     = 'https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/cell_registered/georeferenced_tiff/';
    s.DataUrl       = 'https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/cell_registered/georeferenced_tiff/ETOPO1_Bed_c_geotiff.zip';
    s.LastChecked   = datetime(2018,11,21);
    s.Tag           = 'topographic_map_world';
    s.FileName      = 'ETOPO1_Bed_c_geotiff.tif';
    s.DisplayName   = 'world topography';
    s.PutIntoCorrectFolder  = @move_to_correct_folder_WORLD;
    s.ZipFileName   = 'worlddata.zip';
    s.Locale        = 'WORLD';
    
    DEM_Details(s.Locale) = s;
    
    %%
    % - - - - - - - - - -
    
    p = inputParser();
    p.addOptional('ax'          , gca,@isgraphics);
    p.addParameter('locale'     , 'world');
    p.addParameter('colormap'   , 'demcmap');
    p.addParameter('ShadedOnly' , false);
    p.parse(varargin{:});
    
    ax          = p.Results.ax;
    locale      = p.Results.locale;
    colorscheme = p.Results.colormap;
    
    if p.Results.ShadedOnly
        colorscheme = [0.5 0.5 0.5];
    end
        
    deets = DEM_Details(upper(locale));
    
    delete(findobj(ax,'Tag',deets.Tag,'-and','Type','surface'));
    watchon
    my_dem_file = fullfile(RootFolder, deets.Locale, deets.FileName);
    
    if ~exist(my_dem_file, 'file')
        try_to_aquire_file(deets, RootFolder);
    end
    
    watchoff
    
    if ~exist(my_dem_file, 'file')
        error(['Data for this topographic model cannot be found or downloaded. ', ...
            'Expected "%s" in folder dem/%s/\n', ...
            '\nPossibly downloadable from:\n%s'], ...
            deets.FileName, deets.Locale, Deets.SourceUrl);
    end
    
            
    switch deets.Locale
        case 'CH'
            
            [Z,~] = arcgridread(my_dem_file);
            
            % limits picked manually out of accompanying metadata file
            LonLims=[5.867,10.921];
            LatLims=[45.803,47.866];
            lats=fliplr(linspace(LatLims(1), LatLims(2), size(Z,1)));
            lons=linspace(LonLims(1), LonLims(2), size(Z,2));
            
            
        case 'WORLD'
                        
            [Z,R] = geotiffread(my_dem_file);
            
            lons = linspace(R.XWorldLimits(1), R.XWorldLimits(2), R.RasterSize(2));
            lats = fliplr(linspace(R.YWorldLimits(1), R.YWorldLimits(2), R.RasterSize(1)));
            
        otherwise
            
            error('Unknown locale');
            
    end
    
    plot_the_colormap(ax, deets, lats, lons, Z, colorscheme);
    watchoff
    
end

function set_topo_colormap(ax, colorscheme, Z)
    if isequal(colorscheme, 'demcmap')
        colorscheme=demcmap(Z);
    end
    colormap(ax, colorscheme);
end

function x = expand_border(x)
    % expand the borders by 1 sample in each direction
    x(find(diff(x)==1))=true;
    lastadd=find(diff(x)==-1);
    if ~isempty(lastadd)
        x(lastadd+1)=true;
    end
end

function download_if_necessary(deets, zfn)
    if ~exist(zfn,'file')...
            && questdlg([deets.DisplayName, ' does not exist, attempt to download?'],'Download')=="Yes"
        msg.dbdisp('downloading...')
        websave(zfn, deets.DataUrl);
    end
    if ~exist(zfn,'file')
        error(['Data for this topographic model cannot be found. ', ...
            'Expected "%s" in folder dem/%s/\n', ...
            '\nPossibly downloadable from:\n%s'], ...
            deets.FileName, deets.Locale, Deets.SourceUrl);
    end
end

function move_to_correct_folder_CH(deets, zfn, folder_name)
    msg.dbdisp('unzipping')
    unzip(zfn, fullfile(folder_name));
    from_folder = fullfile(folder_name,'data');
    to_folder = fullfile(folder_name, deets.Locale);
    msg.dbdisp('moving');
    movefile(from_folder, to_folder);
end

function move_to_correct_folder_WORLD(deets, zfn, folder_name)
    f=watchon
    drawnow
    msg.dbdisp('unzipping')
    unzip(zfn, fullfile(folder_name, deets.Locale));
    watchoff(f)
end

function delete_downloaded_file(deets, downloaded_file_name)
    if questdlg("Delete temporary zip file ["+ downloaded_file_name + "] containing "+ deets.Locale +" topography?",'Delete zip')=="Yes"
        delete(downloaded_file_name)
    end
end

function  try_to_aquire_file(deets, RootFolder)
    folder_name = fullfile(ZmapGlobal.Data.hodi, RootFolder);
    try
        zfn=fullfile(folder_name, deets.ZipFileName);
        download_if_necessary(deets, zfn); % will throw if aborted or not successful
        deets.PutIntoCorrectFolder(deets, zfn, folder_name);
        delete_downloaded_file(deets, zfn);
        
    catch
        watchoff
        error('Data for this topographic model cannot be found. Expected "%s" in folder dem/%s/\n\nPossibly downloadable from:\n%s',deets.FileName, deets.Locale, Deets.SourceUrl);
    end
end

function plot_the_colormap(ax, deets, lats, lons, Z, colorscheme)
    xl = ax.XLim;
    yl  =ax.YLim;
    
    lonidx = lons >=xl(1) & lons <= xl(2);
    latidx = lats >=yl(1) & lats <= yl(2);
    
    lonidx = expand_border(lonidx);  % expand the borders by 1 sample in each direction
    latidx = expand_border(latidx);
    
    Z = Z(latidx,lonidx);
    
    %set(ax,'YDir','normal')
    ax.NextPlot = 'add';
    
    pc = pcolor(ax,lons(lonidx),lats(latidx),Z);
    pc.Tag          = deets.Tag;
    pc.DisplayName  = deets.DisplayName;
    pc.HitTest      = 'off';
    
    ax.NextPlot = 'replace';
    shading (ax,'flat')
    ax.Children = circshift(ax.Children,-1); %this gets put at the bottom of the plot heirarchy
    % geoshow(topo,topoR,'DisplayType','texturemap')
    set_topo_colormap(ax, colorscheme, Z)
end