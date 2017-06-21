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


    def = {'1982.6','3','200','0.1','0.1',num2str(dz),num2str(max(a.Depth)), num2str(min(a.Depth))};

    tit ='Three dimesional z-value analysis';
    prompt={'Time of analysis?',...
        'Window length in years ?',...
        'Sample size N?',...
        'Spacing in Longitude (dx in [deg])',...
        'Sapcing in Latitude  (dy in [deg])',...
        'Spacing in Depth    (dz in [km ])',...
        'Depth Range: deep limit [km] ',...
        'Depth Range: shallow limit',...
        };


    ni2 = inputdlg(prompt,tit,1,def);

    l = ni2{1}; ti  = str2double(l);
    l = ni2{2}; iwl2= str2double(l);
    l = ni2{3}; ni= str2double(l);
    l = ni2{4}; dx= str2double(l);
    l = ni2{5}; dy= str2double(l);
    l = ni2{6}; dz= str2double(l);
    l = ni2{7}; z1= str2double(l);
    l = ni2{8}; z2= str2double(l);


    sel = 'ca'; zgrid3db


end   % if sel == 'in'

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    selgp3dB
    zvect=[z2:dz:z1];
    gz = zvect;
    itotal = length(gx)*length(gz)*length(gy);
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    zvg = ones(length(gx),length(gy),length(gz))*nan;
    ra  = ones(length(gx),length(gy),length(gz));

    t0b = a(1,3)  ;
    n = a.Count;
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
    tl = teb - t0b;
    iwl = floor(iwl2*365/par1);
    t = floor((ti-t0b)*365/par1);


    z0 = 0; x0 = 0; y0 = 0; dt = 1;
    % loop over all points
    for x = min(gx):dx:max(gx)
        x0 = x0+1;
        for y = min(gy):dy:max(gy)
            y0 = y0+1;
            for z = min(gz):dz:max(gz)
                z0 = z0+1;
                allcount = allcount + 1.;
                i2 = i2+1;

                % calculate distance from center point and sort wrt distance
                l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + ((a.Depth - z)).^2 ) ;
                [s,is] = sort(l);
                b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

                % take first ni points
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance


                [bv magco stan av me mer me2,  pr] =  bvalca3(b,inb1,inb2);
                l2 = sort(l);
                zvg(x0,y0,z0) = bv;
                ra(x0,y0,z0) = l2(ni);

                zvg(x0,y0,z0) = (mean1 - mean2)/(sqrt(var1/(ncu-iwl)+var2/iwl));
                ra(x0,y0,z0) = l(ni);
                waitbar(allcount/itotal)
            end  % for z
            z0 = 0;
        end  % for y
        y0 = 0;
    end  % for x
    x0 = 0;

    % save data
    %
    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' zvg ra gx gy gz dx dy dz d par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    gz = -gz;
    zv2 = zvg;
    ac2 = 'new'; myslicer;

end  % if cal

