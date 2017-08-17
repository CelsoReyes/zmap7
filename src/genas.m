function out_ztimes = genas(cumu,xt,totbin,bin0,bin1)
    %
    %  Syntax:     ztimes = genas(cumu,xt,totbin,bin0,bin1)
    %
    %  This Matlab function uses the GenAS algorithm of Habermann
    %  to determine times of maximum Z values (as given by function AS)
    %  for a cumulative time curve.
    %
    %  cumu is a histogram of events using a predefined bin length
    %  xt is the total time vector (in decimal years)
    %  bin0 is the cutoff at the beginning and bin1 at end of the analyses
    %  totbin is the total number of bins (including those with 0 z-values)
    %  ztimes is a vector with max-zvalues, its indexes give the bin number
    %  ------------------                                  R. Zuniga, 4/94
    
    global ztimes
    global sumx
    
    report_this_filefun(mfilename('fullpath'));
    
    as = 1:1:totbin;
    as = as*0;
    % if ~exist('sumx', 'var'); sumx = sum(cumu); end
    sumx = [sumx; sum(cumu)];
    sumx = max(sumx);
    par2 = sumx*0.1;
    %
    %
    for i = bin0+3:1:bin1-3          % calculate mean and z value for AS
        mean1 = mean(cumu(bin0:i));
        mean2 = mean(cumu(i+1:bin1));
        var1 = cov(cumu(bin0:i));
        var2 = cov(cumu(i+1:bin1));
        if mean1 && mean2 ~= 0
            as(i) = (mean1 - mean2)/(sqrt(var1/(i-bin0+1)+var2/(bin1-i)));
        else
            as(i) = 0;
            
        end     %if mean1
        
    end     % for i
    
    %   S = sprintf('bin0 %3d bin1 %3d i  %d',bin0, bin1, i);
    %   disp(S)
    %
    % check for threshold  (z = 1.96 -> 95%,  2.57  -> 99%)
    %as
    [xmax,ixs] = max(abs(as));
    if abs(as(ixs)) >= 2.57
        zmax = as(ixs);
        as = as*0 ;
        as(ixs) = zmax;
        
        ztimes(ixs) = as(ixs);      % form (vector) ztimes
        %  find(ztimes)
        
        xsum = cumsum(cumu);
        
        t1(1) = xt(ixs);
        t1(2) = xsum(ixs);
        t1p = [  t1(1)  t1(2); t1(1)   t1(2)+par2 ];
        plot(t1p(:,1),t1p(:,2),'k');
        hold on;
        
        S = sprintf('bin0 %d sig-Z at %d bin1 %d ',bin0, ixs, bin1);
        disp(S)
        
        ztimes = genas(cumu,xt,totbin,bin0,ixs);  %call genas again for both extremes
        ztimes = genas(cumu,xt,totbin,ixs,bin1);
        
    end     %if abs
    
    ztimes(1,totbin) = 0.;    %   pad the end of ztimes
    as = as*0;
    out_ztimes = ztimes; %return a version that isn't the global
    
    %
    %  Plot the as(t)
    %
    %figure_w_normalized_uicontrolunits(2)
    %clf
    % orient tall
    % rect = [0.2,  0.20, 0.55, 0.75];
    % axes('position',rect)
    %hold on
    %%plotyy(xt,cumu2,xt,as*10,'m')
    %% y2label('z-value')
    %% plot(xt,as*10,'+m')
    %% plot(xt,as*10,'m')
    % %text(0.70,0.5,'+: AS * 10','sc')
end
