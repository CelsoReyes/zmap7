

V = pi*(ra*1000*100)^2 * 15*1000*100;
dt = max(b(:,3)) - min(b(:,3));
c = sum( 10.^(1.5*b(:,6) + 16.1));
Msum = 2/3*( log10(c) - 16.1 );
strain = 1/(2*3*10^11*V*dt) * c;
def = strain*(2*ra*1000*100*10); % annual deformation in mm

