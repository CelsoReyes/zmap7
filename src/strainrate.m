

V = (max(newt2(:,2)) - min(newt2(:,2))) * (max(newt2(:,1)) - min(newt2(:,1))) * 111*111 *1000*1000 *100 *100*30*1000*100;
dt = max(newt2(:,3)) - min(newt2(:,3));
c = sum( 10.^(1.5*newt2(:,6) + 16.1));
Msum = 2/3*( log10(c) - 16.1 )
strain = 1/(2*3*10^11*V*dt) * c
% annual deformation in mm
def = strain*(max(newt2(:,2)) - min(newt2(:,2)))*111*1000*100*10


%bdiff2
plotfmdsA1A2
c = 0; RE = [];
dt = 1;
for m = 2:0.1:9
    N = 10^(aw-bw*m);
    c = c + N*( 10.^(1.5*m + 16.1));
    Msum = 2/3*( log10(c) - 16.1 );
    strain = 1/(2*3*10^11*V*dt) * c;
    def = strain*(max(newt2(:,2)) - min(newt2(:,2)))*111*1000*100*10;
    RE = [RE ; m Msum strain def];
end

figure
pl = plot(RE(:,1),RE(:,4),'sk');
set(gca,'Yscale','log')
set(pl,'markerfacecolor','b');
xlabel('Mw')
ylabel('annual deformation (mm)');



