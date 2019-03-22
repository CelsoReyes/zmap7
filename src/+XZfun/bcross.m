classdef bcross < ZmapVGridFunction
    % BCROSS calculate b-values along a cross section
    properties
        mc_auto         McAutoEstimate
        mc_choice       McMethods
        
    end
    
    properties(Constant)
        PlotTag         = 'bcross'
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'magComp',  'Mc map', '';...
            'McStdDev', 'Standard deviation Mc', '';...
            'b_value',  'b-value', '';...
            'mStdB',    'Standard deviation b-value', '';...
            'a_value',  'a-value M(0)', '';...
            'mStdA',    'Standard deviation a-value', '';...
            'fitToPowerlaw', 'Goodness of fit to power-law map', '';...
            'ro',       'Whatever this is', '';...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {'magComp','McStdDev','b_value','mStdB','a_value','mStdA','fitToPowerlaw','ro'} % cell array of charstrings, matching into ReturnDetails.Names
        
        ParameterableProperties = []; % array of strings matching into obj.Properties
        References="";
    end
    
    methods
        function obj=bcross(zap, varargin)
            % BCROSS
            % obj = BCROSS() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CBCROSS(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapVGridFunction(zap, 'b_value');
            
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
            
            
            zdlg.AddMcMethodDropdown('mc_choice');
            zdlg.AddGridSpacing('gridOpts',dx,'km',[],'',dd,'km');
            obj.AddDialogOption(zdlg,'EventSelector');
            
            zdlg.AddEdit('fBinning','Magnitude binning', fBinning,...
                'Bins for magnitudes');
            obj.AddDialogOption(zdlg, 'NodeMinEventCount');
            zdlg.AddEdit('fMcFix', 'Fixed Mc',fMcFix,...
                'fixed magnitude of completeness (Mc)');
            zdlg.AddEdit('fMccorr', 'Mc correction factor',fMccorr,...
                'Correction term to be added to Mc');
            zdlg.AddCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
                're takes longer, but provides more accurate results');
            zdlg.AddEdit('nBstSample','Number of bootstraps', nBstSample,...
                'Number of bootstraps to determine Mc');
            
            
            [res,okPressed] = zdlg.Create('Name', 'B-Value Parameters [xsec]');
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            % called when the dialog's OK button is pressed
            obj.hndl2=res.mc_choice;
            obj.dx = res.gridOpts.dx;
            obj.dd = res.gridOpts.dz;
            obj.tgl1 = res.eventSelector.UseNumClosestEvents;
            obj.tgl2 = ~tgl1;
            obj.ni = res.eventSelector.NumClosestEvents;
            obj.ra = res.eventSelector.RadiusKm;
            obj.bGridEntireArea = res.gridOpts.GridEntireArea;
            obj.bBst_button = res.useBootstrap;
            obj.nBstSample = res.nBstSample;
            obj.fMccorr = res.fMccorr;
            obj.fBinning = res.fBinning;
            
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the values in the grid by sorting the
            % seismicity and selecting the appropriate neighbors to each grid point
            
            % Select and create grid
            [newgri, xvect, yvect, ll] = ex_selectgrid(xsec_fig(), dx, dd, bGridEntireArea);
            
            % Plot all grid points
            plot(newgri(:,1),newgri(:,2),'+k')
            
            %  make grid, calculate start- endtime etc.  ...
            %
            [t0b, teb] = bounds(newa.Date) ;
            n = newa.Count;
            tdiff = round((teb-t0b)/ZG.bin_dur);
            
            % loop over  all points
            % Set size for output matrix
            bvg = NaN(length(newgri),12);
            allcount = 0.;
            wai = waitbar(0,' Please Wait ...  ');
            set(wai,'NumberTitle','off','Name','b-value grid - percent done');
            drawnow
            itotal = length(newgri(:,1));
            %
            % loop
            %
            for i= 1:length(newgri(:,1))
                x = newgri(i,1);y = newgri(i,2);
                allcount = allcount + 1.;
                
                % calculate distance from center point and sort wrt distance
                l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
                [s,is] = sort(l);
                b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
                
                
                if tgl1 == 0   % take point within r
                    l3 = l <= ra;
                    b = newa.subset(l3);      % new data per grid point (b) is sorted in distanc
                    rd = ra;
                else
                    % take first ni points
                    b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                    rd = s(ni);
                end
                
                % Number of earthquakes per node
                [nX,nY] = size(b);
                
                %estimate the completeness and b-value
                ZG.newt2 = b;
                
                if Nmin <= length(b)
                    % Added to obtain goodness-of-fit to powerlaw value
                    [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                    fMc = calc_Mc(b, obj.mc_choice, fBinning, fMccorr);
                    l = (fMc-(fBinning/2)) <= b.Magnitude;
                    if Nmin <= length(b(l,:))
                        [ fBValue, fStd_B, fAValue] =  calc_bmemag(b(l,:), fBinning);
                    else
                        %fMc = NaN;
                        fBValue = NaN; fStd_B = NaN; fAValue= NaN;
                    end
                    
                    % Bootstrap uncertainties
                    if bBst_button
                        % Check Mc from original catalog
                        l = (fMc-(fBinning/2)) <= b.Magnitude;
                        if Nmin <= length(b(l,:))
                            [fMc, fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, vMc, b_value] = calc_McBboot(b, fBinning, nBstSample, obj.mc_choice);
                        else
                            %fMc = NaN;
                            %fStd_Mc = NaN;
                            fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                        end
                    else
                        % Set standard deviation of a-value to NaN;
                        fStd_A= NaN; fStd_Mc = NaN;
                    end
                    
                else % of if length(b) >= Nmin
                    fMc = NaN; fStd_Mc = NaN; fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A = NaN;
                    %bv = NaN; bv2 = NaN; stan = NaN; stan2 = NaN; prf = NaN; magco = NaN; av = NaN; av2 = NaN;
                    prf = NaN;
                    b = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
                    nX = NaN;
                end
                mab = max(b.Magnitude) ;
                if isempty(mab)
                    mab = NaN;
                end
                
                % Result matrix
                %bvg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan prf  mab av2 fStdDevB fStdDevMc nX];
                bvg(allcount,:)  = [fMc fStd_Mc x y rd fBValue fStd_B fAValue fStd_A prf mab nX];
                waitbar(allcount/itotal)
            end  % for  newgri
            
            drawnow
            gx = xvect;gy = yvect;
            
            catsave3('bcross_orig');
            %corrected window positioning error
            close(wai)
            watchoff
            
            % initialize a few matrices
            [magComp, McStdDev, mRadRes, b_value, mStdB, a_value, mStdA, fitToPowerlaw, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
            % replace the indexed values within
            
            magComp(ll) = bvg(:,1);         % Mc map
            McStdDev(ll) = bvg(:,2);       % Standard deviation Mc
            mRadRes(ll) = bvg(:,5);     % Radius resolution
            b_value(ll) = bvg(:,6);      % b-value
            mStdB(ll) = bvg(:,7);        % Standard deviation b-value
            a_value(ll) = bvg(:,8);      % a-value M(0)
            mStdA(ll) = bvg(:,9);        % Standard deviation a-value
            fitToPowerlaw(ll) = bvg(:,10);       % Goodness of fit to power-law map
            ro(ll) = bvg(:,11);          % Whatever this is
            mNumEq(ll) = bvg(:,12);     % number of events
            
            valueMap = b_value;
            kll = ll;
            % View the b-value map
            view_bv2([],valueMap)
            
            
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
            label='b-value [xsec]';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XZfun.bcross(zapFcn()));
        end
    end
