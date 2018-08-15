classdef bdepth_ratio < ZmapHGridFunction
% BDEPTH_RATIO compare b values at two different depths
% Stefan Wiemer 1/95
    
    properties
        topzone_ceiling         = 0;    % Top of TOP zone
        topzone_floor           = 5;    % Bottom of TOP zone
        bottomzone_ceiling      = 7;    % Top of BOTTOM zone
        bottomzone_floor        = 15;   % Bottom of BOTTOM zone
        fBinning                = 0.1;  % magnitude bins
        Nmin                    = 50;
        mc_choice   McMethods   = McMethods.MaxCurvature % magnitude of completion method
        useAutoMcomp McAutoEstimate = true
    end
    
    properties(Constant)
        PlotTag='bdepth'
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            ...
            ... % these are returned from the calculation
            'bv_ratio',     'b-value Ratio Map',                            '';... %valueMap [old] #1
            'magco',        'Magnitude of completion (bottom)',             'mag';... #2 
            'bv2',          'b-value Ratio map (with autoestimate Mcomp)',  '';... #3
            'av',           'a-value ratios',                   '';... #4 avm
            'Prmap',        'Utsu Probability map',             '';... #5 Prmap
            'top_b',        'Top Zone b-value map',             '';... #6 tob_b
            'bottom_b',     'Bottom Zone b-value map',          '';... #7 bottom_b
            'per_top',      '% of nodal EQs within TOP zone',   '';... #8 per_in_top
            'per_bot',      '% of nodal EQs within BOTTOM zone','';... #9 per_in_bot
            'Number_of_Events_top', 'Number of events in TOP zone',     '';... #10
            'Number_of_Events_bot', 'Number of events in BOTTOM zone',  '';... #11
            ...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields = {...
            'bv_ratio',     'magco',    'bv2',      'av',       'Prmap',...
            'top_b',        'bottom_b', 'per_top',  'per_bot',...
            'Number_of_Events_top',     'Number_of_Events_bot'};
        
        ParameterableProperties = ["topzone_ceiling" "topzone_floor"....
                    "bottomzone_ceiling" "bottomzone_floor"...
                    "fBinning" "Nmin" "mc_choice" "useAutoMcomp"];
    end
    
    methods
        function obj = bdepth_ratio(zap, varargin) 
            % BDEPTH_RATIO compare b values at two different depths
            
            obj@ZmapHGridFunction(zap, 'bv_ratio');
            report_this_filefun();
            
            obj.parseParameters(varargin);
            obj.StartProcess();
            
        end
        
        
        function InteractiveSetup(obj)
            
            % get two time periods, along with grid and event parameters
            zdlg=ZmapDialog([]);   
            zdlg.AddMcAutoEstimateCheckbox('useAutoMcomp',  obj.useAutoMcomp);
            zdlg.AddMcMethodDropdown('mc_choice',           obj.mc_choice);
            zdlg.AddHeader('Please define two Depth ranges to compare');
            zdlg.AddEdit('top_of_top','TOP zone ceiling [km]',         obj.topzone_ceiling,'');
            zdlg.AddEdit('bottom_of_top','TOP zone floor [km]',        obj.topzone_floor,'');
            zdlg.AddEdit('top_of_bottom','BOTTOM zone ceiling [km]',   obj.bottomzone_ceiling,'');
            zdlg.AddEdit('bottom_of_bottom','BOTTOM zone floor [km]',  obj.bottomzone_floor,'');
            zdlg.AddEdit('Nmin','Min. No. of events > Mc',             obj.Nmin,...
                'Min # events greater than magnitude of completeness (Mc)');
            zdlg.AddEventSelector('evsel',                       obj.EventSelector)
            [res,okPressed]=zdlg.Create('Depth Ratio Grid input parameters');
            if ~okPressed
                return
            end
            
            obj.SetValuesFromDialog(res)
            
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            obj.useAutoMcomp        = res.useAutoMcomp;
            obj.mc_choice           = res.mc_choice;
            obj.topzone_ceiling     = res.top_of_top;
            obj.topzone_floor       = res.bottom_of_top;
            obj.bottomzone_ceiling  = res.top_of_bottom;
            obj.bottomzone_floor    = res.bottom_of_bottom;
            obj.Nmin                = res.Nmin;
            obj.EventSelector       = res.evsel;
        end
        
        
        function modifyGlobals(obj)
            obj.ZG.bvg = obj.Result.values;
        end
        
        function results=Calculate(obj)
            
            assert(obj.topzone_ceiling < obj.topzone_floor, 'TOP ZONE: zone floor is above zone ceiling');
            assert(obj.bottomzone_ceiling < obj.bottomzone_floor, 'BOTTOM ZONE: zone floor is above zone ceiling');

            %  make grid, calculate start- endtime etc.  ...
            %
            
            % find row index of ratio midpoint
            l = obj.RawCatalog.Depth >= obj.topzone_ceiling & obj.RawCatalog.Depth <  obj.topzone_floor;
            top_zone = obj.RawCatalog.subset(l);
            
            l = obj.RawCatalog.Depth >= obj.bottomzone_ceiling & obj.RawCatalog.Depth <  obj.bottomzone_floor;
            bot_zone = obj.RawCatalog.subset(l);
            
            
            % overall b-value
            [top_b_overall] = bvalca3(top_zone.Magnitude, obj.useAutoMcomp);
            [bottom_b_overall] = bvalca3(bot_zone.Magnitude, obj.useAutoMcomp);
            
            depth_ratio = top_b_overall/bottom_b_overall;
            disp(depth_ratio);
            
            [~,mcCalculator] = calc_Mc([], obj.mc_choice,obj.fBinning);
            
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
                    
                    [Mc_valueTop] = mcCalculator(topb);
                    [Mc_valueBot] = mcCalculator(botb);
                    [topbv, topbv2, ~, topav, n1]=calc_bval_both_ways(topb,Mc_valueTop, top_b_overall);
                    [botbv, botbv2, magco, botav, n2]=calc_bval_both_ways(botb,Mc_valueBot, bottom_b_overall);
                else
                    [topbv, topbv2, ~, topav,  n1]=deal(nan);
                    [botbv, botbv2, magco, botav, n2]=deal(nan);
                end
                bv = topbv/botbv; 
                bv2 = topbv2/botbv2; 
                av = topav/botav;
                
                n = n1+n2;
                ZG.overall_b_value = topbv;
                da = -2*n*log(n) + 2*n1*log(n1+n2 * topbv/botbv) + 2*n2*log(n1 * botbv/topbv + n2) - 2;
                pr = (1  -  exp(-da/2-2))*100;
                
                ltopb = topb.Count;
                lbotb = botb.Count;
                
                
                
                out = [bv magco ...
                    bv2 av pr ...
                    topbv botbv ...
                    per_in_top per_in_bot ...
                    ltopb lbotb];
                
                
                function [bv, bv2, magco, av, n] = calc_bval_both_ways(mycat,magco,b_overall)
                    % where mycat is already the subset value
                    idx = mycat.Magnitude >= magco-0.05;
                    n=sum(idx);
                    if sum(idx) >= obj.Nmin
                        [bv, magco, ~, av] =  bvalca3(mycat.Magnitude(idx), McAutoEstimate.manual, b_overall); %not automatic estimate of Mcomp 
                        bv2 =  bvalca3(mycat.Magnitude(idx), McAutoEstimate.auto); % automatic estimate of Mcomp 
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
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.bdepth_ratio(zapFcn()));
        end
        
        function obj=my_load()
            unimplemented_error();
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