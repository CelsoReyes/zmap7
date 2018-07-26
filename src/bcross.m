function bcross(sel)
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
    bGridEntireArea = 0;
    nBstSample = 100;
    fMccorr = 0;
    fBinning = 0.1;
    bBst_button = 0;
    fMcFix = 1.5;
    
    
    
    %% make the interface
    zdlg = ZmapDialog();
    %zdlg = ZmapDialog(obj, @obj.doIt);
    
    zdlg.AddBasicHeader('Choose stuff');
    zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',McMethods.dropdownList(),double(McMethods.MaxCurvature),...
        'Choose the calculation method for Mc');
    zdlg.AddGridParameters('gridOpts',dx,'km',[],'',dd,'km');
    zdlg.AddEventSelectionParameters('eventSelector',ni, ZG.ra,Nmin);
    
    zdlg.AddBasicEdit('fBinning','Magnitude binning', fBinning,...
        'Bins for magnitudes');
    zdlg.AddBasicCheckbox('useBootstrap','Use Bootstrapping', false, {'nBstSample','nBstSample_label'},...
        're takes longer, but provides more accurate results');
    zdlg.AddBasicEdit('nBstSample','Number of bootstraps', nBstSample,...
        'Number of bootstraps to determine Mc');
    zdlg.AddBasicEdit('Nmin','Min. No. of events > Mc', Nmin,...
        'Min # events greater than magnitude of completeness (Mc)');
    zdlg.AddBasicEdit('fMcFix', 'Fixed Mc',fMcFix,...
        'fixed magnitude of completeness (Mc)');
    zdlg.AddBasicEdit('fMccorr', 'Mc correction for MaxC',fMccorr,...
        'Correction term to be added to Mc');
    
    [res,okPressed] = zdlg.Create('b-Value X-section Grid Parameters');
            
    if ~okPressed
        return
    end
    
    hndl2=res.mc_choice;
    dx = res.gridOpts.dx;
    dd = res.gridOpts.dz;
    tgl1 = res.eventSelector.UseNumNearbyEvents;
    tgl2 = ~tgl1;
    ni = res.eventSelector.NumNearbyEvents;
    ra = res.eventSelector.RadiusKm;
    Nmin = res.eventSelector.requiredNumEvents;
    bGridEntireArea = res.gridOpts.GridEntireArea;
    bBst_button = res.useBootstrap;
    nBstSample = res.nBstSample;
    fMccorr = res.fMccorr;
    fBinning = res.fBinning;
    
        mycalculate();
    
    %tgl1 : use Number of Events
    %tgl2 : use Constant Radius
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selecting the ni neighbors
    % to each grid point
    
    function mycalculate()
    
        % Select and create grid
        [newgri, xvect, yvect, ll] = ex_selectgrid(xsec_fig(), dx, dd, bGridEntireArea);
        
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = newa.DateRange() ;
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
            
            if length(b) >= Nmin  % enough events?
                % Added to obtain goodness-of-fit to powerlaw value
                [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                [fMc] = calc_Mc(b, McMethods(ZG.inb1), fBinning, fMccorr);
                l = b.Magnitude >= fMc-(fBinning/2);
                if length(b(l,:)) >= Nmin
                    [ fBValue, fStd_B, fAValue] =  calc_bmemag(b(l,:), fBinning);
                else
                    %fMc = NaN;
                    fBValue = NaN; fStd_B = NaN; fAValue= NaN;
                end
                
                % Bootstrap uncertainties
                if bBst_button == 1
                    % Check Mc from original catalog
                    l = b.Magnitude >= fMc-(fBinning/2);
                    if length(b(l,:)) >= Nmin
                        [fMc, fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, vMc, mBvalue] = calc_McBboot(b, fBinning, nBstSample, ZG.inb1);
                    else
                        %fMc = NaN;
                        %fStd_Mc = NaN;
                        fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                    end
                else
                    % Set standard deviation ofa-value to NaN;
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
        
        catsave3('bcross');
        %corrected window positioning error
        close(wai)
        watchoff
        
        % initialize a few matrices
        [mMc, mStdMc, mRadRes, mBvalue, mStdB, mAvalue, mStdA, Prmap, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
        % replace the indexed values within
        
        mMc(ll) = bvg(:,1);         % Mc map
        mStdMc(ll) = bvg(:,2);       % Standard deviation Mc
        mRadRes(ll) = bvg(:,5);     % Radius resolution
        mBvalue(ll) = bvg(:,6);      % b-value
        mStdB(ll) = bvg(:,7);        % Standard deviation b-value
        mAvalue(ll) = bvg(:,8);      % a-value M(0)
        mStdA(ll) = bvg(:,9);        % Standard deviation a-value
        Prmap(ll) = bvg(:,10);       % Goodness of fit to power-law map
        ro(ll) = bvg(:,11);          % Whatever this is
        mNumEq(ll) = bvg(:,12);     % number of events
        
        valueMap = mBvalue;
        kll = ll;
        % View the b-value map
        view_bv2([],valueMap)
        
    end
    
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
            [mMc, mStdMc, mRadRes, mBvalue, mStdB, mAvalue, mStdA, Prmap, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
            % replace the indexed values within
            
            mMc(ll) = bvg(:,1);         % Magnitude of completness
            mStdMc(ll) = bvg(:,2);       % Standard deviation Mc
            mRadRes(ll) = bvg(:,5);     % Radius resolution
            mBvalue(ll) = bvg(:,6);      % b-value
            mStdB(ll) = bvg(:,7);        % Standard deviation b-value
            mAvalue(ll)= bvg(:,8);      % a-value M(0)
            mStdA(ll) = bvg(:,9);        % Standard deviation a-value
            Prmap(ll) = bvg(:,10);       % Goodness of fit to power-law map
            ro(ll) = bvg(:,11);          % Whatever this is
            mNumEq(ll) = bvg(:,12);     % number of events
            
            valueMap = mBvalue;
            
            nlammap
            [xsecx xsecy,  inde] =mysect(ZG.primeCatalog.Latitude',ZG.primeCatalog.Longitude',ZG.primeCatalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            set(gca,'NextPlot','add')
            plot(newgri(:,1),newgri(:,2),'+k')
            view_bv2([],valueMap)
        else
            return
        end
    end
    
end