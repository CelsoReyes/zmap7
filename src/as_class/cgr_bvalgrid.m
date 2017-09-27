classdef cgr_bvalgrid < ZmapFunction
    % description of this function
    %
    %
    % in the function that generates the figure where this function can be called:
    %
    %     % create some menu items...
    %     h=cgr_bvalgrid.MenuItem(hMenu, ax) %c reate subordinate to menu item with handle hMenu
    %     % create the rest of the menu items...
    %
    %  once the menu item is clicked, then cgr_bvalgrid.interative_setup(true,true) is called
    %  meaning that the user will be provided with a dialog to set up the parameters,
    %  and the results will be automatically calculated & plotted once they hit the "GO" button
    %
    %
    
    properties
        OperatingCatalog={'primeCatalog'}; % name of catalog containing raw data. eg. 'a', 'newt2', etc.
        ModifiedCatalog='newt2'; %name of catalog changed by this function
        
        dx = 1.00;
        dy = 1.00 ;
        ni = 100;
        ra = ZmapGlobal.Data.ra;
        Nmin = 50;
        fMcFix=2.2;
        nBstSample=100;
        useBootstrap;
        fMccorr = 0.2;
        fBinning = 0.1;
        selOpts=[];
        gridOpts=[];
        bGridEntireArea = false;
        bCreateGrid = true;
        bLoadGrid = false;
        bUseNiEvents= true;
        mc_choice
        mygrid % actual grid[X Y;...], created from gridOpts
        xvect %valid x values for grid
        yvect %valid y values for grid
    end
    
    properties(Constant)
        PlotTag='myplot';
    end
    
    methods
        function obj=cgr_bvalgrid(varargin)
            % create bvalgrid
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            disp('sample.constructor');
            if nargin==0
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                % run this function without human interaction
                
                obj.CheckCatalogPreconditions();
                obj.Calculate();
                obj.plot();
                obj.ModifyGlobals();
            end
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            % if autoCalculate, then do the calculation immediately.
            % if autoPlot, then plot results immediately after calculation
            
            %% make the interface
            zdlg = ZmapFunctionDlg(obj, @obj.doIt);
            
                zdlg.AddBasicHeader('Choose stuff');
                zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',calc_Mc(),1,...
                                    'Choose the calculation method for Mc');
                zdlg.AddGridParameters('gridOpts',obj.dx,'lon',obj.dy,'lon',[],'');
                zdlg.AddEventSelectionParameters('selOpts',obj.ni, obj.ra);
                zdlg.AddBasicCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
                    're takes longer, but provides more accurate results');
                zdlg.AddBasicEdit('nBstSample','Number of bootstraps', obj.nBstSample,...
                    'Number of bootstraps to determine Mc');
                zdlg.AddBasicEdit('Nmin','Min. No. of events > Mc', obj.Nmin,...
                    'Min # events greater than magnitude of completeness (Mc)');
                ... obj.basicEdit('fMcFix', 'Fixed Mc (affects only "Fixed Mc")',obj.fMcFix); %'ToolTipString','fixed magnitude of completeness (Mc)'
                zdlg.AddBasicEdit('fMccorr', 'Mc correction for MaxC',obj.fMccorr,...
                    'Correction term to be added to Mc');
            
            zdlg.Create('b-Value Grid Parameters')
        end
        
        function SetValuesFromDialog(obj)
            % called when the dialog's OK button is pressed
            
            
            obj.Nmin=get(obj.findDlgTag('nmin'),'Value');
            % obj.fMcFix=get(obj.findDlgTag('fmcfix'),'Value');
            obj.nBstSample=get(obj.findDlgTag('nbstsample'),'Value');
            obj.fMccorr=get(obj.findDlgTag('fmccorr'),'Value');
            
            % The following are from the old version
            obj.ZG.inb1=get(obj.findDlgTag('mc_choice'),'Value');
            
            obj.dx=obj.gridOpts.dx;
            obj.dy=obj.gridOpts.dy;
            obj.bGridEntireArea=obj.gridOpts.GridEntireArea;
            obj.bCreateGrid=obj.gridOpts.CreateGrid;
            obj.bLoadGrid=obj.gridOpts.LoadGrid;
            
            obj.bUseNiEvents=obj.selOpts.UseNumNearbyEvents;
            obj.ni=obj.selOpts.ni;
            obj.ra=obj.selOpts.ra;
            
        end
        
        function CheckPreconditions(obj)
            % check to make sure any inportant conditions are met.
            % for example,
            % - catalogs have what are expected.
            % - required variables exist or have valid values
            assert(~isempty(obj.getCat()) , 'Catalog is not empty');
            assert(isa(obj.getCat(),'ZmapCatalog'), 'Catalog is a ZmapCatalog');
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            
            % get the grid-size interactively and
            % calculate the b-value in the grid by sorting
            % thge seimicity and selectiong the ni neighbors
            % to each grid point
            map = findobj('Name','Seismicity Map');
            mycat=obj.getCat();
            
            if obj.gridOpts.CreateGrid
                % Select and create grid
                pause(0.5)
                [obj.mygrid, obj.xvect, obj.yvect, ll] = ex_selectgrid(map, obj.gridOpts.dx, obj.gridOpts.dy, obj.gridOpts.GridEntireArea);
                gx = obj.xvect;
                gy = obj.yvect;
            end
            
            
            if obj.bLoadGrid
                %load file
                
                pause(0.5) %the pause is needed there, because sometimes load was ignored
                [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
                
                if length(path1) > 1
                    
                    my_load([path1 file1])
                end
            end
            
            
            %  make grid, calculate start- endtime etc.  ...
            %
            
            % loop over  all points
            allcount = 0.;
            wai = waitbar(0,' Please Wait ...  ');
            set(wai,'NumberTitle','off','Name','b-value grid - percent done');
            drawnow
            
            % Overall b-value
            bv =  bvalca3(mycat, obj.ZG.inb1); %ignore all the other outputs of bvalca3
            
            itotal = length(obj.mygrid(:,1));
            bvg = nan(itotal,14);
            obj.ZG.bo1 = bv;
            no1 = mycat.Count;
            
            % loop over all points
            for i= 1:length(obj.mygrid(:,1))
                [fMc, fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, fStdDevB, fStdDevMc,prf, nX] = deal(nan);
                x = obj.mygrid(i,1);
                y = obj.mygrid(i,2);
                allcount = allcount + 1.;
                
                if obj.selOpts.useEventsInRadius   % take point within r
                    b = mycat.selectRadius(y,x,obj.selOpts.radius_km);      % new data per grid point (b) is sorted in distanc
                    rd = obj.selOpts.radius_km;
                else
                    [b,rd] = mycat.selectClosestEvents(y,x,[],obj.selOpts.numNearbyEvents);      % new data per grid point (b) is sorted in distance
                end
                
                % Number of earthquakes per node
                nX = b.Count;
                
                % Estimate the completeness and b-value
                obj.ZG.(obj.ModifiedCatalog) = b;
                
                if nX >= obj.Nmin  % enough events?
                    % Added to obtain goodness-of-fit to powerlaw value
                    [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
                    %[~, ~, ~, ~, prf]=mcperc_ca3();
                    
                    [fMc] = calc_Mc(b, obj.ZG.inb1, obj.fBinning, obj.fMccorr);
                    l = b.Magnitude >= fMc-(obj.fBinning/2);
                    if sum(l) >= obj.Nmin
                        [~, fBValue, fStd_B, fAValue] =  calc_bmemag(b.subset(l), obj.fBinning);
                    else
                        [fBValue, fStd_B, fAValue] = deal(nan);
                    end
                    
                    % Bootstrap uncertainties
                    if obj.useBootstrap
                        % Check Mc from original catalog
                        if sum(l) >= obj.Nmin
                            % following line has only b, but maybe should be b.subset(l)
                            [fMc, fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, fStdDevB, fStdDevMc] = calc_McBboot(b, obj.fBinning, obj.nBstSample, obj.ZG.inb1);
                        else
                            fMc = NaN;
                            %fStd_Mc = NaN; fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                        end
                    else
                        % Set standard deviation ofa-value to NaN;
                        fStd_A= NaN; fStd_Mc = NaN;
                    end
                    
                    
                else
                    [fMc, fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, fStdDevB, fStdDevMc,prf, nX] = deal(nan);
                    b = b.subset([]);
                end
                mab = max(b.Magnitude) ;
                if isempty(mab); mab = NaN; end
                
                % Result matrix
                %bvg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan prf  mab av2 fStdDevB fStdDevMc nX];
                bvg(allcount,:)  = [fMc fStd_Mc x y rd fBValue fStd_B fAValue fStd_A prf mab fStdDevB fStdDevMc nX];
                waitbar(allcount/itotal)
            end  % for  obj.mygrid
            
            
            myvalues = array2table(bvg,'VariableNames',...
                {
                'Mc_value', ... mMc, Mc value'p-value',... mPval, p-Value
                'Mc_std', ... mStdMc, Standard deviation Mc
                'x',...
                'y',...
                'Radius_km', ... vRadiusRes,  Radii of chosen events, Resolution
                'b_value',... mBvalue, b-value
                'b_value_std',... mStdB, b-value standard deviation
                'a_value',... mAvalue, a-value
                'a_value_std',... mStdA, a-value standard deviation
                'power_fit', ... Prmap, Goodness of fit to power-law map
                'max_mag', ... ro, maximum magnitude for node
                'Additional_Runs_b_std',... mStdDevB
                'Additional_Runs_Mc_std',... mStdDevMc
                'Number_of_Events'...mNumEq, Number of earthquakes
                });
            
            kll = ll;
            obj.Result.values=myvalues;
            if nargout
                results=myvalues;
            end
            obj.ZG.bvg=myvalues;
        end
        
        function plot(obj,varargin)
            % plots the results on the provided axes.
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f)
            delete(findobj(f,'Type','axes'));
            
            % Plot all grid points
            plot(obj.mygrid(:,1),obj.mygrid(:,2),'+k')
            % plot here
            
        end
        
        function ModifyGlobals(obj)
        end
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent, label)
            % create a menu item
            disp('MenuItem in sample');
            if ~exist('label','var')
                label='Mc, a- and b- value map';
            end
            h=uimenu(parent,'Label',label,...
                'Callback', @(~,~)cgr_bvalgrid);
        end
        
    end % static methods
    
end %classdef

