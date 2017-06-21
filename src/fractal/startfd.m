%
% This is the starting code for the fractal dimension, which organizes
% the different codes with each other.
% Francesco Pacchiani 1/2000
%
%
% disp('fractal/codes/startfd.m');
%
%
switch (org)

    case 1 	% Call from timeplot.m, fdsphere.m, dorand.m

        range = 1;
        radm = [];
        rasm = [];
        fdparain;


    case 2	% Call from fdparain.m

        dtokm = 1;
        pdc3;


    case 3	% Call from timeplot.m
        %
        % Default values
        %
        numran = 1000;				% # of points in random catalog
        distr = 1;
        stdx = 0.5;
        stdy = 0.5;
        stdz = 1;
        long1 = min(a.Longitude);
        long2 = max(a.Longitude);
        lati1 = min(a.Latitude);
        lati2 = max(a.Latitude);
        dept1 = min(abs(a.Depth));
        dept2 = max(abs(a.Depth));

        E = a;
        randomcat;


    case 4	% Call from timeplot.m

        nev = 600;
        inc = 100;
        fdtimin;


    case 5  % Call from view_Dv.m

        range = 1;
        radm = [];
        rasm = [];
        crclparain;

end	%end switch(org)


