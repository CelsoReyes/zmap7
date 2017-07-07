report_this_filefun(mfilename('fullpath'));

% Cumpute the radius based on M

rh = 10.^(1.33*newa(:,6) - 6); % this is in Km2 from the Geller, 1976....
rh = sqrt(rh/pi);

% now we plot them

figure
hold on

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
po = length(newa(1,:));

for i = 1:length(newa(:,5))
    col = [0.8 0.8 0.8];
    pl = patch(newa(i,po)+sin(x)*rh(i), -newa(i,7)+cos(x)*rh(i),col,'era','back');
    hold on
end
axis equal
axis tight
box on

