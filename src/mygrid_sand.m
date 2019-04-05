function  [image_data,lats,lons] = mygrid_sand(region, varargin)
    % MYGRID_SAND  Read bathymetry data from Sandwell Database
    %      [image_data,vlat,vlon] = mygrid_sand(region)
    %      ... = mygrid_sand(__, 'Decimation', n) decimates by extracting every nth point
    %      ... = mygrid_sand(__, 'AsMesh', n) returns a mesh for lats and lons instead of a vector.
    %
    % program to get bathymetry from topo_8.2.img  If earlier version is used, then rename to 
    % topo_8.2.img.
    %
    % latitudes must be between -72.006 and 72.006;
    %       input:
    %               region =[south north west east];
    %       output:
    %               image_data - matrix of sandwell bathymetry/topography
    %               lats - vector ( or matrix) of latitudes associated with image_data
    %               lons - vector (or matrix) of longitudes
    %
    %  see also satbath
           
    p = inputParser();
    p.addParameter('Decimation',1);
    p.addParameter('AsMesh', false);
    p.parse(varargin{:});
    
    [lats, lons, image_data] = satbath(p.Result.Decimation, region(1:2), region(3:4));
    if ~p.Result.AsMesh
        % keep only vector rows
        lats = lats(:,1);
        lons = lons(1,:);
    end
end
