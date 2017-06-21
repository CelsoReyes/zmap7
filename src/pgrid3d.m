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
    dx = 0.01;
    dy = 0.01 ;
    dz = 1.00 ;
    ni = 300;

    def = {num2str(maepi(1,3))};
    ni2 = inputdlg('Input Time of Mainshock ?','Input',1,def);
    l = ni2{:};
    mati = str2double(l);


    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 450 250]);
    axis off
    labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
    labelPos = [0.2 0.7  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');



    labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
    labelPos = [0.2 0.8  0.6  0.08];
    hndl1=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList,...
        'Callback','inb1 =get(hndl1,''Value''); ');


    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .32 .22 .10],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    freq_field4=uicontrol('Style','edit',...
        'Position',[.60 .22 .22 .10],...
        'Units','normalized','String',num2str(dz),...
        'Callback','dz=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(dz));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inb1 =get(hndl1,''Value'');inb2 =get(hndl2,''Value'');close,sel =''ca'', pgrid3d',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String','Automatically estimate magn. of completeness?   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.64 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.22 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in z (dz) in deg:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Number of Events (Ni):');
    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    selgp3d
    zvect=[min(a.Depth):dz:max(a.Depth)];
    gz = zvect;
    itotal = length(newgri(:,1))*length(gz);
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    bvg = ones(length(gx),length(gy),length(gz))*nan;
    pvg = ones(length(gx),length(gy),length(gz))*nan;
    pro = ones(length(gx),length(gy),length(gz))*nan;
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
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(a,inb1,inb2);
    bo1 = bv; no1 = a.Count;

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

                [st,ist] = sort(b);   % re-sort wrt time for cumulative count
                b = b(ist(:,3),:);


                % call the p-value function
                ttcat = b;
                [p,sdp,c,sdc,dk,sdk,aa,bb]=mypval2(3, mati);

                A = log10(av/dk)
                la = 0; c = 0.05;
                M = max(b(:,6)) - 5;
                if isnan(p) == 0
                    t0 = (-mati + max(b(:,3)))*365;
                    for t = t0:dt:t0+365
                        la = la + (10^(A + bv*(M)) * (t + c)^(-p))  *dt;
                    end
                    P = 1- exp(-la);
                else
                    P = nan;
                end
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);

                l2 = sort(l);
                bvg(x0,y0,z0) = bv;
                pvg(x0,y0,z0) = p;
                pro(x0,y0,z0) = P;
                ra(x0,y0,z0) = l2(ni);

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
        ' sapa2 = [''save '' path1 file1 '' bvg pvg pro ra gx gy gz dx dy dz dd par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    re3=bvg;
    r=ra;

    % View the p-value map
    %  view_b3d

end   % if sel = na

gz = -gz;



pv2 = pvg;
l = ra > 12.00;
pro(l)=nan;


figure
clf
[X,Y,Z] = meshgrid(gy,gx,gz);
[X2,Y2,Z2] = meshgrid(gy,gx,-5);
Z2 = X2*0-16 + (Y2 - mean(mean(Y2)))*15 + (X2 - mean(mean(X2)))*15;


zs = [-16 -12 -7 -1];
%sl = slice(X,Y,Z,pro,[mean(gy)] ,[ -118.6],zs);
clf
sl = slice(X,Y,Z,pro,X2,Y2,Z2);
hold on
sl = slice(X,Y,Z,pro,X2,Y2,Z2);


hold on
rotate3d on
caxis([0 0.3])
%set(gca,'XLim',[s1 s2],'xgrid','off')
%set(gca,'YLim',[s4 s3],'ygrid','off')
%set(gca,'ZLim',[ -max(a.Depth)-2 0 ],'zgrid','off')

shading interp
cob = colorbar('vert')
set(cob,'TickDir','out','pos',[0.8 0.3 0.07 0.3])
set(gca,'Box','on','vis','on')
tmp = ra*nan;
tmp(1,1,1) = 0;
tmp(1,1,2) = 1;
hold on
sl = slice(X,Y,Z,tmp,[mean(gy)] ,[ -118.6],zs);
caxis([0 0.4])
set(sl(:),'EdgeColor',[0.5 0.5 0.5]);
view([-36 10])
axis([min(gy) max(gy) min(gx) max(gx) min(gz) max(gz)]);
grid off
plot3(a.Latitude,a.Longitude,-a.Depth,'yo','MarkerSize',2)
hold on

main =  [ -118.5370   34.2133   94.0453    1.0000   17.0000    6.7000   18.4010];

epimax = plot3(main(:,2),main(:,1),-main(:,7),'hm');
set(epimax,'LineWidth',2.5,'MarkerSize',18,...
    'MarkerFaceColor','w','MarkerEdgeColor','r')
hold on
aft1 = [ -118.6700   34.3692   97.3163    4.0000   26.0000    5.1000   16.4510];
epimax = plot3(aft1(:,2),aft1(:,1),-aft1(:,7),'^m');
set(epimax,'LineWidth',2.5,'MarkerSize',16,...
    'MarkerFaceColor','w','MarkerEdgeColor','m')

whitebg(gcf)


