classdef bvalmapt < ZmapGridFunction
    properties
        t1 % start of timeperiod 1
        t2 % end of timeperiod 1
        t3 % start of timeperiod 2
        t4 % end of timeperiod 2
        minnu % minimum number of events/node/timeperiod
        useAutoMcomp=true;
    end
    properties(Access=private)
        duration_A
        duration_B
    end
    
    properties(Constant)
        PlotTag='bvalmapt';
        ReturnDetails = { ... VariableNames, VariableDescriptions, VariableUnits
            'nEvents_1','Number of events in node - period 1', '';...
            'bval_1','b-value map first period','';... #1 'b-value'
            'aval_1','a-value for period 1','';... 'av
            'magco_1','mag of completeness map - period 1','mag';... #2 'Mcomp1' 
            
            'nEvents_2', 'Number of events in node - period 2', '';...
            'bval_2','b-value map second period','';...#6 'b-value'
            'aval_2', 'a-value for period 2', '';... #8 avm
            'magco_2','mag of completeness map - period 2','mag';... #12 'Momp2'
            
            'pro','Probability Map (Utsus test for b1 and b2)','';... #7 'P'
            
            'max_mag', 'Maximum magnitude at node', 'mag';... #13 [maxm] [outside]
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';...
            'db12','Differential B-value','';... #11[outside] 'b-value'
            'dbperc','b change in percent','pct';...[outside]#14 'b-value change'
            'eqprobchange','Earthquake probability change map (M5)',''; ... [log10(#13)]'dP'
            'stanm','standard error map (P6a - pro)','';... (#9-#7) 'error in b' 
            'dmag','differential completeness map','';...[#2 - #12][outside] 'DMc'
            'P6a','P6 for period 2','per year';...
            'P6b','P6 for period 1','per year';...
            'P6a_over_P6b','ratio of P6  (period1/period2)','ratio';...
            'x', 'Longitude', 'deg';... #3[outside]
            'y', 'Latitude', 'deg';... #4[outside]
            
            ...%'r','resolution Map - number of events',''... #5 [ actually, number of events & outside]
            'nEvents', 'Number of events in node', ''... # was #5 'r' ['Resolution map']
            };
        % the viewplotting methods also had call to zhist,
        %
        % various select eq in polygons (new/hold) [selectp with various hold_state],
        % and various select eq in circle:
        %      (general [cirbva,met='ni', 
        %       constant r [cirbva,met='ra'],
        %       time split[cirbvat met='ti'],
        %       overlay exist [hold_state=true,cirbva])
        %
    end
    
    methods
        function obj=bvalmapt(zap, varargin)
            % This subroutine creates a differential bvalue map
            % for two time periods. The difference in
            % both b and Mc can be displayed.
            %   Stefan Wiemer 1/95
            %   Rev. R.Z. 4/2001
            % turned into function by Celso G Reyes 2017
            
            
            report_this_filefun(mfilename('fullpath'));
            obj.active_col='db12';
            if ~exist('zap','var') || isempty(zap)
                zap = ZmapAnalysisPkg.fromGlobal();
            end
            
            ZmapFunction.verify_catalog(zap.Catalog);
            
            obj.EventSelector = zap.EventSel;
            if obj.EventSelector.useNumNearbyEvents
                disp('This is designed to use events in constant radius instead of # of events.')
                obj.EventSelector.useNumNearbyEvents=false;
                obj.EventSelector.useEventsInRadius=true;
            end
            %obj.ra = obj.EventSelector.radius_km;
            obj.RawCatalog = zap.Catalog;
            obj.Grid = zap.Grid;
            obj.Shape = zap.Shape;
            
            obj.InteractiveSetup();
            
        end
        
        function InteractiveSetup(obj)
            
            
            t0b=min(obj.RawCatalog.Date());
            teb=max(obj.RawCatalog.Date());
            
            obj.t1 = t0b;
            obj.t4 = teb;
            obj.t2 = t0b + (teb-t0b)/2;
            obj.t3 = obj.t2+seconds(0.001);
            %{
            sdlg.prompt='Start Time A : T1 = '; sdlg.value=t1;
            sdlg(2).prompt='End Time A : T2 = '; sdlg(2).value=t2;
            sdlg(3).prompt='Start Time B: T3 = '; sdlg(3).value=t3;
            sdlg(4).prompt='End Time B: T4 = '; sdlg(4).value=t4;
            sdlg(5).prompt='Min # of events in each period?'; sdlg(5).value=50;
            [~,~,obj.t1,obj.t2,...
                obj.t3,obj.t4,...
                obj.minnu] = smart_inputdlg('differential b-value map', sdlg);
            %}
            
            %% make the interface
            zdlg = ZmapDialog();
            
            zdlg.AddBasicHeader('Choose stuff');
            %zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',calc_Mc(),1,'Choose the calculation method for Mc');
            
            zdlg.AddBasicCheckbox('useAutoMcomp', 'Automatically estimate magn. of completeness',...
                obj.useAutoMcomp, [],'Maximum likelihood - automatic magnitude of completeness');
            %zdlg.AddBasicEdit('Nmin','Min. No. of events > Mc', obj.Nmin,...
            %    'Min # events greater than magnitude of completeness (Mc)');
            
            zdlg.AddBasicEdit('t1','Start Time A : ', obj.t1, 'Start time for first period');
            zdlg.AddBasicEdit('t2','End Time A : ', obj.t2, 'End time for first period');
            zdlg.AddBasicEdit('t3','Start Time B : ', obj.t3, 'Start time for Second period');
            zdlg.AddBasicEdit('t4','End Time B :', obj.t4, 'Start time for Second period');
            
            zdlg.AddBasicEdit('ra', 'Constant radius [km]', obj.EventSelector.radius_km,...
                'Radus used in calculation');
            zdlg.AddBasicEdit('minnu', 'Minimum number of events in each period:', ...
                obj.EventSelector.requiredNumEvents,'');
            
            [res,okPressed] = zdlg.Create('b-Value Grid Parameters');
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj,res)
            %obj.ZG.inb2=res.useAutoMcomp;
            obj.useAutoMcomp=res.useAutoMcomp;
            obj.EventSelector.radius_km=res.ra;
            obj.t1 = res.t1;
            obj.t2 = res.t2;
            obj.t3 = res.t3;
            obj.t4 = res.t4;
            obj.minnu = res.minnu;
            obj.duration_A = obj.t2 - obj.t1;
            obj.duration_B = obj.t4 - obj.t3;
            % note, dx & dy were originally in degrees
        end
        
        function results=Calculate(obj)
            % get the grid-size interactively and
            % calculate the b-value in the grid by sorting
            % thge seimicity and selectiong the radius neighbors
            % to each grid point
            
            returnFields = obj.ReturnDetails(:,1);
            returnDesc = obj.ReturnDetails(:,2);
            returnUnits = obj.ReturnDetails(:,3);
            
            % overall b-value
            [bv, magco, ~   , av_unused,  ~] =  bvalca3(obj.RawCatalog.Magnitude, obj.useAutoMcomp);
            %ZG.bo1 = bv; 
            %no1 = obj.RawCatalog.Count;
            
            % loop over all points
            [bvg,nEvents,maxDists,maxMag, ll]=gridfun(@calculation_function,...
                obj.RawCatalog, ...
                obj.Grid, obj.EventSelector,...
                9);
            
            bvg= modify_raw_results(bvg);
            
            myvalues = array2table(bvg,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            obj.Result.values=myvalues;
            if nargout
                results=myvalues;
            end
            
            %catsave3('bvalmapt');
            
            
            function out=calculation_function(catalog)
                
                idx_1 =  catalog.Date >= obj.t1 &  catalog.Date <obj.t2 ;
                no_1=sum(idx_1);
                enough_1 = no_1 >= obj.minnu;
                
                idx_2 = catalog.Date >= obj.t3 &  catalog.Date < obj.t4 ;
                no_2=sum(idx_2);
                enough_2  =no_2 >= obj.minnu;
                
                if ~enough_1 && ~enough_2
                    out = [ no_1 NaN NaN NaN...
                        no_2 NaN NaN NaN...
                        NaN];
                    return
                end
                % call the b-value function
                
                
                if  enough_1
                    % calculate magnitudes, bvalues, etc for events during this time frame
                    [bv_1, magco_1, ~, av_1,  ~] =  bvalca3(catalog.Magnitude(idx_1), obj.useAutoMcomp, bv);
                    
                else
                    % calculate magnitudes, bvalues, etc forr *ALL* events, regardless of time
                    [bv_1, magco_1, ~, ~,  ~] =  bvalca3(catalog.Magnitude, obj.useAutoMcomp, bv);
                    av_1=NaN;
                    % pr = 50; % completely controlled by the 2nd time period, for some reason.
                end
                
                if  enough_2
                    % calculate magnitudes, bvalues, etc for events during this time frame
                    [bv_2, magco_2, ~, av_2,  pr] =  bvalca3(catalog.Magnitude(idx_2), obj.useAutoMcomp,bv_1);
                    
                else
                    av_2=NaN;
                    if ~enough_1
                        % these values were already calculated, so don't bother repeating
                        bv_2 = bv_1;
                        magco_2 = maco_1;
                    else
                        % calculate magnitudes, bvalues, etc forr *ALL* events, regardless of time
                        [bv_2, magco_2, ~, ~, ~] =  bvalca3(catalog.Magnitude, obj.useAutoMcomp, bv_1);
                    end
                    pr = 50;
                end
            
                if pr >= 40
                    out = [no_1 bv_1 av_1 magco_1...
                        no_2 bv_2 av_2 magco_2...
                        pr];
                else
                    out = [ no_1 NaN NaN NaN ... 
                        no_2 NaN NaN NaN ...
                         pr] ;
                end
            end %calculation_function
            
            function rslt=modify_raw_results(rslt)
                % do any calculations that can be performed after-the-fact and aren't grid dependent
                
                rField=@(s) strcmp(s,returnFields);
                %rVals=@(s) rslt(:,rField(s)); % good for right-hand side calculations only
                %idxVals=@(n,s) rslt(n,rField(s));
                
                
                % fields returned [in order] by gridfun:
                % nEvents1
                % bval_1
                % aval_1
                % magco_1
                % nEvents_2
                % bval_2
                % aval_2
                % magco_2
                % pro
                
                % add fields created by gridfun
                rslt(:,rField('nEvents'))=nEvents; % last field, makes sure rslt is big enough
                rslt(:,rField('x'))=obj.Grid.X(:);
                rslt(:,rField('y'))=obj.Grid.Y(:);
                rslt(:,rField('Radius_km'))=maxDists;
                rslt(:,rField('max_mag'))=maxMag;
                
                
                % deal with this mysterious P6b 
                idx = rVals('nEvents_1') >= obj.minnu;
                rfactor=zeros(size(idx));
                rfactor(idx)=6.5;
                rfactor(~idx)=5.0;
                tmp_av = rVals('aval_1');
                
                % replace av values for grid points where there are not enough events.
                tmp_av(~idx) = log10(idxVals(~idx,'nEvents_1')) + idxVals(~idx,'bval_1') .* idxVals(~idx,'magco_1');
                rslt(:,rField('P6b'))=10.^(tmp_av - rVals('bval_1').* rfactor) ./ years(obj.duration_A);
                rslt(~idx, rField('bval_1')) = NaN;
                
                % deal with this mysterious P6a
                idx = rVals('nEvents_2') >= obj.minnu;
                rfactor=zeros(size(idx));
                rfactor(idx)=6.5;
                rfactor(~idx)=5.0;
                tmp_av = rVals('aval_2');
                
                % replace av values for grid points where there are not enough events.
                tmp_av(~idx)= log10(idxVals(~idx,'nEvents_2')) + idxVals(~idx,'bval_2') .* idxVals(~idx,'magco_2');
                rslt(:,rField('P6a'))=10.^(tmp_av - rVals('bval_2').* rfactor) ./ years(obj.duration_B);
                rslt(~idx, rField('bval_2')) = NaN;
                
                rslt(:,rField('P6a_over_P6b'))=rVals('P6a') ./ rVals('P6b');
                
                rslt(:,rField('stanm'))=rVals('P6a')-rVals('pro');
                rslt(:,rField('dbperc'))=rVals('bval_1')./rVals('bval_2') .* 100 - 100; % bv2/bv*100-100
                rslt(:,rField('dmag'))=rVals('magco_1')-rVals('magco_2');
                rslt(:,rField('eqprobchange'))=log10(rVals('max_mag'));
                rslt(:,rField('db12'))=rVals('bval_1') - rVals('bval_2');
                function x=rVals(s)
                    x=rslt(:,rField(s)); % good for right-hand side calculations only
                end
                function x=idxVals(n,s)
                    x=rslt(n,rField(s));
                end
            end
        end % Calculate
        
        
        
    end
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Differential b-value map';
            h=uimenu(parent,'Label',label,'Callback', @(~,~)bvalmapt(zapFcn()));
        end
        function obj= load()
            %RZ Load existing  diff b-grid
            report_this_filefun(mfilename('fullpath'));
            warndlg('Not implemented');
            %{
            [file1,path1] = uigetfile(['*.mat'],'Diff b-value gridfile');
            if length(path1) > 1
                
                load([path1 file1])
                normlap2=nan(length(tmpgri(:,1)),1)
                normlap2(ll)= bvg(:,1);
                bm1=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,5);
                r=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,6);
                bm2=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,2);
                magco1=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,12);
                magco2=reshape(normlap2,length(yvect),length(xvect));
                
                dmag = magco1 - magco2;
                
                normlap2(ll)= bvg(:,7);
                pro=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,8);
                avm=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,9);
                stanm=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,10);
                maxm=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,11);
                db12=reshape(normlap2,length(yvect),length(xvect));
                
                valueMap = db12;
                old = valueMap;
                
                view_bvtmap
            else
                return
            end
            %}
        end
    end % STATIC methods
end
