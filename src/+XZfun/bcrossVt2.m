classdef bcrossVt2 < ZmapVGridFunction
    % BCROSSVT2 compares b-values for 2 time periods within a cross section
    %   Stefan Wiemer 1/95
    properties
        
        ni = 100;
        ra = ZmapGlobal.Data.ra;
        dd = 1.0
        dx = 1.0
        
        % get the time periods of interest
        t0b datetime = ZmapGlobal.Data.t0b;
        teb datetime = ZmapGlobal.Data.teb;
        t1  datetime = ZmapGlobal.Data.t0b;
        t2  datetime = ZmapGlobal.Data.t0b + ([ ZmapGlobal.Data.teb - ZmapGlobal.Data.t0b])/2;
        
        t3  datetime = ZmapGlobal.Data.t0b + ([ ZmapGlobal.Data.teb - ZmapGlobal.Data.t0b])/2 + seconds(.1);
        t4  datetime = ZmapGlobal.Data.teb;
        mcAuto      McAutoEstimate              = true;
        wtAuto      LSWeightingAutoEstimate     = true;
    end
    
    properties(Constant)
        PlotTag = 'bcrossVt2'
        ReturnDetails = cell2table({... VariableNames, VariableDescriptions, VariableUnits
            'b_value_1', 'b-value I', '';...1 bv > valueMap [discarded later]
            'Mc_value1', 'Magnitude of Completion (Mc) I', '';...2 magco > old1
            'stan1','error in b I','';...9 stan > stanm
            'a_value1', 'a-value I', '';... 8 av > avm
            'probability', 'Probability I','';...7 pr > pro
            'count_1', 'Number of events I','';...
            ...
            'b_value_2', 'b-value II', '';...1 bv2 > valueMap [discarded later]
            'Mc_value2', 'Magnitude of Completion (Mc) II', '';...2 magco2 > old1
            'stan2','error in b II','';...9 stan2 > stanm
            'a_value2', 'a-value II', '';... 8 av2 > avm
            'probability2', 'Probability II','';...7 pr2 > pro
            'count_2', 'Number of events II','';...
            ...
            'distance_along_strike','distance along cross-section strike','km';...
            'dM','Difference in Mc','mag';... Mc_value2 - Mc_value1 (Not)maxm-magco
            'delta_bval','Difference in b-values','';... old - meg  : BV2 - BV1
            'dbperc','b-value change','pct';... bv2/bv*100-100 
            }, 'VariableNames', {'Names','Descriptions','Units'});
        
        CalcFields = {...
            'b_value_1','Mc_value1','stan1','a_value1','probability','count_1',...
            'b_value_2','Mc_value2', 'stan2','a_value2','probability2','count_2'};
        
        References="";
        % [bv magco stan av pr no1 bv2 magco2 stan2 av2 pr2 no2] % changed to return relevent properies
        %{
        ReturnDetailsOld = {... VariableNames, VariableDescriptions, VariableUnits
            
            'b_value_1', 'Mcomp b-value I', '';...1 bv > valueMap [discarded later]
            'Mc_value', 'Magnitude of Completion (Mc)', '';...2 magco > old1
            'x', 'Longitude', 'deg';... 3 x
            'y', 'Latitude', 'deg';... 4 y
            'Number_of_Events', 'Number of events in node', ''...5 b.Count > r [INCORRECT]
            'b_value_2', 'b-value II', '';...6 bv2 > meg
            'probability', 'Probability','';...7 pr > pro
            'a_value', 'a-value', '';... 8 av > avm
            'stan','error in b','';...9 stan > stanm
            'maxmag','maximum magnitude','mag';... 10 max(b.Magnitude) or maxm > Mmax
            'delta_bv','difference in b-values',''; ... 11 bv-bv2 > -db12 (negative? why?)
            'probability', 'probability again. same one.','';...12 pr
            'dbperc','b-value change','pct'...13 bv2/bv*100-100 
            
           % bv magco x y b.Count bv2 pr av stan  max(b.Magnitude) bv-bv2  pr bv2/bv*100-100
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';...
            'dM','Difference from Mc','mag';...maxm-magco
            'd_b','Difference in b','';... old - meg
            'Number_of_Events', 'Number of events in node', ''...
            };
        %}
    end
    
    methods
        function obj=bcrossVt2(catalog, varargin)
            obj@ZmapVGridFunction(zap, 'd_b');
            
            obj.NodeMinEventCount = 100;
            
            report_this_filefun();
            unimplemented_error()
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        function InteractiveSetup(obj)
            report_this_filefun();
            %ZG=ZmapGlobal.Data;
            
            sdlg.prompt='T1 = '; sdlg.value=obj.t1;
            sdlg(2).prompt='T2 = '; sdlg(2).value=obj.t2;
            sdlg(3).prompt='T3 = '; sdlg(3).value=obj.t3;
            sdlg(4).prompt='T4 = '; sdlg(4).value=obj.t4;
            sdlg(5).prompt='NodeMinEventCount'; sdlg(5).value=obj.NodeMinEventCount;
            [~,~,obj.t1,obj.t2,obj.t3,obj.t4,obj.NodeMinEventCount]=smart_inputdlg('differential b-value map', sdlg);
            
            
            %% make the interface
            zdlg = ZmapDialog();
            %zdlg = ZmapDialog(obj, @obj.doIt);
            
            zdlg.AddHeader('Automatically estimate magnitude of completeness?');
            zdlg.AddMcAutoEstimateCheckbox('mcAuto', obj.mcAuto);
            zdlg.AddCheckbox('wtAuto', 'AUTOMATIC Least Squares Weighting', obj.wtAuto,...
                'Choose the calculation weighting method for Mc');
            zdlg.AddGridSpacing('gridOpts',obj.dx,'km',[],'',obj.dd,'km');
            obj.AddDialogOption(zdlg,'EventSelector');
            obj.AddDialogOption(zdlg,'NodeMinEventCount');
            
            
            [res,okPressed] = zdlg.Create('Name', 'differential b-value map X-section Grid Parameters');
            
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res)
            obj.doIt();
        end
        
        function SetValuesFromDialog(obj,res)
            % called when the dialog's OK button is pressed
            obj.mcAuto = res.mcAuto; % MC Calculation using Max Likelihood automatic  Mcomp 
            obj.wtAuto = res.wtAuto; % 1 is automatic LSW, 2 is  not automatic
            obj.dx=res.gridOpts.dx;
            obj.dd=res.gridOpts.dz;
            obj.ni = res.eventSelector.NumClosestEvents;
            obj.ra = res.eventSelector.RadiusKm;
            obj.NodeMinEventCount = res.eventSelector.requiredNumEvents;
        end

        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % the seismicity and selectiong the ni neighbors
        % to each grid point
        
        function results = Calculate(obj)
            %{
        figure(xsec_fig());
        set(gca,'NextPlot','add')
        
        ax=findobj(gcf,'Tag','mainmap_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        plos2 = plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        
        %create a rectangular grid
        xvect=[min(x):dx:max(x)];
        yvect=[min(y):dd:max(y)];
        gx = xvect;gy = yvect;
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        n=0;
        for i=1:length(xvect)
            for j=1:length(yvect)
                n=n+1;
                tmpgri(n,:)=[xvect(i) yvect(j)];
            end
        end
        %extract all gridpoints in chosen polygon
        XI=tmpgri(:,1);
        YI=tmpgri(:,2);
        
        ll = polygon_filter(x,y, XI, YI, 'inside');
        %grid points in polygon
        newgri=tmpgri(ll,:);
        
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        itotal = length(newgri(:,1));
        
            %}
            
            %  make grid, calculate start- endtime etc.  ...
            %
            n = obj.RawCatalog.Count;
            
            % set mainshock magnitude to  ZG.CatalogOpts.BigEvents.MinMag
            % f = find(newa(:,6) == max(newa(:,6)))
            % newa(f,6) = min(newa(:,6));
            
            
            % overall b-value
            bv =  bvalca3(obj.RawCatalog.Magnitude, obj.mcAuto);
            b_value_overall = bv;
            obj.ZG.overall_b_value = bv;
            %
            
            returnFields = obj.ReturnDetails.Names;
            returnDesc = obj.ReturnDetails.Descriptions;
            returnUnits = obj.ReturnDetails.Units;
            
            [bvg,nEvents,maxDists,maxMag, ll]=gridfun(@calculation_function,obj.RawCatalog,obj.Grid, obj.EventSelector, numel(returnFields));
            
            
            bvg(:,strcmp('delta_bval',returnFields))=bvg(:,strcmp('b_value_2',returnFields)) - bvg(:,strcmp('b_value_1',returnFields));
            
            bvg(:,strcmp('dM',returnFields))=bvg(:,strcmp('Mc_value2',returnFields)) - bvg(:,strcmp('Mc_value_1',returnFields));
            
            bvg(:,strcmp('dbperc',returnFields))=bvg(:,strcmp('b_value_2',returnFields))/bvg(:,strcmp('b_value_1',returnFields)) .* 100 - 100;
            
            bvg(:,strcmp('x',returnFields))=obj.Grid.X(:);
            bvg(:,strcmp('y',returnFields))=obj.Grid.Y(:);
            bvg(:,strcmp('z',returnFields))=obj.Grid.Z(:);
            bvg(:,strcmp('Number_of_Events',returnFields))=nEvents;
            bvg(:,strcmp('Radius_km',returnFields))=maxDists;
            bvg(:,strcmp('max_mag',returnFields))=maxMag;
            
            
            myvalues = array2table(bvg,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            %kll = ll;
            obj.Result.values=myvalues;
            if nargout
                results=myvalues;
            end
            
            %{
            % reshape a few matrices
            %
            normlap2=nan(length(tmpgri(:,1)),1)
            normlap2(ll)= bvg(:,1);
            valueMap=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,2);
            old1 =reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,5);
            r =reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,6);
            meg=reshape(normlap2,length(yvect),length(xvect));
            
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
            db12 = -db12;
            
            normlap2(ll)= bvg(:,13);
            dbperc=reshape(normlap2,length(yvect),length(xvect));
            
            
            valueMap = db12;
            old = valueMap;
            %}
            % View the b-value map
            %  TODO: PLOTTING SHOULD BE HANDLED BY THE ZMAPGRIDFUNCTION class
            view_bvt([],valueMap)
            
            function out=calculation_function(catalog)
                % The guts of calculating at an individual point goes here
                
                %{
                x = catalog(i,1);y = catalog(i,2);
                allcount = allcount + 1.;
                i2 = i2+1;
                
                % calculate distance from center point and sort wrt distance
                l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
                %[s,is] = sort(l);
                %catalog = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
                
                % take first ni points
                l = l <= ra;
                catalog = newa.subset(l);      % new data per grid point (catalog) is sorted in distance
                %}

                if catalog.Count >= obj.NodeMinEventCount
                    minForTimeslice = obj.NodeMinEventCount/2;
                    % call the catalog-value function
                    
                    % this was [apparently] sloppy, output values migth be result of one or the other
                    % catalog piece, depending on the number of events.
                    lt =  catalog.Date >= obj.t1 &  catalog.Date < obj.t2;
                    count1 = sum(lt);
                    bv = NaN; pr = 50; no1=0;stan1=NaN;av=NaN; pr=NaN; magco=NaN;
                    if  count1 > minForTimeslice
                        [bv, magco, stan, av, pr] =  bvalca3(catalog.Magnitude(lt),obj.mcAuto, b_value_overall);
                        obj.ZG.overall_b_value = bv;
                        no1 = count1;
                    end
                    
                    lt = catalog.Date >= obj.t3 &  catalog.Date < obj.t4 ;
                    count2 = sum(lt);
                    bv2 = NaN; pr2=50; no2=0; stan2=NaN; av2=NaN; pr2=NaN; magco2=NaN;
                    if  count2 > minForTimeslice
                        [bv2, magco2, stan2, av2, pr2] =  bvalca3(catalog.Magnitude(lt),obj.mcAuto, b_value_overall);
                        no2=count2;
                    end
                    
                    if pr2 >= 99 % don't know what [specifically] this is accomplishing.
                        out = [bv magco stan av pr no1 bv2 magco2 stan2 av2 pr2 no2]; % changed to return relevent properies
                        %out = [bv magco x y catalog.Count bv2 pr av stan  max(catalog.Magnitude) bv-bv2  pr bv2/bv*100-100];
                    else
                        out = [0 NaN(1,11)];
                        %out = [0 NaN x y NaN NaN NaN NaN NaN  NaN 0 NaN NaN];
                    end
                else
                    out = NaN(1,12);
                    %out = [NaN NaN x y NaN NaN NaN NaN NaN  NaN 0 NaN NaN];
                end
            end
        end
        
        function ModifyGlobals(obj)
            % if something is changed that goes back to ZG, do it here
            obj.ZG.bvg=obj.Result.values;
        end
        
        % Load exist b-grid
        function my_load()
            load_existing_bgrid_version_A
        end
    end
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label='differential b-value [xsec]';
            h = uimenu(parent, 'Label', label,...
                MenuSelectedField(), @(~,~)XZfun.bcrossVt2(zapFcn()),...
                varargin{:});
        end
        
    end % static method
        
end

