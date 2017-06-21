% plot using mapping toolbox from shapefile
% download the shapefile from http://www.gadm.org (recommende is the one with 6 dissolved layers
%S=shaperead('/Users/reyesc/Downloads/gadm28_levels/gadm28_adm1.shp','UseGeoCoords',true); %1st administrative level
S=shaperead('/Users/reyesc/Downloads/gadm28_levels/gadm28_adm0.shp','UseGeoCoords',true); %country administrative level
figure
axesm lambert
framem
plotm([S.Lat],[S.Lon]);

%plot(ax,[S.Lon],[S.Lat],'color',[.5 .5 .5],'Tag','borders')