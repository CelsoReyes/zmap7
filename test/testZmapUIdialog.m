classdef testZmapUIdialog < matlab.uitest.TestCase
    properties
        zdlg
        
        
        anum    = 3
        adate   = datetime
        dur     = hours(15)
        aname   = 'joe'
        cb      = true
        pop     = '';
        popsimp = '';
    end
    methods (Test)
        function testGadgets_NoChange_OKpressed(testCase)
            testCase.setup();
            
            testCase.zdlg.Create('Name', 'my test');
            dateh=testCase.zdlg.PartHandle('adate');
            testCase.assertTrue(dateh.Value == "2017-11-25 14:39:15")
            pause(1)
            
            testCase.press(testCase.zdlg.OKbutton);
            
            testCase.assertEqual(testCase.anum, 3);
            testCase.assertEqual(testCase.adate, datetime("2017-11-25 14:39:15"));
            testCase.assertEqual(testCase.dur, hours(15));
            testCase.assertEqual(testCase.cb, true);
            testCase.assertEqual(testCase.pop, 10);
            %delete(testCase.zdlg.hDialog);
        end
        
        function testGadgets_Changes_OKpressed(testCase)
            testCase.setup();
            testCase.zdlg.Create('Name', 'other test');
            
            testCase.type(testCase.zdlg.PartHandle('anum'), "5");
            testCase.type(testCase.zdlg.PartHandle('adate'), '2015-04-01');
            testCase.type(testCase.zdlg.PartHandle('aname'), 'jane');
            testCase.type(testCase.zdlg.PartHandle('dur'), "3");
            testCase.press(testCase.zdlg.PartHandle('cb')); %toggle checkbox off
            testCase.choose(testCase.zdlg.PartHandle('pop'), "-cicle");
            testCase.choose(testCase.zdlg.PartHandle('popsimp'), "a");
            pause(1)
            
            testCase.press(testCase.zdlg.OKbutton);
            pause(1)
            testCase.assertEqual(testCase.anum,     5)
            testCase.assertEqual(testCase.adate,    datetime(2015,4,1));
            testCase.assertEqual(testCase.dur,      days(3));
            testCase.assertEqual(testCase.aname,    'jane');
            testCase.assertEqual(testCase.cb,       false);
            testCase.assertEqual(testCase.pop,      20); % alternate value!
            testCase.assertEqual(testCase.popsimp,  'a'); % original values are char, not string
            %delete(testCase.zdlg.hDialog);
        end
        
        
        function testGadgets_Struct_OKpressed(testCase)
            testCase.setup_interactive();
            [st, okpressed] = testCase.zdlg.Create('INTERACTIVE: Press OK','DialogCreatedFcn',@unlockit);
            testCase.assertTrue(okpressed);
            testCase.assertEqual(st.anum, 3);
            testCase.assertEqual(st.adate, datetime("2017-11-25 14:39:15"));
            testCase.assertEqual(st.dur, hours(15));
            testCase.assertEqual(st.cb, true);
            testCase.assertEqual(st.pop, 10);
            %delete(testCase.zdlg.hDialog);
            
            function unlockit()
                %testCase.press(testCase.zdlg.OKbutton);
                % this test requires I press the OK button manually.
                matlab.uitest.unlock(testCase.zdlg.hDialog);
            end
        end
        
        function testGadgets_Changes_CANCELpressed(testCase)
            testCase.setup();
            testCase.zdlg.Create('Name', 'Cancel pressed');
            testCase.type(testCase.zdlg.PartHandle('anum'), "5");
            testCase.type(testCase.zdlg.PartHandle('adate'), '2015-04-01');
            testCase.type(testCase.zdlg.PartHandle('aname'), 'jane');
            testCase.type(testCase.zdlg.PartHandle('dur'), "3");
            testCase.press(testCase.zdlg.PartHandle('cb')); %toggle checkbox off
            testCase.choose(testCase.zdlg.PartHandle('pop'), "-cicle");
            testCase.choose(testCase.zdlg.PartHandle('popsimp'), "a");
            pause(1)
            oldpop = testCase.pop;
            testCase.press(testCase.zdlg.CANCELbutton);
            
            testCase.assertEqual(testCase.anum, 3);
            testCase.assertEqual(testCase.adate, datetime(2017,11,25,14,39,15));
            testCase.assertEqual(testCase.dur, hours(15));
            testCase.assertEqual(testCase.cb, true);
            testCase.assertEqual(testCase.pop, oldpop);
            %delete(testCase.zdlg.hDialog);
        end
        
        function testGadgets_CheckboxBehavior(testCase)
            testCase.zdlg = ZmapDialog(testCase);
            testCase.zdlg.AddEdit('x','Number',3,'tooltip');
            testCase.zdlg.AddCheckbox('cb', 'check here', true, {'x','z'}, 'tooltip');
            testCase.zdlg.AddEdit('y','Name','joe','tooltip');
            testCase.zdlg.AddEdit('z','Name','joe','tooltip');
            testCase.zdlg.Create('Name', 'checkbox test');
            
            myx = testCase.zdlg.PartHandle('x');
            myy = testCase.zdlg.PartHandle('y');
            myz = testCase.zdlg.PartHandle('z');
            mycb = testCase.zdlg.PartHandle('cb');
            
            testCase.assertTrue(myx.Enable == "on" && myz.Enable=="on" && myy.Enable=="on" && mycb.Value);
            % toggle checkbox off & verify
            testCase.press(testCase.zdlg.PartHandle('cb'));
            testCase.assertTrue(myx.Enable == "off" && myz.Enable=="off" && myy.Enable=="on" && ~mycb.Value);
            % toggle checkbox back on & verify
            testCase.press(testCase.zdlg.PartHandle('cb'));
            testCase.assertTrue(myx.Enable == "on" && myz.Enable=="on" && myy.Enable=="on" && mycb.Value);
            
            testCase.press(testCase.zdlg.CANCELbutton);
            %delete(testCase.zdlg.hDialog);
        end
    end
    methods
        function setup(testCase)
            
        % helper method to setu up same dialog box
        
            testCase.zdlg = ZmapDialog(testCase);
            dt = datetime(2017,11,25,14,39,15);
            testCase.adate = dt;
            testCase.zdlg.AddHeader('myheader');
            testCase.zdlg.AddEdit('anum','Number',3,'tooltip');
            testCase.zdlg.AddEdit('adate','Date',dt,'tooltip');
            testCase.zdlg.AddEdit('aname','Name','joe','tooltip');
            testCase.zdlg.AddDurationEdit('dur','How long?',hours(15),'tooltip',@days);
            testCase.zdlg.AddCheckbox('cb', 'check here', true, [], 'tooltip');
            testCase.zdlg.AddPopup('pop', 'popme', {'lolly-','-cicle'}, 'lolly-','',{10,20});
            testCase.zdlg.AddPopup('popsimp', 'simp', {'a','b'}, 'b','',[]);
            esp = EventSelectxionParameters('NumClosestEventsUpToRadius',250, 20)
            testCase.zdlg.AddEventSelector('evsel',esp);
        end
        function setup_interactive(testCase)
            
        % helper method to setu up same dialog box
        
            testCase.zdlg = ZmapDialog();
            dt = datetime(2017,11,25,14,39,15);
            testCase.adate = dt;
            testCase.zdlg.AddHeader('myheader');
            testCase.zdlg.AddEdit('anum','Number',3,'tooltip');
            testCase.zdlg.AddEdit('adate','Date',dt,'tooltip');
            testCase.zdlg.AddEdit('aname','Name','joe','tooltip');
            testCase.zdlg.AddDurationEdit('dur','How long?',hours(15),'tooltip',@days);
            testCase.zdlg.AddCheckbox('cb', 'check here', true, [], 'tooltip');
            testCase.zdlg.AddPopup('pop', 'popme', {'lolly-','-cicle'}, 'lolly-','',{10,20});
            testCase.zdlg.AddPopup('popsimp', 'simp', {'a','b'}, 'b','',[]);
        end
    end
end
