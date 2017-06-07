%
% This code creates the plot of the D-value versus the radius of the sampling sphere.
% The code is called from view_Dv.
% Francesco Pacchiani 3/2000
%
%
figure_w_normalized_uicontrolunits('Numbertitle','off','Name','D versus Resolution');
plot(bvg(:,4),bvg(:,1),'ko', 'Markersize', 10);
hold on;
xlabel('Radius of the sampling sphere', 'fontsize',12);
ylabel('D-value', 'fontsize',12);
title('D-value versus Radius of the Sampling Sphere', 'fontsize',14);
set(gca, 'fontsize',10);
