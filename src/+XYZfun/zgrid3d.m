classdef zgrid3d < Zmap3DGridFunction
    % calcultes something over 3d space
    properties
    end
    
    properties(Constant)
        PlotTag='zgrid3d';
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'name','longer description','units';...
            'name2','longer description2','units2'...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        
        % fields returned by the calculation. must match column 1 of ReturnDetails
        CalcFields = {} % cell of charstrings
        
        ParameterableProperties = []; %array of strings
    end
    
    methods
        function obj=zgrid3d(zap, varargin)
            % ZGRID3D
            % obj = ZGRID3D() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = ZGRID3D(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@Zmap3DGridFunction(zap, 'z_value');
            
            report_this_filefun();
            unimplemented_error()
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            zdlg.AddHeader('Choose stuff');
            zdlg.Create('Name', '3D Z-Value Parameters','WriteToObj',obj,'OkFcn',@obj.doIt);
        end
        
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the values in the grid by sorting the
            % seismicity and selecting the appropriate neighbors to each grid point
            
            
            function out=calculation_function(catalog)
                % calulate values at a single point
            end
        end
        
        function ModifyGlobals(obj)
        end
    end
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='3D  z-value distribution';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.zgrid3d(zapFcn()));
        end
    end % static methods
    
end

function zgrid3d_orig(sel,catalog) 
    % This subroutine assigns creates a 3D grid with
    % spacing dx,dy, dz (in degreees). The size will
    % be selected interactiVELY. The pvalue in each
    % volume around a grid point containing ni earthquakes
    % will be calculated as well as the magnitude
    % of completness
    %   Stefan Wiemer 1/98
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    if ~exist('catalog')
        catalog=ZG.primeCatalog;
    end
    
    if ~exist('sel','var') || sel == 'in'
        % get the grid parameter
        % initial values
        [dx,dy,dz,z1,z2] = request_3dgrid_params('Three dimesional z-value analysis');
        ni = 300;
        R = 10000;
        zgrid3d_orig('ca')
        
        
    end
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selectiong the ni neighbors
    % to each grid point
    
    if sel == 'ca'
        
        [t5, gx, gy, gz]=selgp3dB(dx, dy, dz, z1, z2);
        
        vol_dimensions=[length(gx), length(gy), length(gz), 300];
        
        itotal = length(t5);
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [zvg, ram] = deal(nan(vol_dimensions));
        [t0b, teb] = catalog.DateRange() ;
        n = catalog.Count;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name',' 3D gridding - percent done');
        drawnow
        %
        %
        
        
        z0 = 0; x0 = 0; y0 = 0; dt = 1;
        % loop over all points
        for il =1:length(t5)
            
            x = t5(il,1);
            y = t5(il,2);
            z = t5(il,3);
            allcount = allcount + 1.;
            i2 = i2+1;
            
            % calculate distance from center point and sort wrt distance
            di = sqrt(((catalog.Longitude-x)*cosd(y)*111).^2 + ((catalog.Latitude-y)*111).^2 + ((catalog.Depth - z)).^2 ) ;
            [s,is] = sort(di);
            
            l2 = find(is <= 300);
            
            zvg(t5(il,5),t5(il,6),t5(il,7),:) = is(1:300);
            ram(t5(il,5),t5(il,6),t5(il,7),:) = di(is(1:300));
            if rem(allcount,20) == 0
                waitbar(allcount/itotal) ;
            end
        end  % for xt5
        % save data
        %
        try
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ;
            if length(file1) > 1
                save([path1 file1], 'zvg', 'ram', 'gx', 'gy', 'gz', 'dx', 'dy', 'dz',...
                    'ZG', 'tdiff', 't0b', 'teb', 'a', 'main', 'faults', 'mainfault',...
                    'coastline', 'yvect', 'xvect', 'tmpgri', 'll'); %FIXME savevariables
                
            end
        catch ME
            warning(ME)
        end
        
        
        close(wai)
        watchoff
        
        gz = -gz;
        zv2 = zvg;
        sel = 'no';
        tdiff = teb-t0b;
        
        lta_winy = tdiff/5;
        zv4 = zv2;
        tiz = 10;
        slicemapz();
        
    end  % if cal
    
    
end
