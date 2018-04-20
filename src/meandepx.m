function meandepx(catalog, dist_km)
    % MEANDEPX compute the mean depth along a x-section
    %   catalog : catalog from cross section
    %   dist : distance from cross-section start
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    % compute the mean depth along a x-section
    
    
    button = questdlg('Mean Depth Computation','Which method would you like?','Constant number steps','Constant km steps','yep');
    
    
    switch button
        case 'Constant number steps'
            
            [xstep, movew] = constnumstepdialog(50,10);
            [d,idx] = sort(dist_km);
            z = -catalog.Depth(idx);
            %{
            col = length(catalog(1,:));
            [s,is] = sort(catalog(:,col)); % last column (?)
            catalog = catalog(is(:,1),:) ;
            
            d= catalog(:,col);
            z =-catalog.Depth;
            %}
            stepvalues = 1 : movew : length(d)-xstep; 
            MD = nan(numel(stepvalues),3);
            for i= 1:numel(stepvalues)
                thisrange = stepvalues(i) : stepvalues(i)+xstep;
                meanz=mean(z(thisrange)); 
                meand=mean(d(thisrange));
                stdz=std(z(thisrange));
                MD(i,:) = [meanz, meand, stdz];
            end
            
        case 'Constant km steps'
            [xstep, movew] = constkmstepdialog(50,10);
            [d,idx] = sort(dist_km);
            z = -catalog.Depth(idx);
            %{
            [s,is] = sort(catalog(:,10));
            catalog = catalog(is(:,1),:) ;
            
            col = length(catalog(1,:));
            d= catalog(:,col);
            z =-catalog(:,7);
            %}
            stepvalues = 0 : movew : max(d)-xstep;
            MD = nan(numel(stepvalues),3);
            for n= 1:numel(stepvalues)
                i=stepvalues(n);
                l = d >= i & d < i+xstep;
                MD(n,:) = [mean(z(l)) mean(d(l)) std(z(l))];
            end
            
    end % switch
    
    
    figure
    plot(d,z,'.r','markersize',1);
    hold on
    errorbar(MD(:,2),MD(:,1),MD(:,1)+MD(:,3));
    
    pl = plot(MD(:,2),MD(:,1),'sk');
    
    axis([min(d) max(d) min(z) max(z)]);
    xlabel('Distance [km]')
    ylabel('Depth [km]');
end

function [xstep, movew] = constnumstepdialog(xstep,movew)
    def = {num2str(xstep),num2str(movew)};
    ni2 = inputdlg({'Average over how many events in each step?','Move window by how many events?'},'Mean depth computation',1,def);
    l = ni2{1};
    xstep = str2double(l);
    l = ni2{2};
    movew = str2double(l);
end

function [xstep, movew] = constkmstepdialog(xstep,movew)
    def = {num2str(xstep),num2str(movew)};
    ni2 = inputdlg({'Step width in km?','step size in [km]'},'Mean depth computation',1,def);
    l = ni2{1};
    xstep = str2double(l);
    l = ni2{2};
    movew = str2double(l);
end