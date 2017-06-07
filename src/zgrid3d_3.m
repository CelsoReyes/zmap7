% This subroutine assigns creates a 3D grid with
% spacing dx,dy, dz (in degreees). The size will
% be selected interactiVELY. The pvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/98

report_this_filefun(mfilename('fullpath'));
global no1 bo1 inb1 inb2

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 0.1;
    dy = 0.1 ;
    dz = 5.00 ;
    ni = 300;
    R = 10000;


    def = {'0.1','0.1',num2str(dz),num2str(max(a(:,7))), num2str(min(a(:,7)))};

    tit ='Three dimesional z-value analysis';
    prompt={...
        'Spacing in Longitude (dx in [deg])',...
        'Sapcing in Latitude  (dy in [deg])',...
        'Spacing in Depth    (dz in [km ])',...
        'Depth Range: deep limit [km] ',...
        'Depth Range: shallow limit',...
        };


    ni2 = inputdlg(prompt,tit,1,def);

    l = ni2{1}; dx= str2double(l);
    l = ni2{2}; dy= str2double(l);
    l = ni2{3}; dz= str2double(l);
    l = ni2{4}; z1= str2double(l);
    l = ni2{5}; z2= str2double(l);


    sel = 'ca'; zgrid3d


end   % if sel == 'in'

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    selgp3dB
    zvect=[z2:dz:z1];
    gz = zvect;
    itotal = length(t5);
    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    zvg = NaN(length(gx),length(gy),length(gz),300);
    ram  = NaN(length(gx),length(gy),length(gz),300);

    t0b = a(1,3)  ;
    n = length(a(:,1));
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3,length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name',' 3D gridding - percent done');;
    drawnow
    %
    %


    z0 = 0; x0 = 0; y0 = 0; dt = 1;
    % loop over all points
    for il =1:length(t5);

        x = t5(il,1);
        y = t5(il,2);
        z = t5(il,3);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        di = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + ((a(:,7) - z)).^2 ) ;
        [s,is] = sort(di);

        l2 = find(is <= 300);


        %[cumu, xt] = hist(b(:,3),(t0b:(teb-t0b)/99:teb));

        zvg(t5(il,5),t5(il,6),t5(il,7),:) = is(1:300);
        ram(t5(il,5),t5(il,6),t5(il,7),:) = di(is(1:300));
        if rem(allcount,20) == 0;  waitbar(allcount/itotal) ;end
    end  % for xt5
    % save data
    %
    catSave3 =...
        [ 'welcome(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' zvg ram gx gy gz dx dy dz  par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    gz = -gz;
    zv2 = zvg;
    sel = 'no';
    lta_winy = 2;
    zv4 = zv2;
    tiz = 10;
    slm = 'new'; slicemapz;

end  % if cal

