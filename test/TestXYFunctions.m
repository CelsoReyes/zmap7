classdef TestXYFunctions < matlab.uitest.TestCase
    properties(TestParameter)
        classToTest = getclasses('XYfun');
    end
    
    properties
        zap         =  getZmapAnalysisPkg();
    end
    
    methods(Test)
        function testInitializable(testCase, classToTest)
            disp(classToTest);
            myclass = str2func(classToTest);
            obj = myclass(testCase.zap,'DelayProcessing',true,'InteractiveMode',false,'AutoShowPlots',false);
            testCase.assumeClass(obj,myclass);
            testCase.assertEqual(obj.RawCatalog,    zap.Catalog);
            testCase.assertEqual(obj.EventSelector, zap.EventSel);
            testCase.assertEqual(obj.Grid,          zap.Grid);
            testCase.assertEqual(obj.Shape,         zap.Shape);
            testCase.assertTrue(any( ReturnDetails.Properties.VariableNames == obj.active_col ));
            
            % XYfun.objectHandle(abc)
        end
        
        function testCalculatable(testCase, classToTest)
            disp(classToTest);
            myclass = str2func(classToTest);
            obj = myclass(testCase.zap,'DelayProcessing',true,'InteractiveMode',false,'AutoShowPlots',false);
            results = obj.Calculate();
            testCase.assumeNotEmpty(results);
            
        end
    end

end

function zap = getZmapAnalysisPkg()
    
    % get catalog
    catalogFile = 'resrc/sample/SED_fdsn_2000_on.mat';
    c=load(catalogFile,'catalog');
    
    % set up sampling parameters
    num_events  = 200;
    max_radius = 50; 
    dist_units = 'km';
    evsel = EventSelectionParameters('NumClosestEventsUpToRadius', num_events, max_radius,'DistanceUnits',dist_units);
    
    % set up grid
    g_opts.dx = 10;
    g_opts.dy = 10;
    g_opts.dz = 10;
    g_opts.xyunits = 'kilometer';
    g_opts.FollowMeridians = false;
    g_opts.GridEntireArea = false;
    
    %center on ETHZ
    fixedOpts.UseFixedAnchorPoint = true;
    fixedOpts.XAnchor = 47.3763;
    fixedOpts.YAnchor = 8.5477;
    fixedOpts.ZAnchor = 0;
    
    gopt= GridOptions(g_opts, fixedOpts);
    g = ZmapGrid('testgrid', gopt);
    
    % set up shape
    sh = load_shape('eq_data/switzerland_shape.csv');
    
    zap = ZmapAnalysisPkg([],c,evsel,g,sh);
    
    %zap = ZmapAnalysisPkg.fromGlobal('primeCatalog');
    
end

function c = getfuns(packageName)
    a=what(packageName);
    a.m(a.m == "Contents.m") = [];
    funNames=replace(a.m,'.m','');
    funNames = strcat(packageName, '.', funNames);
    c = cellfun(@str2func,funNames,'UniformOutput',false);
end

function c = getclasses(packageName)
    a=what(packageName);
    a.m(a.m == "Contents.m") = [];
    funNames=replace(a.m,'.m','');
    c = strcat(packageName, '.', funNames);
end