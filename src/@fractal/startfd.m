function obj = startfd(obj)
    % This is the starting code for the fractal dimension, which manages the different codes.
    % Francesco Pacchiani 1/2000
    %
    %
    % disp('fractal/codes/startfd.m');
    %
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    switch (obj.org)
        
        case 1 	% Call from TIMEPLOT, FDSPHERE, DORAND
            
            range = 1;
            radm = [];
            rasm = [];
            fdparain(obj.gobut);
            
            
        case 2	% Call from FDPARAIN
            
            dtokm = 1;
            pdc3;
            
            
        case 3	% Call from TIMEPLOT
            %
            % Default values
            %
            numran = 1000;				% # of points in random catalog
            distr = 1;
            stdx = 0.5;
            stdy = 0.5;
            stdz = 1;
            long1 = min(obj.catalog.Longitude);
            long2 = max(obj.catalog.Longitude);
            lati1 = min(obj.catalog.Latitude);
            lati2 = max(obj.catalog.Latitude);
            dept1 = min(abs(obj.catalog.Depth));
            dept2 = max(abs(obj.catalog.Depth));
            
            obj.E = obj.catalog;
            obj.randomcat();
            
            
        case 4	% Call from TIMEPLOT
            
            nev = 600;
            inc = 100;
            fdtimin;
            
            
        case 5  % Call from VIEW_DV
            
            range = 1;
            radm = [];
            rasm = [];
            crclparain;
            
    end	%end switch(org)
    
    
    
end
