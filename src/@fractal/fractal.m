classdef fractal < handle
    
    properties
        catalog
        org
        gobut
        E
        
        range = 1
        radm = []
        rasm = []
        
        numran = 1000;				% # of points in random catalog
        distr = 1;
        stdx = 0.5;
        stdy = 0.5;
        stdz = 1;
    end
    
    methods
        function obj=fractal(org, catalog, gobut)
            obj.org = org;
            obj.catalog = catalog;
            obj.gobut = gobut;
            obj = obj.startfd(obj);
        end
        
        Dcross(obj)
        actdistr(obj)
        actrange(obj)
        crclparain(obj)
        dcparain(obj)
        dofdim(obj)
        dofdnofig(obj)
        dorand(obj, params)
        fdallfig(obj)
        fdparain(obj)
        fdsphere(obj)
        fdtimin(obj)
        pdc2(obj)
        pdc3(obj)
        pdc3nofig(obj)
        params=randomcat(obj)
        view_Dv(obj)
    end
    
    methods(Static)
        obj = startfd(org)
    end
end