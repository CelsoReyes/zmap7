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
        
        dx = .2 %1.00;
        dy = .5 % 1.00 ;
        ni = 100;
        ra = ZmapGlobal.Data.ra;
        Nmin = 50;
        fMcFix=1.0; %2.2
        nBstSample=100;
        useBootstrap; % perform bootstrapping?
        fMccorr = 0.2; % magnitude correction
        fBinning = 0.1; % magnitude bins
        EventSelector;
        gridOpts;
        %bUseNiEvents= true;
        mc_choice
        Grid % actual grid[X Y;...], created from gridOpts
        %xvect %valid x values for grid
        %yvect %valid y values for grid
    end
    
    properties(Constant)
        PlotTag='myplot';
        ReturnFields = {
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
                };
    end
    
    methods
        function obj=cgr_bvalgrid(varargin)
            % create bvalgrid
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
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
            zdlg = ZmapFunctionDlg();
            %zdlg = ZmapFunctionDlg(obj, @obj.doIt);
            
                zdlg.AddBasicHeader('Choose stuff');
                zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',calc_Mc(),1,...
                                    'Choose the calculation method for Mc');
                zdlg.AddGridParameters('gridOpts',obj.dx,'lon',obj.dy,'lon',[],'');
                zdlg.AddEventSelectionParameters('EventSelector',[], obj.ra,obj.Nmin);
                zdlg.AddBasicCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
                    're takes longer, but provides more accurate results');
                zdlg.AddBasicEdit('nBstSample','Number of bootstraps', obj.nBstSample,...
                    'Number of bootstraps to determine Mc');
                zdlg.AddBasicEdit('Nmin','Min. No. of events > Mc', obj.Nmin,...
                    'Min # events greater than magnitude of completeness (Mc)');
                ... obj.basicEdit('fMcFix', 'Fixed Mc (affects only "Fixed Mc")',obj.fMcFix); %'ToolTipString','fixed magnitude of completeness (Mc)'
                zdlg.AddBasicEdit('fMccorr', 'Mc correction for MaxC',obj.fMccorr,...
                    'Correction term to be added to Mc');
            
            [res,okPressed] = zdlg.Create('b-Value Grid Parameters');
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            % called when the dialog's OK button is pressed
            
            obj.Nmin=res.Nmin;
            obj.nBstSample=res.nBstSample;
            obj.fMccorr=res.fMccorr;
            obj.ZG.inb1=res.mc_choice;
            obj.EventSelector=res.EventSelector;
            obj.gridOpts=res.gridOpts;
            obj.useBootstrap=res.useBootstrap;
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
                obj.Grid = ZmapGrid('bvalgrid',obj.gridOpts);
            end
            
            % Overall b-value
            bv =  bvalca3(mycat, obj.ZG.inb1); %ignore all the other outputs of bvalca3
            
            %itotal = length(obj.Grid(:,1));
            %bvg = nan(itotal,14);
            obj.ZG.bo1 = bv;
            % no1 = mycat.Count;
            
            
            [bvg,nEvents,maxDists,maxMag, ll]=gridfun(@calculation_function,mycat,obj.Grid, obj.EventSelector, numel(obj.ReturnFields));
            bvg(:,strcmp('x',obj.ReturnFields))=obj.Grid.X;
            bvg(:,strcmp('y',obj.ReturnFields))=obj.Grid.Y;
            bvg(:,strcmp('Number_of_Events',obj.ReturnFields))=nEvents;
            bvg(:,strcmp('Radius_km',obj.ReturnFields))=maxDists;
            bvg(:,strcmp('max_mag',obj.ReturnFields))=maxMag;
            % adjust to match expectations
            
            
            myvalues = array2table(bvg,'VariableNames', obj.ReturnFields);
            
            kll = ll;
            obj.Result.values=myvalues;
            if nargout
                results=myvalues;
            end
            
             function out=calculation_function(catalog)
                % calulate values at a single point

                % Added to obtain goodness-of-fit to powerlaw value
                % [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
                [~, ~, ~, ~, prf]=mcperc_ca3(catalog);
                
                [Mc_value] = calc_Mc(catalog, obj.ZG.inb1, obj.fBinning, obj.fMccorr);
                l = catalog.Magnitude >= Mc_value-(obj.fBinning/2);
                
                if sum(l) >= obj.Nmin
                    [b_value, b_value_std, a_value] =  calc_bmemag(catalog.subset(l), obj.fBinning);
                    % otherwise, they should be NaN
                else
                    [b_value, b_value_std, a_value] = deal(nan);
                end
                
                % Bootstrap uncertainties FOR EACH CELL
                if obj.useBootstrap
                    % Check Mc from original catalog
                    if sum(l) >= obj.Nmin
                        % following line has only b, but maybe should be catalog.subset(l)
                        [Mc_value, Mc_std, ...
                            b_value, b_value_std, ...
                            a_value, a_value_std, ...
                            Additional_Runs_b_std, Additional_Runs_Mc_std] = ...
                            calc_McBboot(catalog, obj.fBinning, obj.nBstSample, obj.ZG.inb1);
                    else
                        Mc_value = NaN;
                        %fStd_Mc = NaN; fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                    end
                else
                    % Set standard deviation ofa-value to NaN;
                    a_value_std= NaN; 
                    Mc_std = NaN;
                    Additional_Runs_b_std=NaN;
                    Additional_Runs_Mc_std=NaN;
                end

                mab = max(catalog.Magnitude) ;
                if isempty(mab); mab = NaN; end

                % Result matrix
                out  = [Mc_value Mc_std nan nan, ... nan's were x and y
                    nan b_value b_value_std a_value a_value_std,... was rd
                    prf mab Additional_Runs_b_std Additional_Runs_Mc_std nan]; % nan was nX
            
            end
        end
        
        function plot(obj,varargin)
            % plots the results on the provided axes.
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f)
            set(f,'name','B-values')
            delete(findobj(f,'Type','axes'));
            
            obj.Grid.pcolor([],obj.Result.values.b_value,'B-values');
            shading(obj.ZG.shading_style)
            hold on
            obj.Grid.plot()
            ft=obj.ZG.features('borders');
            newft=copyobj(ft,gca)
            %ft.plot(gca);
            colorbar
            title('B-values')
            xlabel('Longitude')
            ylabel('Latitude')
            
            %TODO add shading menu
            %TODO add plotAnyValue menu that 
            
           % plot here
            
        end
        
        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
            obj.ZG.Grid = obj.Grid;
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

