classdef bcrossVt2 < ZmapGridFunction
    % tHis subroutine assigns creates a grid with
    % spacing dx,dy (in degreees). The size will
    % be selected interactiVELY. The bvalue in each
    % volume around a grid point containing ni earthquakes
    % will be calculated as well as the magnitude
    % of completness
    %   Stefan Wiemer 1/95
    properties
        OperatingCatalog={''};
        ModifiedCatalog='';
        
        ni = 100;
        ra = ZmapGlobal.Data.ra;
        dd = 1.0
        dx = 1.0
        Nmin=100; % minimum number of events
        
        % get the time periods of interest
        t0b = ZmapGlobal.Data.t0b;
        teb = ZmapGlobal.Data.teb;
        t1 = ZmapGlobal.Data.t0b;
        t2 = ZmapGlobal.Data.t0b + mean(ZmapGlobal.Data.t0b, ZmapGlobal.Data.teb);
        
        t3 = ZmapGlobal.Data.t0b + mean(ZmapGlobal.Data.t0b, ZmapGlobal.Data.teb) + seconds(.1);
        t4 = ZmapGlobal.Data.teb;
    end
    
    properties(Constant)
        PlotTag = 'myotherplot'
        ReturnDetails = {... VariableNames, VariableDescriptions, VariableUnits
            'x', 'Longitude', 'deg';...
            'y', 'Latitude', 'deg';...
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';...
            'Number_of_Events', 'Number of events in node', ''...
            };
    end
    
    methods
        function obj=bcrossVt2(varargin)
            % create bcrossVt2 object (or do the calculation)
            obj.plotcolumn='b_value';
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            if nargin==0
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                % run this function without human interaction
                obj.doIt();
                %obj.CheckCatalogPreconditions();
                %obj.Calculate();
                %obj.plot();
                %obj.ModifyGlobals();
            end
        end
        function InteractiveSetup(obj)
            report_this_filefun(mfilename('fullpath'));
            ZG=ZmapGlobal.Data;
            
            sdlg.prompt='T1 = '; sdlg.value=obj.t1;
            sdlg(2).prompt='T2 = '; sdlg(2).value=obj.t2;
            sdlg(3).prompt='T3 = '; sdlg(3).value=obj.t3;
            sdlg(4).prompt='T4 = '; sdlg(4).value=obj.t4;
            sdlg(5).prompt='Nmin'; sdlg(5).value=obj.Nmin;
            [~,~,obj.t1,obj.t2,obj.t3,obj.t4,obj.Nmin]=smart_inputdlg('differential b-value map', sdlg);
            
            % make the interface
            %
            labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
            
            labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
            
            %% make the interface
            zdlg = ZmapDialog();
            %zdlg = ZmapDialog(obj, @obj.doIt);
            
            zdlg.AddBasicHeader('Automatically estimate magnitude of completeness?');
            zdlg.AddBasicPopup('mc_choice', 'Mc method:',labelList,1,...
                'Choose the calculation method for Mc');
            zdlg.AddBasicPopup('mc_weights', 'Weighting:',labelList2,1,...
                'Choose the calculation method for Mc');
            zdlg.AddGridParameters('gridOpts',dx,'km',[],'',dd,'km');
            zdlg.AddEventSelectionParameters('eventSelector',ni, ra,Nmin);
            
            [res,okPressed] = zdlg.Create('differential b-value map X-section Grid Parameters');
            
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res)
            obj.doIt();
        end
        
        function setValuesFromDialog(obj,res)
            % called when the dialog's OK button is pressed
            obj.ZG.inb1=res.mc_choice;
            obj.ZG.inb2=res.mc_weights;
            obj.dx=res.gridOpts.dx;
            obj.dd=res.gridOpts.dz;
            obj.ni = res.eventSelector.numNearbyEvents;
            obj.ra = res.eventSelector.radius_km;
            obj.Nmin = res.eventSelector.requiredNumEvents;
        end
        
        function CheckPreconditions(obj)
        end
        
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % thge seimicity and selectiong the ni neighbors
        % to each grid point
        
        function results = calculate(obj)
            %{
        figure(xsec_fig());
        hold on
        
        ax = mainmap('axes');
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
            [t0b, teb] = newa.DateRange() ;
            n = newa.Count;
            tdiff = round((teb-t0b)/ZG.bin_dur);
            loc = zeros(3, length(gx)*length(gy));
            
            % loop over  all points
            %
            i2 = 0.;
            i1 = 0.;
            bvg = [];
            allcount = 0.;
            wai = waitbar(0,' Please Wait ...  ');
            set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
            drawnow
            %
            % loop
            
            % set mainshock magnitude to  ZG.big_eq_minmag
            % f = find(newa(:,6) == max(newa(:,6)))
            % newa(f,6) = min(newa(:,6));
            
            
            % overall b-value
            [bv magco stan av pr] =  bvalca3(newa.Magnitude,ZG.inb1);
            ZG.bo1 = bv;
            no1 = newa.Count;
            %
            for i= 1:length(newgri(:,1))
                x = newgri(i,1);y = newgri(i,2);
                allcount = allcount + 1.;
                i2 = i2+1;
                
                % calculate distance from center point and sort wrt distance
                l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
                %[s,is] = sort(l);
                %b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
                
                % take first ni points
                l = l <= ra;
                b = newa.subset(l);      % new data per grid point (b) is sorted in distance
                
                if isempty(b); b = newa.subset(1); end
                if b.Count >= Nmin;
                    % call the b-value function
                    lt =  b.Date >= t1 &  b.Date <t2 ;
                    if  length(b(lt,1)) > Nmin/2;
                        [bv magco stan av pr] =  bvalca3(b.Magnitude(lt),ZG.inb1);
                        ZG.bo1 = bv;
                        no1 = newa.Count;
                    else
                        bv = NaN; pr = 50;
                    end
                    lt = b.Date >= t3 &  b.Date < t4 ;
                    if  length(b(lt,1)) > Nmin/2;
                        [bv2 magco stan av pr] =  bvalca3(b.Magnitude(lt),ZG.inb1);
                    else
                        bv2 = NaN; pr = 50;
                    end
                    
                    if pr >=99
                        bvg = [bvg ; bv magco x y b.Count bv2 pr av stan  max(b.Magnitude) bv-bv2  pr bv2/bv*100-100];
                    else
                        bvg = [bvg ; 0 NaN x y NaN NaN NaN NaN NaN  NaN 0 NaN NaN];
                    end
                else
                    bvg = [bvg ; NaN NaN x y NaN NaN NaN NaN NaN  NaN 0 NaN NaN];
                end
                waitbar(allcount/itotal)
            end  % for  newgri
            
            % save data
            %
            %  set(txt1,'String', 'Saving data...')
            drawnow
            gx = xvect;gy = yvect;
            
            catsave3('bcrossVt2');
            %corrected window postioning error
            close(wai)
            watchoff
            
            % reshape a few matrices
            %
            normlap2=nan(length(tmpgri(:,1)),1)
            normlap2(ll)= bvg(:,1);
            valueMap=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,5);
            r=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,6);
            meg=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,2);
            old1 =reshape(normlap2,length(yvect),length(xvect));
            
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
            
            % View the b-value map
            %  TODO: PLOTTING SHOULD BE HANDLED BY THE ZMAPGRIDFUNCTION class
            view_bvt([],valueMap)
            
            function out=calculation_function(catalog)
                % The guts of calcualting at an individual point goes here
            end
        end
        
        function ModifyGlobals(obj)
            % if something is changed that goes back to ZG, do it here
        end
        
        % Load exist b-grid
        function my_load()
            load_existing_bgrid_version_A
        end
    end
    methods(Static)
        function h=AddMenuItem(parent, label)
            % create a menu item
            if ~exist('label','var')
                label='differential b';
            end
            h=uimenu(parent,'Label',label,'Callback', @(~,~)bcrossVt2);
        end
        
    end % static method
        
end

