function RateGrid = MakeRateGrid2(latmat,lonmat,RateMap)

%This program takes lat, lon, and rate matrices laid out in map view and
%rshapes them into RateGrid format: minlon, maxlon, minlat, maxlat, rate.


lat1 = latmat(1:end-1,1:end-1);
lat2 = latmat(2:end,2:end);

lon1 = lonmat(1:end-1,1:end-1);
lon2 = lonmat(2:end,2:end);

RateGrid(:,3) = reshape(lat1,size(lat1,1)*size(lat1,2),1);
RateGrid(:,4) = reshape(lat2,size(lat1,1)*size(lat1,2),1);
RateGrid(:,1) = reshape(lon1,size(lat1,1)*size(lat1,2),1);
RateGrid(:,2) = reshape(lon2,size(lat1,1)*size(lat1,2),1);

RateGrid(:,5) = reshape(RateMap,size(lat1,1)*size(lat1,2),1);