end

function bcross_orig(sel)
    % This subroutine  creates a grid with
    % spacing dx,dy (in degreees). The size will
    % be selected interactively or grids the entire cross section.
    % The b-value in each volume is computed around a grid point containing ni earthquakes
    % or in between a certain radius
    % The standard deviation is calcualted either with the max. likelihood or by bootstrapping, when that box is checked.
    % If not, both options can be assigned by the additional run assignment.
    % Standard deviation of b-value in non-bootstrapping case is calculated from Aki-formula!
    % Org: Stefan Wiemer 1/95
    % updated: J. Woessner, 02.04.2005
    
    % JW: Removed Additional random runs for uncertainty determination since
    % this is incorporated in new functions to determine Mc and B with
    % bootstrapping
    
    ZG=ZmapGlobal.Data
    report_this_filefun();
    error('Update this file to the new catalog')
    if ~exist('sel','var'), sel='in',end
    
    
    switch sel
        case 'load'
            myload()
            return
    end
    
    
    % Do we have to create the dialogbox?
    % Set the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    bv2 = NaN;
    Nmin = 50;
    stan2 = NaN;
    stan = NaN;
    prf = NaN;
    av = NaN;
    %nRandomRuns = 1000;
    bGridEntireArea = false;
    nBstSample = 100;
    fMccorr = 0;
    fBinning = 0.1;
    bBst_button = false;
    fMcFix = 1.5;
    
    
    
    %% make the interface
    %{
    zdlg = ZmapDialog();
    %zdlg = ZmapDialog(obj, @obj.doIt);
    
    zdlg.AddHeader('Choose stuff');
    zdlg.AddMcMethodDropdown('mc_choice');
    zdlg.AddGridSpacing('gridOpts',dx,'km',[],'',dd,'km');
    zdlg.AddEventSelector('eventSelector',obj.EventSelector);
    
    zdlg.AddEdit('fBinning','Magnitude binning', fBinning,...
        'Bins for magnitudes');
    zdlg.AddCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
        're takes longer, but provides more accurate results');
    zdlg.AddEdit('nBstSample','Number of bootstraps', nBstSample,...
        'Number of bootstraps to determine Mc');
    zdlg.AddEdit('Nmin','Min. No. of events > Mc', Nmin,...
        'Min # events greater than magnitude of completeness (Mc)');
    zdlg.AddEdit('fMcFix', 'Fixed Mc',fMcFix,...
        'fixed magnitude of completeness (Mc)');
    zdlg.AddEdit('fMccorr', 'Mc correction factor',fMccorr,...
        'Correction term to be added to Mc');
    
    [res,okPressed] = zdlg.Create('Name', 'b-Value X-section Grid Parameters');
            
    if ~okPressed
        return
    end
    hndl2=res.mc_choice;
    dx = res.gridOpts.dx;
    dd = res.gridOpts.dz;
    tgl1 = res.eventSelector.UseNumClosestEvents;
    tgl2 = ~tgl1;
    ni = res.eventSelector.NumClosestEvents;
    ra = res.eventSelector.RadiusKm;
    Nmin = res.eventSelector.requiredNumEvents;
    bGridEntireArea = res.gridOpts.GridEntireArea;
    bBst_button = res.useBootstrap;
    nBstSample = res.nBstSample;
    fMccorr = res.fMccorr;
    fBinning = res.fBinning;
    
        mycalculate();
    %}
    
    %tgl1 : use Number of Events
    %tgl2 : use Constant Radius
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selecting the ni neighbors
    % to each grid point
    
    % Load exist b-grid
    function myload()
        [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            xsecx = newa(:,end)';
            xsecy = newa(:,7);
            xvect = gx; yvect = gy;
            tmpgri=zeros((length(xvect)*length(yvect)),2);
            
            
            normlap2=NaN(length(tmpgri(:,1)),1); % no longer used(?)
            % initialize a few matrices
            [magComp, McStdDev, mRadRes, b_value, mStdB, a_value, mStdA, fitToPowerlaw, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
            % replace the indexed values within
            
            magComp(ll) = bvg(:,1);         % Magnitude of completness
            McStdDev(ll) = bvg(:,2);       % Standard deviation Mc
            mRadRes(ll) = bvg(:,5);     % Radius resolution
            b_value(ll) = bvg(:,6);      % b-value
            mStdB(ll) = bvg(:,7);        % Standard deviation b-value
            a_value(ll)= bvg(:,8);      % a-value M(0)
            mStdA(ll) = bvg(:,9);        % Standard deviation a-value
            fitToPowerlaw(ll) = bvg(:,10);       % Goodness of fit to power-law map
            ro(ll) = bvg(:,11);          % Whatever this is
            mNumEq(ll) = bvg(:,12);     % number of events
            
            valueMap = b_value;
            
            nlammap
            globalcatalog = ZG.primeCatalog;
            [xsecx xsecy,  inde] =mysect(globalcatalog.Y',globalcatalog.X',globalcatalog.Z,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            set(gca,'NextPlot','add')
            plot(newgri(:,1),newgri(:,2),'+k')
            view_bv2([],valueMap)
        else
            return
        end
    end
    
end