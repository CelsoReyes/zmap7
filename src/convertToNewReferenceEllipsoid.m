function [lat, lon,depth] = convertToNewReferenceEllipsoid(lat,lon, varargin)
    % CONVERTTONEWREFERENCEELLIPSOID transforms lat/lon/depth coordinates from one datum to another
    % [lat, lon] = convertToNewReferenceEllipsoid(lat, lon, srcEllipsoid, targEllipsoid)
    % [lat,lon,depth] = convertToNewReferenceEllipsoid(lat, lon, depth, srcllipsoid, targEllipsoid)
    %
    % Ellipsoids can be a name, such as 'nad27', or can be any reference ellipsoid.
    %
    % example 1:
    %
    %    [la, lo] = convertToNewReferenceEllipsoid(la, lo, 'airy1849', 'wgs84');
    %
    % example 2: using a defined ellipsoid
    %
    %    src = referenceEllipsoid('grs80','kilometer');
    %    targ = referenceEllipsoid('international','kilometer');
    %    [la, lo] = convertToNewReferenceEllipsoid(la, lo, src, targ);
    %
    %
    % see also ecef2geodetic, geodetic2ecef, referenceEllipsoid
    
    assert(isequal(size(lat) , size(lon)));
    if numel(varargin) == 3
        % depth was provided
        depth = varargin{1};
        assert(isequal(size(lat),size(depth)));
        sourceEllipsoid = varargin{2};
        targetEllipsoid = varargin{3};
        
    elseif numel(varargin)==2
        depth=zeros(size(lat));
        sourceEllipsoid = varargin{1};
        targetEllipsoid = varargin{2};
    else
        error('Incorrect number of input arguments.\n\n%s',help('convertToNewReferenceEllipsoid'));
    end
    if ischar(sourceEllipsoid)||isstring(sourceEllipsoid)
        sourceEllipsoid = referenceEllipsoid(sourceEllipsoid,'kilometers');
    end
    if ischar(targetEllipsoid)||isstring(targetEllipsoid)
        targetEllipsoid = referenceEllipsoid(targetEllipsoid,'kilometers');
    end
    
    [x,y,z]=geodetic2ecef(sourceEllipsoid,lat,lon,-depth);
    [lat,lon,depth]=ecef2geodetic(targetEllipsoid,x,y,z);
end
    
    