function plot95C() 
    % This program plots in GMT a polar projection of the
    % best fitting stress-tensor and the 95% confidence limits
    %
    % stefan Wiemer 05/96, last modified, Jan 2001
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    figure_w_normalized_uicontrolunits( ...
        'Name','Polar projection of stress tensor inversion result ',...
        'NumberTitle','off', ...
        'NextPlot','add', ...
        'Visible','on', ...
        'Position',[ (ZG.fipo(3:4) - [600 500]) winx winx]);
    
    global c i newgri ste s te te1
    hodis = fullfile(hodi,'stinvers');
    load(fullfile(hodis,out95));
    
    cd(hodis)
    
    % find the 95% confidence region
    
    f2 = out95;
    fit = min(out95(:,9));
    pai = atan(1.0)*4;
    k = 4;
    conf = 1.96;
    li = (conf*sqrt((pai/2.0-1)*n)+n*1.0)*fit/((n-k)*1.0);
    
    %li = prctile2(out95(:,9),1.0);
    l = out95(:,9) <= li;
    f = out95(l,:);
    save out95B.dat f -ascii
    
    i =  find(f(:,9) == min(f(:,9)));
    f3 = f(min(i),:);
    save out95C.dat f3 -ascii
    % add the strike of the fault
    %def = {'45'};
    % ni2 = inputdlg('Strike of the fault-line to be plotted in degrees?','Input',1,def);
    % l = ni2{1};
    % strike  = str2double(l);
    %str = [180-strike 0 ; 360-strike 0];
    %save strike.dat str -ascii
    
    system("psbasemap -R0/360/-90/0 -Ja0/-90/2.5/0  -Ba400f30N  -G255/255/255 -V -P -X3.0 -Y4.0 -K > gmt.ps");
    system("awk '{print $2, -$1}' out95B.dat  | psxy -R -Ja -Sc0.08 -O -G255/0/0 -V -P -K >> gmt.ps");
    system("awk '{print $4, -$3}' out95B.dat  | psxy -R -Ja -Sc0.08 -O -G0/255/0 -V -P -K >> gmt.ps");
    system("awk '{print $6, -$5}' out95B.dat  | psxy -R -Ja -Sc0.08 -O -G0/0/255 -V -P -K >> gmt.ps");
    
    system("awk '{print $2, -$1}' out95C.dat  | psxy -R -Ja -St0.20 -W2/0/0/0 -O -G255 -V -P -K >> gmt.ps");
    system("awk '{print $4, -$3}' out95C.dat  | psxy -R -Ja -Ss0.20 -W2/0/0/0 -O -G255 -V -P -K >> gmt.ps");
    system("awk '{print $6, -$5}' out95C.dat  | psxy -R -Ja -Si0.20 -W2/0/0/0 -O -G255 -V -P -K >> gmt.ps");
    
    system("awk '{print $1, -$2}' strike.dat  | psxy -R -Ja -W2/0/0/0 -O -V -P -K >> gmt.ps");
    
    system("gs gmt.ps");
    
    
    
end
