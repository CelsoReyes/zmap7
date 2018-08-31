classdef testEventSelectionParameters < matlab.unittest.TestCase
    methods(Test)
        function testEmptyConstruction(testCase)
            evp = EventSelectionParameters();
            testCase.assertNotEmpty(evp);
        end
        function testClosestEvent(testCase)
            esp = EventSelectionParameters('NumClosestEvents', 100);
            
            testCase.assertEqual(esp.NumClosestEvents,100);
            testCase.assertTrue(esp.UseNumClosestEvents);
            NCE = 25;
            esp.NumClosestEvents = NCE;
            testCase.assertEqual(esp.NumClosestEvents,NCE);
            testCase.assertEqual(esp.PrevNumClosestEvents,100);
            testCase.assertTrue(esp.UseNumClosestEvents);
            
            esp.NumClosestEvents = inf;
            testCase.assertTrue(isinf(esp.NumClosestEvents));
            testCase.assertEqual(esp.PrevNumClosestEvents,NCE);
            testCase.assertFalse(esp.UseNumClosestEvents);
        end
        function testNumClosestEvents(testCase)
            esp = EventSelectionParameters('AllEventsInRadius', 5);
            
            % make sure radius accepts change, and affects prev radius appropriately
            testCase.assertEqual(esp.MaxSampleRadius, 5);
            testCase.assertTrue(esp.UseEventsInRadius);
            MSR = 20;
            esp.MaxSampleRadius = MSR;
            testCase.assertEqual(esp.MaxSampleRadius,MSR);
            testCase.assertEqual(esp.PrevMaxSampleRadius,5);
            testCase.assertTrue(esp.UseEventsInRadius);
            
            esp.MaxSampleRadius = inf;
            testCase.assertTrue(isinf(esp.MaxSampleRadius));
            testCase.assertEqual(esp.PrevMaxSampleRadius,MSR);
            testCase.assertFalse(esp.UseEventsInRadius);
        end
        function testNumClosestEventsUpToRadius(testCase)
            esp = EventSelectionParameters('NumClosestEventsUpToRadius',30, 5);
            
            testCase.assertEqual(esp.NumClosestEvents,30);
            testCase.assertEqual(esp.MaxSampleRadius, 5);
            testCase.assertTrue(esp.UseEventsInRadius);
            testCase.assertTrue(esp.UseNumClosestEvents);
        end
        function testChangeUseEventsInRadius(testCase)
            R = randi(1000);
            esp = EventSelectionParameters('AllEventsInRadius', R);
            esp.UseEventsInRadius = false;
            testCase.assertFalse(esp.UseEventsInRadius);
            testCase.assertTrue(isinf(esp.MaxSampleRadius));
            
            esp.UseEventsInRadius = true;
            testCase.assertTrue(esp.UseEventsInRadius);
            testCase.assertEqual(esp.MaxSampleRadius, R);
        end
        function testChangeUseNumClosestEvents(testCase)
            N = randi(100000);
            esp = EventSelectionParameters('NumClosestEvents', N);
            esp.UseNumClosestEvents = false;
            testCase.assertFalse(esp.UseNumClosestEvents);
            testCase.assertTrue(isinf(esp.NumClosestEvents));
            
            esp.UseNumClosestEvents = true;
            testCase.assertTrue(esp.UseNumClosestEvents);
            testCase.assertEqual(esp.NumClosestEvents, N);
        end
        function testDistanceUnits(testCase)
            esp = EventSelectionParameters('AllEventsInRadius', 25,'DistanceUnits','deg');
            testCase.assertEqual(esp.DistanceUnits, "degrees");
            esp.DistanceUnits = "km";
            testCase.assertEqual(esp.DistanceUnits, "kilometer");
            esp.DistanceUnits = 'radians';
            testCase.assertEqual(esp.DistanceUnits, "radians");
        end
            
        function testSelectionFromDistances_maxradius(testCase)
            evDists = [.001; 1; 5; 20; 100; 200;2000; 20000];
            esp = EventSelectionParameters('AllEventsInRadius', 5); % defaults to km
            mask1 = esp.SelectionFromDistances(evDists,'km');
            testCase.assertTrue(mask1(3));
            testCase.assertFalse(mask1(4));
            mask = esp.SelectionFromDistances(evDists,'kilometer');
            testCase.assumeEqual(mask, mask1);
            mask = esp.SelectionFromDistances(evDists,"kilometers");
            testCase.assumeEqual(mask, mask1);
            esp.SelectionFromDistances(evDists,"miles");
            esp.SelectionFromDistances(evDists,"radians");
            esp.SelectionFromDistances(evDists,"degrees");
            
            esp = EventSelectionParameters('AllEventsInRadius', 30000,'DistanceUnits','feet');
            esp.SelectionFromDistances(evDists,'km');
            esp.SelectionFromDistances(evDists,'deg');
            esp.SelectionFromDistances(evDists,'rad');
            
            esp = EventSelectionParameters('AllEventsInRadius', 5,'DistanceUnits','deg');
            esp.SelectionFromDistances(evDists,'km');
            esp.SelectionFromDistances(evDists,'deg');
            esp.SelectionFromDistances(evDists,'rad');
            esp.SelectionFromDistances(evDists,'miles');
            testCase.assertError(@()esp.SelectionFromDistances(evDists,'junk'),'maputils:unitsratio:unsupportedUnit');
            
        end
        function testSelectionFromDistances_closest(testCase)
            a = rand(100000,1) * 100; 
            esp = EventSelectionParameters('NumClosestEvents', 1000);
            mask = esp.SelectionFromDistances(a , 'kilometer');
            testCase.assertEqual(sum(mask), esp.NumClosestEvents); % right number of events returned
            testCase.assertTrue(max(a(mask)) <= min(a(~mask))); % these ARE the closest events
            
            % test both together
            esp.MaxSampleRadius = 30;
            mask = esp.SelectionFromDistances(a , 'kilometer');
            testCase.assertTrue(sum(mask) <= esp.NumClosestEvents);
            testCase.assertTrue(max(a(mask)) <= esp.MaxSampleRadius);
            
            % make sure, right number of events are returned
            esp = EventSelectionParameters('NumClosestEvents', 5);
            vals = 1:10;
            mask = esp.SelectionFromDistances(vals , 'kilometer');
            testCase.assertEqual(sum(mask), esp.NumClosestEvents);
            testCase.assertSize(mask,sizeof(vals));
            
        end
            
        function testConversion(testCase)
             esp = EventSelectionParameters('AllEventsInRadius', 1, 'DistanceUnits', 'degrees');
             val = esp.SelectionFromDistances([100 110 120], 'km');  % one degree of arc is ~111km
             testCase.assertEqual(val, [true true false]);
            
             esp.DistanceUnits = 'miles';
             val = esp.SelectionFromDistances([2.0, 1.5 1.0],'km'); % comparing against 1 mile
             testCase.assertEqual(val, [false true true]);
             
             esp.DistanceUnits = 'km';
             esp.MaxSampleRadius = 110;
             val = esp.SelectionFromDistances([0.9 1.0 1.1], 'degrees');
             testCase.assertEqual(val, [true false false]);
        end
            
    end
end