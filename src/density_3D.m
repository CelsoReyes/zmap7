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

    def = {'0.1','0.1',num2str(dz),num2str(max(a(:,7))), num2str(min(a(:,7)))};

    tit ='Three dimesional b-value analysis';
    prompt={ 'Spacing in Lat/Lon (dx in [deg])',...
        'Sample Raduis [km])',...
        'Spacing in Depth    (dz in [km ])',...
        'Depth Range: deep limit [km] ',...
        'Depth Range: shallow limit',...
        };


    ni2 = inputdlg(prompt,tit,1,def);

    l = ni2{1}; dx= str2num(l);dy = dx;
    l = ni2{2}; R= str2double(l);
    l = ni2{3}; dz= str2double(l);
    l = ni2{4}; z1= str2double(l);
    l = ni2{5}; z2= str2double(l);


    sel = 'ca'; density_3D


end   % if sel == 'in'

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    selgp3dB


    gz = zvect;
    itotal = length(t5);
    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    bvg = ones(length(gx),length(gy),length(gz))*nan;


    t0b = a(1,3)  ;
    n = length(a(:,1));
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3,length(gx)*length(gy));
    Rconst = R;
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
    for il =1:length(t5)

        x = t5(il,1);
        y = t5(il,2);
        z = t5(il,3);

        allcount = allcount + 1.;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + ((a(:,7) - z)).^2 ) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        l3 = l <= R;
        b = a(l3,:);      % new data per grid point (b) is sorted in distanc
        rd = length(b(:,1));


        bvg(t5(il,5),t5(il,6),t5(il,7)) = rd;

        waitbar(allcount/itotal)
    end  % for t5

    % save data
    %
    gz = -gz;
    zv2 = bvg;
    zvg = bvg;


    close(wai)
    watchoff

    sel = 'no';

    ButtonName=questdlg('Which viwer would you like to use?', ...
        'Question', ...
        'Slicer - map view','Slicer - 3D ','Help','none');


    switch ButtonName
        case 'Slicer - map view'
            slm = 'new'; slicemap;
        case 'Slicer - 3D '
            ac2 = 'new'; myslicer;
        case 'Help'
            showweb('3dbgrids')
    end % switch

    uicontrol('Units','normal',...
        'Position',[.90 .95 .04 .04],'String','Slicer',...
         'Callback','')

    %ac2 = 'new'; myslicer;

end  % if cal

