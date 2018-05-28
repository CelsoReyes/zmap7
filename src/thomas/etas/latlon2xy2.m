function xycoords = latlon2xy(latlon,centerpoint)

%This function will take coordinates given in latitude and longitude
%and convert them to and x,y coordinate system with x pointing east, y
%pointing north.

%The zero point will be set at the point given in centerpoint, where
%centerpoint is entered as [lat lon].



lat = latlon(:,1);
lon = latlon(:,2);



%Defining the y and x coordinates of each lat and lon

y = deg2km(lat - centerpoint(1));

x = deg2km(lon - centerpoint(2)).*cosd(lat);

%Outputting a vector with column1 = x coords, column2 = y coords

xycoords = [x(:) y(:)];



