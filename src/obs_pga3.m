report_this_filefun(mfilename('fullpath'));

b = a;

% Hier vielleicht dx, dy aendern ...
ve = [];dx = 0.1; dy = 0.1;

x0 = min(a(:,1));
x1 = max(a(:,1));
y0 = min(a(:,2));
y1 = max(a(:,2));


for x = x0:dx:x1
    for y = y0:dy:y1
        ve =    [ ve ; x y ];
    end
end

le = length(ve);
Y0 = zeros(le,1);

% Hier muss die richtige abminderung rein ...
for i = 1:length(b)
    di2 = deg2km((distance(ve(:,2),ve(:,1),repmat(b(i,2),le,1),repmat(b(i,1),le,1))));
    R = di2;
    r = sqrt(R.^2 + 5.57^2);
    M = b(i,6); % wenn mit felhler: + dM  (random mit standart)
    Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;
    Y = 10.^Y;
    c = [Y , Y0];
    mapga = max(c');
    Y0 = mapga';
end

mapga = mapga';


l1 = length(x0:dx:x1);
l2 = length(y0:dy:y1);


re = reshape(mapga,l2,l1);
rey = reshape(ve(:,2),l2,l1);
rex = reshape(ve(:,1),l2,l1);

figure
pcolor(rex,rey,re)
hold on
shading interp
overlay
colorbar
