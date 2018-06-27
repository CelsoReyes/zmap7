function add_topo(varargin)
    % add topography to an axes
    % ADD_TOPO(AX) add world topography to axes, cropping based on current axes limits
    % ADD_TOPO(..., 'locale', choice) add specific topograph (or, if not found, world topography) to axes.
    %     current choices are: 'CH' (switzerland)
    % ADD_TOPO(..., 'colormap', COLORSCHEME) sets the colormap. Default is 'demcmap', a topographic
    % colormap. colorscheme may be any colormap, or [ Nx3] rgb value matrix
    %
    % see also demcmap
    
    p = inputParser();
    p.addOptional('ax',gca,@isgraphics);
    p.addParameter('locale','world');
    p.addParameter('colormap','demcmap');
    p.parse(varargin{:});
    
    ax=p.Results.ax;
    locale = p.Results.locale;
    colorscheme = p.Results.colormap;
    
    xl = ax.XLim;
    yl  =ax.YLim;
    switch locale
        case 'CH'
            tag='topographic_map_switzerland';
            delete(findobj(ax,'Tag',tag,'-and','Type','surface'));
            fname='DHM200.asc';
            if ~exist(fullfile('CH',fname),'file')
                CHSourceURL='https://opendata.swiss/en/dataset/das-digitale-hohenmodell-der-schweiz-mit-einer-maschenweite-von-200-m';
                error('Data for this topographic model cannot be found. Expected "%s" in folder dem/CH/\n\nPossibly downloadable from:\n%s',fname,CHSourceURL);
            end
            
            filename=fullfile('CH',fname); % expected to be in dem directory
            [Z,~] = arcgridread(filename);
            
            % limits picked manually out of accompanying metadata file
            LonLims=[5.867,10.921];
            LatLims=[45.803,47.866];
            lats=fliplr(linspace(LatLims(1),LatLims(2),size(Z,1)));
            lons=linspace(LonLims(1),LonLims(2),size(Z,2));
            
            lonidx = lons >=xl(1) & lons <= xl(2); 
            latidx = lats >=yl(1) & lats <= yl(2); 
            
            % expand the borders by 1 sample in each direction
            lonidx(find(diff(lonidx)==1))=true; 
            lastadd=find(diff(lonidx)==-1); 
            if ~isempty(lastadd)
                lonidx(lastadd+1)=true;
            end
            
            latidx(find(diff(latidx)==1))=true; 
            lastadd=find(diff(latidx)==-1);
            if ~isempty(lastadd)
                latidx(lastadd+1)=true; 
            end
            Z=Z(latidx,lonidx);
            
            %set(ax,'YDir','normal')
            ax.NextPlot = 'add';
            pc=pcolor(ax,lons(lonidx),lats(latidx),Z);
            pc.Tag=tag;
            pc.DisplayName='Swiss topography';
            ax.NextPlot = 'replace';
            shading (ax,'flat')
            ax.Children=circshift(ax.Children,-1); %this gets put at the bottom of the plot heirarchy
            % geoshow(topo,topoR,'DisplayType','texturemap')
            set_topo_colormap()
        otherwise
            tag='topographic_map_world';
            delete(findobj(ax,'Tag',tag,'-and','Type','surface'));
            fname='ETOPO1_Bed_c_geotiff.tif';
            if ~exist(fullfile('WORLD',fname),'file')
                WorldSourceURL='https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/cell_registered/georeferenced_tiff/';
                error('Data for this topographic model cannot be found. Expected "%s" in folder dem/WORLD/\nPossibly downloadable from:\n%s',fname,WorldSourceURL);
            end
            
            [Z,R]=geotiffread(fullfile('WORLD',fname));
            lons = linspace(R.XWorldLimits(1),R.XWorldLimits(2),R.RasterSize(2));
            lats = fliplr(linspace(R.YWorldLimits(1),R.YWorldLimits(2),R.RasterSize(1)));
            
            lonidx = lons >=xl(1) & lons <= xl(2); 
            latidx = lats >=yl(1) & lats <= yl(2); 
            
            % expand the borders by 1 sample in each direction
            lonidx(find(diff(lonidx)==1))=true; 
            lastadd=find(diff(lonidx)==-1); 
            if ~isempty(lastadd)
                lonidx(lastadd+1)=true;
            end
            latidx(find(diff(latidx)==1))=true; 
            lastadd=find(diff(latidx)==-1);
            if ~isempty(lastadd)
                latidx(lastadd+1)=true; 
            end
            Z=Z(latidx,lonidx);
            
            ax.NextPlot = 'add';
            pc=pcolor(ax,lons(lonidx), lats(latidx), Z);
            pc.Tag=tag;
            pc.DisplayName='world topography';
            
            ax.NextPlot = 'replace';
            shading (ax,'flat')
            % contourf(miniLon,fliplr(miniLat),miniA,20)
            ax.Children=circshift(ax.Children,-1); %this gets put at the bottom of the plot heirarchy
            set_topo_colormap()
    end
    pc.HitTest='off';
    
    function set_topo_colormap()
        if isequal(colorscheme,'demcmap')
            colorscheme=demcmap(Z);
        end
        colormap(ax, colorscheme);
    end
    
end