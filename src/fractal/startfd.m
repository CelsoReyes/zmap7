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

        range = [1];
        radm = [];
        rasm = [];
        fdparain;


    case 2	% Call from fdparain.m

        dtokm = [1];
        pdc3;


    case 3	% Call from timeplot.m
        %
        % Default values
        %
        numran = 1000;				% # of points in random catalog
        distr = [1];
        stdx = [0.5];
        stdy = [0.5];
        stdz = [1];
        long1 = min(a(:,1));
        long2 = max(a(:,1));
        lati1 = min(a(:,2));
        lati2 = max(a(:,2));
        dept1 = min(abs(a(:,7)));
        dept2 = max(abs(a(:,7)));

        E = a;
        randomcat;


    case 4	% Call from timeplot.m

        nev = [600];
        inc = [100];
        fdtimin;


    case 5  % Call from view_Dv.m

        range = [1];
        radm = [];
        rasm = [];
        crclparain;

end	%end swicth(org)


