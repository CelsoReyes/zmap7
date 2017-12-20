function comp2periodz(sel)
    % This subroutine compares seismicity rates for two time periods. 
    % The differences are as z- and beta-values and as percent change.
    %   Stefan Wiemer 1/95
    %   Rev. R.Z. 4/2001
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    if ~exist('sel','var') || sel == 'in'
        % get the grid parameter
        % initial values
        %
        dx = 1.00;
        dy = 1.00 ;
        ra = 5 ;
        
        t1 = ZG.t0b;
        t4 = ZG.teb;
        t2 = ZG.t0b + (ZG.teb-ZG.t0b)/2;
        t3 = t2+0.01;
        
        % get two time periods, along with grid and event parameters
        zdlg=ZmapFunctionDlg([]);
        zdlg.AddBasicHeader('Please define two time periods to compare');
        zdlg.AddBasicEdit('t1','start period 1',t1,'start time for period 1');
        zdlg.AddBasicEdit('t2','end period 1',t2,'end time for period 1');
        zdlg.AddBasicEdit('t3','start period 2',t3,'start time for period 2');
        zdlg.AddBasicEdit('t4','end period 2',t4,'end time for period 2');
        zdlg.AddEventSelectionParameters('eventsel', ZG.ni, ra, minvalid)
        zdlg.AddGridParameters('gridparam',dx,'deg', dy,'deg', [],[])
        [zans,okPressed]=zdlg.Create('Please choose rate change estimation option');
        if ~okPressed
            return
        end
        t1=zans.t1; t2=zans.t2; t3=zans.t3; t4=zans.t4;
        
        %TODO: pluck variables out of zans; tgl1:nEvents, tgl2:maxRadius
        
        
        % GO
         tgl1=tgl1.Value;
        tgl2=tgl2.Value;
        prev_grid=prev_grid.Value;
        create_grid=create_grid.Value;
        load_grid=load_grid.Value;
        save_grid=save_grid.Value;
        my_calculate()
        
    end   % if nargin ==0
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % thge seimicity and selectiong the ni neighbors
    % to each grid point
    function my_calculate()
        
        %get new grid if needed
        if load_grid == 1
            [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
            if length(path1) > 1
                
                load([path1 file1])
                plot(newgri(:,1),newgri(:,2),'k+')
            end
        elseif load_grid ==0  &&  prev_grid == 0
            selgp
            if length(gx) < 4  ||  length(gy) < 4
                errordlg('Selection too small! (Dx and Dy are in degreees! ');
                return
            end
        end
        
        itotal = length(newgri(:,1));
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = ZG.primeCatalog.DateRange() ;
        n = ZG.primeCatalog.Count;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        bvg = [];
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','rate grid - percent done');;
        drawnow
        %
        bvg = nan(length(newgri(:,1)),4);
        lt =  ZG.primeCatalog.Date >= t1 &  ZG.primeCatalog.Date < t2  | ZG.primeCatalog.Date >= t3 &  ZG.primeCatalog.Date <= t4;
        aa_ = ZG.primeCatalog.subset(lt);
        
        % loop over all points
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            % calculate distance from center point and sort wrt distance
            l = sqrt(((aa_(:,1)-x)*cosd(y)*111).^2 + ((aa_(:,2)-y)*111).^2 ) ;
            [s,is] = sort(l);
            b = aa_(is(:,1),:) ;       % re-orders matrix to agree row-wise
            
            if tgl1 == 0   % take point within r
                l3 = l <= ra;
                b = b(l3,:);      % new data per grid point (b) is sorted in distanc
                rd = ra;
            else
                % take first ni points
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); rd = l2(ni);
                
            end
            [s,is] = sort(b.Date);
            b = b(is(:,1),:) ;
            
            lt =  b.Date >= t1 &  b.Date < t2 ;
            tback = b(lt,:);
            [cumu1, xt1] = hist(tback(:,3),(t1:days(ZG.bin_dur):t2));
            
            lt =  b.Date >= t3 &  b.Date <= t4 ;
            tafter = b(lt,:);
            [cumu2, xt2] = hist(tafter(:,3),(t3:days(ZG.bin_dur):t4));
            
            mean1 = mean(cumu1);        % mean seismicity rate in first interval
            mean2 = mean(cumu2);        % mean seismicity rate in second interval
            sum1 = sum(cumu1);          % number of earthquakes in the first interval
            sum2 = sum(cumu2);          % number of earthquakes in the second interval
            var1 = cov(cumu1);          % variance of cumu1
            var2 = cov(cumu2);          % variance of cumu2
            % remark (db): cov and var calculate the same value when applied to a vector
            ncu1 = length(xt1);         % number of bins in first interval
            ncu2 = length(xt2);         % number of bins in second interval
            
            as = (mean1 - mean2)/(sqrt(var1/ncu1 +var2/ncu2));
            per = -((mean1-mean2)./mean1)*100;
            
            % beta nach reasenberg & simpson 1992, time of second interval normalised by time of first interval
            bet = (sum2-sum1*ncu2/ncu1)/sqrt(sum1*(ncu2/ncu1));
            
            bvg(allcount,:) = [as  per rd bet ];
            waitbar(allcount/itotal)
        end  % for newgr
        
        % save data
        %
        close(wai)
        watchoff
        
        % plot the results
        % old and valueMap (initially ) is the z-value matrix
        %
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap2(ll)= bvg(:,1);
        valueMap=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,2);
        per=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,3);
        reso=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,4);
        beta_map=reshape(normlap2,length(yvect),length(xvect));
        
        
        
        old = valueMap;
        det =  'ast'; ZG.shading_style = 'interp';
        % View the b-value map
        storedcat=a;
        replaceMainCatalog(aa_);
        view_ratecomp
        
    end
end
