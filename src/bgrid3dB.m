classdef bgrid3dB < ZmapGridFunction
    % This subroutine assigns creates a 3D grid with
    % spacing dx,dy, dz (in degreees). The size will
    % be selected interactiVELY. The pvalue in each
    % volume around a grid point containing ni earthquakes
    % will be calculated as well as the magnitude
    % of completness
    %   Stefan Wiemer 1/98
    % turned into function by Celso G Reyes 2017
    
    properties
        OperatingCatalog={'primeCatalog'};
        ModifiedCatalog='newt2';
        
        R = 5;
        ni = ZG.ni;
        Nmin = 50;
        mc_choice
    end
    
    properties(Constant)
        PlotTag='myplot';
        ReturnDetails = { ... VariableNames, VariableDescriptions, VariableUnits  [bv2 bv rd prf av av2 magco stan stan2];
            'bv2','bv2: b-value from bmemmag', '';...bv2 (?) b-value from bmemag() ->bvg
            'b_value', 'b-value', '';... bv ->bvg_wls
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';... rd ->ram
            'power_fit', 'Goodness of fit to power-law', '';... prf
            'a_value', 'a-value', '';... av
            'av2','av2: a-value from bmemmag', '';...av2 (?) a-value from bmemag() ->avm
            'Mc_value', 'Magnitude of Completion (Mc)', '';... magco ->mcma
            'b_value_std', 'Std. of b-value', '';...stan
            'stan2','stan2: b-value std from bmemag','';... stan2 (?) bvalue std from bmemag()
            ...'Mc_std', 'Std. of Magnitude of Completion', '';...
            ...'a_value_std', 'Std. of a-value', '';...
            ...'Additional_Runs_b_std', 'Additional runs: Std b-value', '';...
            ...'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', '';...
            'max_mag', 'Maximum magnitude at node', 'mag';...
            'Number_of_Events', 'Number of events in node', '';...
            'x', 'Longitude', 'deg';...
            'y', 'Latitude', 'deg';...
            'z', 'Depth', 'km'...
            ... av2 (?) a-value from bmemag() ->avm
            ... bv2 (?) b-value from bmemag() ->bvg
            };
    end
    methods
        function obj=bgrid3dB()
            ZG=ZmapGlobal.Data; % used by get_zmap_globals
            
            report_this_filefun(mfilename('fullpath'));
            
            useRadius=false;
            
            
            labelList2={'Automatic Mcomp (max curvature)' ;...
                'Fixed Mc (Mc = Mmin)' ; ...
                'Automatic Mcomp (90% probability)' ;...
                'Automatic Mcomp (95% probability)' ;...
                'Best (?) combination (Mc95 - Mc90 - max curvature)'};
            
            zdlg=ZmapFunctionDlg(); %h, okevent
            zdlg.AddBasicHeader('Grid Input Parameters');
            zdlg.AddBasicPopup('mc_choice','Mc Estimation Option:',labelList2,5,'Magnitude of completion option')
            zdlg.AddEventSelectionParameters('evsel',ni,R,50);
            zdlg.AddGridParameters('gridopt',.1,'deg',.1,'deg',5,'km')
            zdlg.AddBasicEdit('minz','Shallowest Boundary [km]',min(ZG.primeCatalog.Depth),'Shallowest boundary');
            zdlg.AddBasicEdit('maxz','Deepest Boundary [km]',max(ZG.primeCatalog.Depth),'Deepest boundary');
            [res, pressedOk]=zdlg.Create('b-value 3D Grid');
            if ~pressedOk
                return
            end
            obj.mc_choice=res.mc_choice;
            ZG.inb2=res.mc_choice;
            ZG.inb1=res.mc_choice;
            obj.ni=res.evsel.numNearbyEvents;
            obj.R=res.evsel.radius_km;
            useRadius=res.evsel.useEventsInRadius;
            dx=res.gridopt.dx;
            dy=res.gridopt.dy;
            dz=res.gridopt.dz;
            z1=res.minz;
            z2=res.maxz;
            
            obj.Calculate();
            
        end
        
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % thge seimicity and selectiong the ni neighbors
        % to each grid point
        
        function results=Calculate(obj)
            zg3=ZmapGrid3('bgid3dBGrid',res.gridopt,[res.minz res.maxz]); % create 3d grid
            vol_dimensions=zg3.mesh_size();
            %[t5, gx, gy, gz]=selgp3dB(dx, dy, dz, z1, z2);
            
            %vol_dimensions=[length(gx), length(gy), length(gz)];
            
            
            %  make grid, calculate start- endtime etc.  ...
            %
            [bvg, bvg_wls, ram, go, avm, mcma] = deal(nan(vol_dimensions));
            
            [t0b, teb] = ZG.primeCatalog.DateRange() ;
            n = ZG.primeCatalog.Count;
            tdiff = round((teb-t0b)/ZG.bin_dur);
            loc = zeros(3, length(gx)*length(gy));
            ZG.Rconst = R;
            % loop over  all points
            %
            i2 = 0.;
            i1 = 0.;
            allcount = 0.;
            %
            %
            
            z0 = 0; x0 = 0; y0 = 0; dt = 1;
            % loop over all points
            [bvg,nEvents,maxDists,maxMag, ll]= gridfun(@calculation_function,ZG.primeCatalog, zg3, res.evsel);
            %modify answer
            bvg(:,strcmp('x',returnFields))=obj.Grid.X;
            bvg(:,strcmp('y',returnFields))=obj.Grid.Y;
            bvg(:,strcmp('Number_of_Events',returnFields))=nEvents;
            bvg(:,strcmp('Radius_km',returnFields))=maxDists;
            bvg(:,strcmp('max_mag',returnFields))=maxMag;
              
            myvalues = array2table(bvg,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            kll = ll;
            obj.Result.values=myvalues;
            if nargout
                results=myvalues;
            end
            
            %{
            for il =1:length(zg3)
                
                x = t5(il,1);
                y = t5(il,2);
                z = t5(il,3);
                
                allcount = allcount + 1.;
                
                % calculate distance from center point and sort wrt distance
                l = sqrt(((ZG.primeCatalog.Longitude-x)*cosd(y)*111).^2 + ((ZG.primeCatalog.Latitude-y)*111).^2 + ((ZG.primeCatalog.Depth - z)).^2 ) ;
                [s,is] = sort(l);
                b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
                
                if useRadius  % take point within r
                    l3 = l <= R;
                    b = ZG.primeCatalog.subset(l3);      % new data per grid point (b) is sorted in distanc
                    rd = b.Count;
                else
                    % take first ni points
                    b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                    l2 = sort(l);
                    rd = l2(ni);
                    
                end
                out=calculation_function(b);
            %}
            end
            
            % save data
            %
            gz = -gz;
            zv2 = bvg;
            zvg = bvg;
            
            catsave3('bgrid3dB');
            
            watchoff
            
            sel = 'no';
            
            ButtonName=questdlg('Which viewer would you like to use?', ...
                'Question', ...
                'Slicer - map view','Slicer - 3D ','Help','none');
            
            
            switch ButtonName
                case 'Slicer - map view'
                    slicemap();
                case 'Slicer - 3D '
                    myslicer();
                case 'Help'
                    showweb('3dbgrids')
            end % switch
            
            uicontrol('Units','normal',...
                'Position',[.90 .95 .04 .04],'String','Slicer',...
                'callback',@callbackfun_010);
            
            
            function out=calculation_function(catalog)
                % calculate values at a single point
                
                %estimate the completeness and b-value
                %1: 'Automatic Mcomp (max curvature)'
                %2: 'Fixed Mc (Mc = Mmin)'
                %3: 'Automatic Mcomp (90% probability)'.
                %4: 'Automatic Mcomp (95% probability)'
                %5: 'Best (?) combination (Mc95 - Mc90 - max curvature)'
                
                [bv, bv2, magco, av, av2] = deal(nan);
                %dP=0; %from case 5
                switch obj.mc_choice
                    
                    case 3 % Automatic Mcomp (90% probability)
                        [~, Mc90, ~, ~, prf]=mcperc_ca3();
                        l = catalog.Magnitude >= Mc90-0.05;
                        if sum(l) >= Nmin
                            minicat=catalog.subset(l);
                            magco = Mc90;
                            [bv magco0 stan av pr] =  bvalca3(minicat,2);
                            [bv2 stan2 av2 ] =  bmemag(minicat);
                        end
                        
                    case 4 % Automatic Mcomp (95% probability)
                        [~, ~, Mc95, ~, prf]=mcperc_ca3();
                        l = catalog.Magnitude >= Mc95-0.05;
                        if sum(l) >= Nmin
                            minicat=catalog.subset(l);
                            magco = Mc95;
                            [bv, magco0, stan, av,   pr] =  bvalca3(minicat,2);
                            [bv2, stan2, av2 ] =  bmemag(minicat);
                        end
                        
                    case 5% Best (?) combination (Mc95 - Mc90 - max curvature)
                        [~, Mc90, Mc95, ~, prf]=mcperc_ca3();
                        if ~isnan(Mc95)
                            magco = Mc95;
                        elseif ~isnan(Mc90)
                            magco = Mc90;
                        else
                            [~, magco, ~, ~, ~, ~, ~,  ~] =  bvalca3(catalog,1);
                        end
                        l = catalog.Magnitude >= magco-0.05;
                        if sum(l) >= Nmin
                            minicat=catalog.subset(l);
                            [bv, magco0, stan, av, pr] =  bvalca3(minicat,2);
                            [bv2, stan2,  av2] =  bmemag(minicat);
                        else
                            [bv, bv2, magco, av, av2] = deal(nan);
                        end
                        
                    case 1 % Automatic Mcomp (max curvature)
                        [bv magco, stan, av,   pr] =  bvalca3(catalog,1);
                        l = catalog.Magnitude >= magco-0.05;
                        if  sum(l) >= Nmin
                            [bv2 stan2,  av2] =  bmemag(catalog.subset(l));
                        else
                            bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                        end
                        
                    case 2 % Fixed Mc (Mc = Mmin)
                        [bv, magco, stan, av,   pr] =  bvalca3(catalog,2);
                        [bv2, stan2, av2 ] =  bmemag(catalog);
                        
                    otherwise
                        error('unanticipated choice')
                end

                %  predi_ca
                bvg(t5(il,5),t5(il,6),t5(il,7)) = bv2;
                bvg_wls(t5(il,5),t5(il,6),t5(il,7)) = bv;
                
                ram(t5(il,5),t5(il,6),t5(il,7)) = rd;
                %go(t5(il,5),t5(il,6),t5(il,7)) = prf;
                avm(t5(il,5),t5(il,6),t5(il,7)) = av2;
                mcma(t5(il,5),t5(il,6),t5(il,7)) = magco;
                out=[bv2 bv rd prf av av2 magco stan stan2];
            end
        end
        
        function callbackfun_010(mysrc,myevt)
            callback_tracker(mysrc,myevt,mfilename('fullpath'));
        end
        
    end
end

