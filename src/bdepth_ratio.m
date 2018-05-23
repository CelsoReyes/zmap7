classdef bdepth_ratio < ZmapHGridFunction
% BDEPTH_RATIO compare b values at two different depths
% Stefan Wiemer 1/95
    
    properties
        topzone_ceiling = 0; % Top of TOP zone
        topzone_floor = 5; % Bottom of TOP zone
        bottomzone_ceiling = 7; % Top of BOTTOM zone
        bottomzone_floor = 15; % Bottom of BOTTOM zone
        fBinning = 0.1;  % magnitude bins
        Nmin=50;
        mc_choice % magnitude of completion method
        useAutoMcomp=true;
    end
    
    properties(Constant)
        PlotTag='bdepth'
        ReturnDetails = { ... VariableNames, VariableDescriptions, VariableUnits
            ...
            ... % these are returned from the calculation
            'bv_ratio','b-value Ratio Map','';... %valueMap [old] #1
            'magco','Magnitude of completion (bottom)','mag';... #2 
            'bv2','b-value Ratio map (with autoestimate Mcomp)','';... #3
            'av', 'a-value ratios','';... #4 avm
            'Prmap','Utsu Probability map','';... #5 Prmap
            'top_b', 'Top Zone b-value map','';... #6 tob_b
            'bottom_b','Bottom Zone b-value map','';... #7 bottom_b
            'per_top','% of nodal EQs within TOP zone','';... #8 per_in_top
            'per_bot','% of nodal EQs within BOTTOM zone','';... #9 per_in_bot
            'Number_of_Events_top', 'Number of events in TOP zone', '';... #10
            'Number_of_Events_bot', 'Number of events in BOTTOM zone', '';... #11
            ...
            };
        CalcFields = {'bv_ratio','magco','bv2','av','Prmap',...
            'top_b','bottom_b','per_top','per_bot',...
            'Number_of_Events_top','Number_of_Events_bot'};
    end
    
    methods
        function obj = bdepth_ratio(zap, varargin) 
            % BDEPTH_RATIO compare b values at two different depths
            
            report_this_filefun();
            
            obj@ZmapHGridFunction(zap, 'bv_ratio');
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            if nargin<2
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                % run this function without human interaction
                obj.doIt();
            end
            
        end
        
        
        function InteractiveSetup(obj)
            
            % get two time periods, along with grid and event parameters
            zdlg=ZmapDialog([]);            
            zdlg.AddBasicCheckbox('useAutoMcomp', 'Automatically estimate magn. of completeness',...
                obj.useAutoMcomp, [],'Maximum likelihood - automatic magnitude of completeness');
            zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',calc_Mc(),1,...
                'Choose the calculation method for Mc');
            zdlg.AddBasicHeader('Please define two Depth ranges to compare');
            zdlg.AddBasicEdit('top_of_top','TOP zone ceiling [km]',obj.topzone_ceiling,'');
            zdlg.AddBasicEdit('bottom_of_top','TOP zone floor [km]',obj.topzone_floor,'');
            zdlg.AddBasicEdit('top_of_bottom','BOTTOM zone ceiling [km]',obj.bottomzone_ceiling,'');
            zdlg.AddBasicEdit('bottom_of_bottom','BOTTOM zone floor [km]',obj.bottomzone_floor,'');
            zdlg.AddBasicEdit('Nmin','Min. No. of events > Mc', obj.Nmin,...
                'Min # events greater than magnitude of completeness (Mc)');
            zdlg.AddEventSelectionParameters('evsel', obj.EventSelector)
            [res,okPressed]=zdlg.Create('Depth Ratio Grid input parameters');
            if ~okPressed
                return
            end
            
            obj.SetValuesFromDialog(res)
            
            obj.doIt()
        end
        function SetValuesFromDialog(obj, res)
            obj.useAutoMcomp=logical(res.useAutoMcomp);
            obj.mc_choice = res.mc_choice;
            obj.topzone_ceiling = res.top_of_top;
            obj.topzone_floor = res.bottom_of_top;
            obj.bottomzone_ceiling = res.top_of_bottom;
            obj.bottomzone_floor = res.bottom_of_bottom;
            obj.Nmin=res.Nmin;
            obj.EventSelector=res.evsel;
        end
        
        function CheckPreConditions(obj)
            assert(obj.topzone_ceiling < obj.topzone_floor, 'TOP ZONE: zone floor is above zone ceiling');
            assert(obj.bottomzone_ceiling < obj.bottomzone_floor, 'BOTTOM ZONE: zone floor is above zone ceiling');
        end
        
        function modifyGlobals(obj)
            obj.ZG.bvg = obj.Result.values;
        end
        
        function results=Calculate(obj)
            
            %  make grid, calculate start- endtime etc.  ...
            %
            
            % find row index of ratio midpoint
            l = obj.RawCatalog.Depth >= obj.topzone_ceiling & obj.RawCatalog.Depth <  obj.topzone_floor;
            top_zone = obj.RawCatalog.subset(l);
            
            l = obj.RawCatalog.Depth >= obj.bottomzone_ceiling & obj.RawCatalog.Depth <  obj.bottomzone_floor;
            bot_zone = obj.RawCatalog.subset(l);
            
            
            % overall b-value
            [tbo1] =  bvalca3(top_zone.Magnitude,obj.useAutoMcomp);
            [bbo1] =  bvalca3(bot_zone.Magnitude,obj.useAutoMcomp);
            
            depth_ratio = tbo1/bbo1;
            disp(depth_ratio);
            
            
            % loop over all points
            obj.gridCalculations(@calculation_function);
            
            obj.Result.top.depthrange_km=[obj.topzone_ceiling obj.topzone_floor];
            obj.Result.bottom.depthrange_km=[obj.bottomzone_ceiling obj.bottomzone_floor];
            
            if nargout
                results=obj.Result.values;
            end
           
            
            %catsave3('bdepth_ratio');
            
            
            % to View the b-value map : view_bdepth
            
            function out=calculation_function(b)
                topb = b.subset( b.Depth >= obj.topzone_ceiling & b.Depth <  obj.topzone_floor );
                per_in_top = (topb.Count/b.Count)*100.0;
                
                botb = b.subset( b.Depth >= obj.bottomzone_ceiling & b.Depth <  obj.bottomzone_floor );
                per_in_bot = (botb.Count/b.Count)*100.0;
                
                
                
                if length(topb) < obj.Nmin  || length(botb) < obj.Nmin
                    
                    [Mc_valueTop] = calc_Mc(topb, obj.mc_choice,obj.fBinning);
                    [Mc_valueBot] = calc_Mc(botb, obj.mc_choice, obj.fBinning);
                    [topbv, topbv2, ~, topav, n1]=calc_bval_both_ways(topb,Mc_valueTop,tbo1);
                    [botbv, botbv2, magco, botav, n2]=calc_bval_both_ways(botb,Mc_valueBot,bbo1);
                else
                    [topbv, topbv2, ~, topav,  n1]=deal(nan);
                    [botbv, botbv2, magco, botav, n2]=deal(nan);
                end
                bv = topbv/botbv; 
                bv2 = topbv2/botbv2; 
                av = topav/botav;
                
                n = n1+n2;
                ZG.bo1 = topbv;
                da = -2*n*log(n) + 2*n1*log(n1+n2 * topbv/botbv) + 2*n2*log(n1 * botbv/topbv + n2) - 2;
                pr = (1  -  exp(-da/2-2))*100;
                
                ltopb = topb.Count;
                lbotb = botb.Count;
                
                
                
                out = [bv magco ...
                    bv2 av pr ...
                    topbv botbv ...
                    per_in_top per_in_bot ...
                    ltopb lbotb];
                
                
                function [bv, bv2, magco, av, n] = calc_bval_both_ways(mycat,magco,bo1)
                    % where mycat is already the subset value
                    idx = mycat.Magnitude >= magco-0.05;
                    n=sum(idx);
                    if sum(idx) >= obj.Nmin
                        [bv, magco, ~, av] =  bvalca3(mycat.Magnitude(idx),false,bo1); %not automatic estimate of Mcomp 
                        bv2 =  bvalca3(mycat.Magnitude(idx),true); % automatic estimate of Mcomp 
                    else
                        [bv, bv2, magco, av] = deal(nan);
                    end
                end
            end
        end % Calculate
        
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='b-value depth ratio grid';
            h=uimenu(parent,'Label',label,Futures.MenuSelectedFcn, @(~,~)bdepth_ratio(zapFcn()));
        end
        
        function obj=my_load()
            error('Not implemented');
            % Load exist b-grid
            [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
            if length(path1) > 1
                
                load([path1 file1])
                normlap2=nan(length(tmpgri(:,1)),1)
                
                
                normlap2(ll)= bvg(:,1);
                valueMap=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,5);
                r=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,6);
                meg=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,2);
                old1=reshape(normlap2,length(yvect),length(xvect));
                
                %  normlap2(ll)= bvg(:,7);
                %  pro=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,7);
                avm=reshape(normlap2,length(yvect),length(xvect));
                
                %  normlap2(ll)= bvg(:,9);
                % stanm=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,8);
                Prmap=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,9);
                top_b=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,10);
                bottom_b=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,11);
                per_top=reshape(normlap2,length(yvect),length(xvect));
                
                normlap2(ll)= bvg(:,12);
                per_bot=reshape(normlap2,length(yvect),length(xvect));
                
                %    normlap2(ll)= bvg(:,13);
                %    ltopb=reshape(normlap2,length(yvect),length(xvect));
                
                %   normlap2(ll)= bvg(:,14);
                %  lbotb=reshape(normlap2,length(yvect),length(xvect));
                
                old = valueMap;
                
                view_bdepth
            else
                return
            end
        end
    end
end