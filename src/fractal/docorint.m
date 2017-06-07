% This code calculates the fractal dimension of a given earthquake dataset
% using as input the pair distances calculated with the pairdist.m code.
%
%
%disp('fractal/codes/docorint.m');
%
% Variables
%
rmax = max(pairdist);
rmin = min(pairdist);

if rmin == 0
    rmin = 0.01;
end

lrmin = log10(rmin);
lrmax = log10(max(pairdist));

%u = (log10(rmin):0.15:log10(rmax))';
%
% Recalculation of the interevent distance vector r in order that on the
% log-log graph all the points plot at equal distances from one another.
%
r = (logspace(lrmin, lrmax, 50))';
%r = zeros(size(u,1),1);
%r = 10.^u;
%
% Calculation of the correlation integral.
%
close(msg2);
Ho_Wb = waitbar(0,'Calculating the correlation integral');


corint = [];						% corint= Vector of ?cumulative? correlation integral values for increasing interevent radius
corint = zeros(size(r,1),1);
k = 1;

for i = 1:size(r,1)

    j = [];
    j = pairdist < r(i);
    corint (k,1) = (2/(N*(N-1)))*sum(j);
    k = k + 1;
    waitbar((1/size(r,1))*i,Ho_Wb);

end

clear i j k;
close(Ho_Wb);
Hf_child = get(groot,'children');
set(Hf_child,'pointer','arrow');
%
% Plotting of the correlation integral in function of the interevent
% distance r.
%
Hf_Fig = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Fractal Dimension');
Hl_gr1 = loglog(r, corint,'r+');
set(Hl_gr1,'MarkerSize',7);
%
% compute D
%
dofd = 'fd';
dofdim;
