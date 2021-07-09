
function [bestmc,bestb,result_flag]=nonlinearity_index(zCat,Mcmin,mode)
    % NONLINEARITY_INDEX detect whether extrapolation of FMD is applicable, or is an inaccurate estimate
    %
    % Measure to detect whether the extrapolation of a given FMD to high
    % magnitudes is applicable or whether the shape of the FMD suggests that
    % an extrapolation would over- or underestimate the probably true rates for
    % large events
    %
    % ------------------- NLIndex NonLinearityIndex ---------------------------
    % [bestmc,bestb,result_flag]=NONLINEARITY_INDEX(zCat,Mcmin,'PreDefinedMc') uses the given Mcmin as
    %      magnitude of completeness. zCat is a ZmapCatalog, and Mcmin is the suggested magnitude of
    %      completeness (Mc). Depending on the mode, this Mc estimate can be corrected to higher values
    %      in order to optimize the linear fit
    %
    % [bestmc,bestb,result_flag]=NONLINEARITY_INDEX(zCat,Mcmin,'OptimizeMc') checks whether a higher Mc
    %       could optimize the NLIndex. For this option, the Mc estimate can be corrected to a higher
    %       value in order to optimize the linear fit
    %
    %
    % author: Thessa Tormann
    % date: October 2012
    %
    % adapted by C. Reyes to ZMap
    %
    %**************************************************************************
    %
    % Input parameters:
    %
    % 1) zCat = catalog to test
    % 2) Mcmin = suggested magnitude of completeness, depending on the mode, this
    %    Mc estimate can be corrected to higher values in order to optimize the
    %    linear fit
    % 3) Nmin = minimum number of events required to attempt a b-value estimate
    %    commonly Nmin=50
    % 4) Mtarg = target magnitude of large events, commonly Mtarg = 6
    % 5) mode = sets the mode in which to run the filter:
    %       'PreDefinedMc' = uses the given Mcmin as magnitude of completeness
    %       'OptimizeMc' = checks whether a higher Mc could optimize the
    %                      NLIndex
    % 6) binnumb = minimum number of different Mc for which N>=Nmin, i.e. b can
    %        be estimated
    % 7) sigMcDif = difference between Mmin and Mc that is regarded
    %        significant, e.g. sigMcDif=1
    % 8) slope_pos = minimum slope of b-value trend that indicates an
    %        overestimation of large magnitude rates, e.g. slope_pos = 0.05
    % 9) slope_neg = maximum slope of b-value trend that indicates an
    %        underestimation of large magnitude rates, e.g. slope_neg = -0.05
    %
    %**************************************************************************
    %
    % Algorithm:
    %
    % 1) calculate b-value for all Mcut from Mcmin to the highest Mcut for
    %       which still Nmin events are sampled
    % 2) mode: 'PreDefinedMc'
    %       --> calculate mean and standard deviation of b-values estimated in
    %        step 1), do this if at least 5 estimates were possible
    %       --> divide standard deviation by the largest individual b-value
    %        uncertainty, this value is the NLIndex
    %       --> if NLIndex is <=1, FMD is linear
    %       --> if NLIndex is >1, and slope of b(mcut) is clearly positive,
    %           FMD overestimates large M rates
    %       --> if NLIndex is >1, and slope of b(mcut) is clearly negative,
    %           FMD underestimates large M rates
    % 3) mode: 'OptimizeMc'
    %       --> calculate mean and standard deviation of b-values estimated in
    %        step 1), do this if at least 5 estimates were possible
    %       --> divide standard deviation by the largest individual b-value
    %        uncertainty, do this for each possible mcut, and for each mcut
    %        this value is the NLIndex
    %       --> divide the NLIndex for each mcut by the number of estimated
    %        b-values to weigh the result by data density
    %       --> find the minimum weighted NLIndex to find the bestmc that
    %        produces the most linear FMD fit
    %       --> find the bestb by taking the mean of all b-value of those mcut
    %        that produced linear estimates
    %       --> if NLIndex is <=1, FMD is linear
    %       --> if NLIndex is >1, and slope of b(mcut) is clearly positive,
    %           FMD overestimates large M rates
    %       --> if NLIndex is >1, and slope of b(mcut) is clearly negative,
    %           FMD underestimates large M rates
    %
    %**************************************************************************
    %
    % Output parameters:
    %
    % 1) bestmc = best value for Mc (=Mcmin, if mode='PreDefinedMc')
    % 2) bestb = best b-value estimate, i.e.:
    %       b for all M>=Mcmin if mode='PreDefinedMc'
    %       median of all b values calculated for M>=Mc for acceptable Mc>=Mcmin
    % 3) result_flag = flag describing the outcome of the analysis:
    %           1: catalog with N<Nmin events, no b-value estimate
    %           2: catalog with N>=Nmin events, but not enough to compute NLI
    %           3: FMD is linear with Mcmin<=Mc<=Mcmin+sigMcDif
    %           4: FMD is linear for significantly increased Mc>Mcmin+0.5
    %           5: FMD is unstable
    %           6: FMD underestimates Mtarg rates
    %           7: FMD overestimates Mtarg rates
    %
    %**************************************************************************
    
    bestmc=[]; bestb=[];
    
    % -------------------------------------------------------------------------
    % SET PARAMETERS:
    % -------------------------------------------------------------------------
    
    % 1) CHOOSE MODE (comment one)
    
    %mode='PreDefinedMc';
    %mode='OptimizeMc';
    
    % 2) SET NUMBERS
    
    Nmin=50;
    Mtarg=6;
    binnumb=5;
    sigMcDif=1;
    slope_pos=0.05;
    slope_neg=-0.15;
    
    %--------------------------------------------------------------------------
    % Catalog preparation
    %--------------------------------------------------------------------------
    
    % round magnitudes to 0.1 binning and cut at Mcmin
    
    % zCat.Magnitude=0.1*round(10*zCat.Magnitude);
    zCat=zCat.subset(zCat.Magnitude>=Mcmin);
    
    
    if zCat.Count<Nmin
        
        result_flag=1;
        bestmc=nan;
        bestb=nan;
        disp('not enough events to calculate b')
        return
    end
    
    % determine magnitude range in catalog from Mcmin to Mmax
    Mrange=Mcmin:0.1:max(zCat.Magnitude);
    
    % calculate FMD (cumulative number of events for M>=Mcmin)
    Numb=hist(zCat.Magnitude,Mrange);
    Numbh=Numb(end:-1:1);
    Ncumh=cumsum(Numbh);
    Ncum=Ncumh(end:-1:1);
    
    disp(['Catalog has ', num2str(Ncum(1)),' events'])
    
    % determine magnitude range for which Ncum(M) >= Nmin (i.e. max mag for
    % which >=50 events exist)
    xx=Ncum>=Nmin;
    Mcrange=Mrange(xx);
    
    if length(Mcrange)<binnumb
        
        result_flag=2;
        bestmc=nan;
        bestb=nan;
        disp('not enough events to perform linearity assessment')
        return
    end
    
    % ---------------------------------------------------------------------
    % Calculation of
    %     b - maximum likelihood b-value (Aki 1965), and
    %     std(b) - standard deviation (Shi & Bold 1982)
    % for each cutoff-magnitude of Mcrange
    % (save results in matrix 'b')
    % ---------------------------------------------------------------------
    
    % b=nan(length(Mcrange),3);
    
    b.Mc = Mcrange;
    b.b1 = nan(length(b.Mc),1);
    b.sig1 = nan(length(b.Mc),1);
    
    for i=1:length(Mcrange)
        
        ll=zCat.Magnitude>=Mcrange(i);
        
        b1=(1/(mean(zCat.Magnitude(ll))-(Mcrange(i)-0.05)))*log10(exp(1));
        
        sig1 = (sum((zCat.Magnitude(ll)-mean(zCat.Magnitude(ll))).^2))/(sum(ll)*(sum(ll)-1));
        sig1 = sqrt(sig1);
        sig1 = 2.30*sig1*b1^2;
        
        % b(i,:)=[Mcrange(i),b1,sig1];
        b.b1(i)=b1;
        b.sig1(i)=sig1;
    end
    
    [histb,xout]=hist(b.b1);
    histb=histb./length(b.Mc);
    
    % ---------------------------------------------------------------------
    % Calculation of NLIndex:
    %      1) for each cutoffmagnitude, for which at least 'binnumb' b-values
    %         from higher cutoff magnitudes have been calculated,
    %      2) calculate the standard variation in the b-values,
    %         and divide by the largest individual std(b) (mark)
    %      3) divide by number of mcutbins underlying the estimate (markw)
    %      4) determine slope and intercept of b(Mc) fit (slope,intercept)
    % (save in matrix 'marker')
    % ---------------------------------------------------------------------
    
    k=0;
    
    for mcut=Mcmin:0.1:max(Mcrange)-(0.1*binnumb-0.2)
        
        k=k+1;
        
        NLIndex=std(b.b1(k:end))/max(b.sig1(k:end));
        NLIndexw=1/(length(Mcrange)-k)*NLIndex;
        
        h1=robustfit(b.Mc(k:end),b.b1(k:end));
        slope(k)=h1(2);
        intercept(k)=h1(1);
        
        % marker(k,:)=[mcut,b.b1(k),b.sig1(k),NLIndex,NLIndexw,slope(k)];
        %         marker(k,:)=[mcut,b.b1(k),b.sig1(k),NLIndex,NLIndexw,0]; % that was
        %         for running it without using 'robustfit'
        marker(k)=struct('mcut',mcut,...
            'b1',b.b1(k),...
            'sig1',b.sig1(k),...
            'NLIndex',NLIndex,...
            'NLIndexw',NLIndexw,...
            'slope',slope(k));
        
    end
    
    %----------------------------------------------------------------------
    % output figure: subplot lower left corner
    %   b-values with stddev (blue) for different Mcut (Mcmin-Mcmax)
    %   b-value trend (blue)
    %   marker values (red) for different Mcut (Mcmin-Mcmax-binnumb)
    %----------------------------------------------------------------------
    
    figure('Name',['B-value linearity analysis : ', mode],'NumberTitle','off')
    plot_bvals_cuts()
    
    %----------------------------------------------------------------------
    % screen output:
    %   markermatrix
    %   number of non-linear estimates
    %----------------------------------------------------------------------
    
    %display(marker)
    
    hhnonlin=[marker.NLIndex]>1;
    numbnonlin=sum(hhnonlin);
    disp([num2str(numbnonlin),' nonlinear estimates out of ',...
        num2str(length(marker))])
    
    %----------------------------------------------------------------------
    % interpret marker values, depending on chosen 'mode'
    %----------------------------------------------------------------------
    
    switch mode
        
        %------------------------------------------------------------------
        % use the pre-defined completeness magnitude
        %   i.e. only interpret first line of marker matrix
        %------------------------------------------------------------------
        case 'PreDefinedMc'
            
            disp('use pre-defined Mcmin')
            
            %--------------------------------------------------------------
            % use given Mc, and corresponding b-value, calculate a-value
            %   and rate of target magnitude events
            %--------------------------------------------------------------
            
            bestmc=marker(1).mcut;
            bestb=marker(1).b1;
            besta=log10(Ncum(1))+bestb*bestmc;
            NMc=Ncum(1);
            NMtarg=10^(besta-bestb*Mtarg);
            
            %--------------------------------------------------------------
            % if marker for Mc is <=1, the fit is ok
            %--------------------------------------------------------------
            
            if marker(1).NLIndex<=1
                
                blurb = 'FMD extrapolation realistically estimates M6+ rates';
                result_flag=3;
                
                %----------------------------------------------------------
                % output figure: subplot upper row
                %   cumulative FMD (black)
                %   b-value (green - fit ok)
                %----------------------------------------------------------
                
                plot_bvalue_cumFMD([marker(1).mcut,Mtarg],[NMc,NMtarg], 'ok');
                
                %----------------------------------------------------------
                % output figure: subplot lower right corner
                %   histogram of b-values for different cutoff magnitudes
                %       (blue)
                %   mean b-value (blue line) +/- stdvar (dotted blue)
                %   mean b-value +/- max individual error (dotted red)
                %----------------------------------------------------------
                
                
                bvalue_cutoff_mag_histogram(b, xout, histb);
                
                %--------------------------------------------------------------
                % if marker for Mc is >1, the fit is not ok
                %--------------------------------------------------------------
                
            else
                
                %----------------------------------------------------------
                % if trend of single b-value estimates is increasing
                %   --> extrapolation overestimates
                %----------------------------------------------------------
                
                if marker(1).slope>slope_pos
                    
                    blurb = 'FMD extrapolation overestimates M6+ rates';
                    result_flag=7;
                    
                    %------------------------------------------------------
                    % output figure: subplot upper row
                    %   cumulative FMD (black)
                    %   b-value (red - fit not ok, rates too high)
                    %------------------------------------------------------
                    
                    plot_bvalue_cumFMD([marker(1).mcut,Mtarg],[NMc,NMtarg],'too_high');
                    
                    %----------------------------------------------------------
                    % if trend of single b-value estimates is decreasing
                    %   --> extrapolation underestimates
                    %----------------------------------------------------------
                    
                elseif marker(1).slope<slope_neg
                    
                    blurb = 'FMD extrapolation underestimates M6+ rates';
                    result_flag=6;
                    
                    %------------------------------------------------------
                    % output figure: subplot upper row
                    %   cumulative FMD (black)
                    %   b-value (blue - fit not ok, rates too low)
                    %------------------------------------------------------
                    
                    plot_bvalue_cumFMD([marker(1).mcut,Mtarg],[NMc,NMtarg],'too_low');
                    
                    %----------------------------------------------------------
                    % if trend of single b-value estimates is flat
                    %   --> extrapolation unstable
                    %----------------------------------------------------------
                    
                else
                    
                    blurb = 'FMD slope unstable';
                    result_flag=5;
                    
                    %------------------------------------------------------
                    % output figure: subplot upper row
                    %   cumulative FMD (black)
                    %   b-value (black - fit not ok, unstable)
                    %------------------------------------------------------
                    
                    plot_bvalue_cumFMD([marker(1).mcut,Mtarg],[NMc,NMtarg],'unstable');
                end
                
                
                
                %----------------------------------------------------------
                % output figure: subplot lower right corner
                %   histogram of b-values for different cutoff magnitudes
                %       (blue)
                %   mean b-value (blue line) +/- stdvar (dotted blue)
                %   mean b-value +/- max individual error (dotted red)
                %----------------------------------------------------------
                
                bvalue_cutoff_mag_histogram(b, xout, histb);
                
            end
            
            %------------------------------------------------------------------
            % optimize suggested completeness magnitude for linearity
            %------------------------------------------------------------------
            
        case 'OptimizeMc'
            
            %figure
            %plot_bvals_cuts()
            
            disp('optimize Mcmin based on linearity assessment')
            
            hhlin=[marker.NLIndex]<=1;
            
            %--------------------------------------------------------------
            % if at least half of the estimated b-values are based on a
            % linear fit
            %--------------------------------------------------------------
            
            if numbnonlin<=0.5*length(marker)
                
                blurb = 'FMD extrapolation realistically estimates M6+ rates';
                result_flag=3;
                
                %----------------------------------------------------------
                % use only estimates with linear fit:
                %   estimate bestMc from the minimum marker value (scaled by
                %     number of estimates) --> most linear fit
                %   estimate bestb as the median b-value of all linear
                %     estimates
                %   calculate besta and the rate of target magnitudes
                %----------------------------------------------------------
                
                markeracc=marker(hhlin);
                [~,i2]=min([markeracc.NLIndexw]);
                markeracc=markeracc(i2:end);
                bestmc=markeracc(1).mcut;
                bestb=median([markeracc.b1], 'omitnan');
                i1=find(round(10*Mrange)==round(10*bestmc));
                besta=log10(Ncum(i1))+bestb*bestmc;
                NMc=Ncum(i1);
                NMtarg=10^(besta-bestb*Mtarg);
                
                %----------------------------------------------------------
                % report if bestMc is significantly larger than Mmin
                %----------------------------------------------------------
                
                if bestmc-Mrange(1)>=sigMcDif
                    disp(blurb);
                    blurb=sprintf('Optimized Mc [%g] significantly higher than suggested Mc [%g]',bestmc, Mrange(1));
                    result_flag=4;
                end
                
                %----------------------------------------------------------
                % output figure: subplot upper row
                %   cumulative FMD (black)
                %   b-value (green - fit ok)
                %----------------------------------------------------------
                plot_bvalue_cumFMD([bestmc,Mtarg],[NMc,NMtarg],'ok');
                
                %----------------------------------------------------------
                % output figure: subplot lower right corner
                %   histogram of b-values for different cutoff magnitudes
                %       (blue)
                %   mean b-value (blue line) +/- stdvar (dotted blue)
                %   mean b-value +/- max individual error (dotted red)
                %----------------------------------------------------------
                
                
                bvalue_cutoff_mag_histogram(b, xout, histb);
                
                %--------------------------------------------------------------
                % if more than half of the estimated b-values are based on a
                % non-linear fit
                %--------------------------------------------------------------
                
            else
                
                %----------------------------------------------------------
                % estimate bestMc as minimum Mc, bestb as median of all
                % estimates, and calculate besta and rate of target events
                %----------------------------------------------------------
                
                bestmc=Mrange(1);
                bestb=median([marker.b1], 'omitnan');
                besta=log10(Ncum(1))+bestb*bestmc;
                NMc=Ncum(1);
                NMtarg=10^(besta-bestb*Mtarg);
                
                %----------------------------------------------------------
                % if trend of single b-value estimates is increasing
                %   --> extrapolation overestimates
                %----------------------------------------------------------
                
                if marker(1).slope>slope_pos
                    
                    
                    blurb = 'FMD extrapolation overestimates M6+ rates';
                    result_flag=7;
                    
                    %------------------------------------------------------
                    % output figure: subplot upper row
                    %   cumulative FMD (black)
                    %   b-value (red - fit not ok, rates too high)
                    %------------------------------------------------------
                    
                    plot_bvalue_cumFMD([Mrange(1),Mtarg],[NMc,NMtarg],'too_high');
                    
                    %----------------------------------------------------------
                    % if trend of single b-value estimates is decreasing
                    %   --> extrapolation underestimates
                    %----------------------------------------------------------
                    
                elseif marker(1).slope<slope_neg
                    
                    blurb = 'FMD extrapolation underestimates M6+ rates';
                    result_flag=6;
                    
                    %------------------------------------------------------
                    % output figure: subplot upper row
                    %   cumulative FMD (black)
                    %   b-value (blue - fit not ok, rates too low)
                    %------------------------------------------------------
                    
                    plot_bvalue_cumFMD([Mrange(1),Mtarg],[NMc,NMtarg],'too_low');
                    %----------------------------------------------------------
                    % if trend of single b-value estimates is flat
                    %   --> extrapolation unstable
                    %----------------------------------------------------------
                    
                else
                    
                    blurb = 'FMD slope unstable';
                    result_flag=5;
                    
                    %------------------------------------------------------
                    % output figure: subplot upper row
                    %   cumulative FMD (black)
                    %   b-value (black - fit not ok, unstable)
                    %------------------------------------------------------
                    
                    plot_bvalue_cumFMD([Mrange(1),Mtarg], [NMc,NMtarg], 'unstable');
                    
                end
                
                %----------------------------------------------------------
                % output figure: subplot lower right corner
                %   histogram of b-values for different cutoff magnitudes
                %       (blue)
                %   mean b-value (blue line) +/- stdvar (dotted blue)
                %   mean b-value +/- max individual error (dotted red)
                %----------------------------------------------------------
                
                bvalue_cutoff_mag_histogram(b, xout, histb);
            end
            disp(blurb);
    end
    
    function plot_bvalue_cumFMD(x, y, status)
        %------------------------------------------------------
        % output figure: subplot upper row
        %   cumulative FMD (black)
        %   b-value
        %       - (blue - fit not ok, rates too low)
        %       - (red - fit not ok, rates too high)
        %       - (green - fit ok)
        %       - (black - fit not ok, unstable)
        %------------------------------------------------------
        
        ax = subplot(2,2,[1 2]);
        
        semilogy(ax,Mrange,Ncum,'.k')
        hold(ax,'on')
        
        switch status
            case 'too_low' % blue
                plot(ax,x,y,'b')
            case 'too_high' % red
                plot(ax,x,y,'r')
            case 'ok'   % green
                plot(ax,x,y,'g')
            case 'unstable'  %black
                plot(ax,x,y,'k')
        end
        title(blurb)
        xlim(ax,[Mcmin-0.1,max(6,Mrange(end)+0.1)])
        ylim(ax,[0.1,2*Ncum(1)])
        xlabel(ax,'Magnitude')
        ylabel(ax,'Cumulative N')
    end
    
    function plot_bvals_cuts()
        %----------------------------------------------------------------------
        % output figure: subplot lower left corner
        %   b-values with stddev (blue) for different Mcut (Mcmin-Mcmax)
        %   b-value trend (blue)
        %   marker values (red) for different Mcut (Mcmin-Mcmax-binnumb)
        %----------------------------------------------------------------------
        
        ax=subplot(2,2,3);
        plot(ax,b.Mc,b.b1,'b.');
        ax.NextPlot='add';
        plot(ax, b.Mc,b.b1-b.sig1,'b:');
        plot(ax, b.Mc,b.b1+b.sig1,'b:');
        plot(ax, b.Mc(k+1:end),b.b1(k+1:end),'.c');
        plot(ax, b.Mc,slope(1)*b.Mc+intercept(1),'b');
        plot(ax, [marker.mcut],[marker.NLIndex],'r.');
        xlim(ax, [Mcmin-0.1,Mcrange(end)+0.1]);
        ylim(ax, [0,max(2,max([marker.NLIndex]))]);
        xlabel(ax, 'Mcut');
        ylabel(ax, 'b (blue), marker (red)');
    end
end

function bvalue_cutoff_mag_histogram(b, xout, histb)
    %----------------------------------------------------------
    % output figure: subplot lower right corner
    %   histogram of b-values for different cutoff magnitudes
    %       (blue)
    %   mean b-value (blue line) +/- stdvar (dotted blue)
    %   mean b-value +/- max individual error (dotted red)
    %----------------------------------------------------------
    ax = subplot(2,2,4);
    bar(ax,xout,histb);
    ax.NextPlot='add';
    plot(ax,[mean(b.b1),mean(b.b1)],[0,1]);
    plot(ax,[mean(b.b1)-std(b.b1),mean(b.b1)-std(b.b1)],[0,1],':');
    plot(ax,[mean(b.b1)+std(b.b1),mean(b.b1)+std(b.b1)],[0,1],':');
    plot(ax,[mean(b.b1)+max(b.sig1),mean(b.b1)+max(b.sig1)],[0,1],':r');
    plot(ax,[mean(b.b1)-max(b.sig1),mean(b.b1)-max(b.sig1)],[0,1],':r');
    xlabel(ax,'b-value');
    ylabel(ax,'count');
    ylim(ax,[0,1]);
end
