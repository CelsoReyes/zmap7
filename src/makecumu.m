%
%   This .m file creates a rectengular grid and calculates the
%   cumulative number curve at each grid point. The grid is
%   saved in a the file "cumugrid.mat". Operates on "a"

%
% define size of the area
%
echo on
% ________________________________________________________________________
%  Please use the left mouse button or the cursor to select the lower
%  left corner of the area of investigation. Please use the left
%  mouse again to select the upper right corner. The calculation might take
%  some time. This time can be reduced by using a smaller area and/or
%  a larger grid-spacing! The amount of calculation done will be displayed
%  in precent of the total time.
%
%_________________________________________________________________________
echo off

report_this_filefun(mfilename('fullpath'));

new = a;
as2 = [];
count = 0;
figure_w_normalized_uicontrolunits(1)
[x0,y0]  = ginput(1);
mark1 =    plot(x0,y0,'ro','era','normal')
set(mark1,'MarkerSize',10,'LineWidth',2.0)
[x1,y1]  = ginput(1);
f = [x0 y0 ; x1 y0 ; x1 y1 ; x0 y1 ; x0 y0];
fplo = plot(f(:,1),f(:,2),'r','era','normal');
set(fplo,'LineWidth',2)

gx = x0:dx:x1;
gy = y0:dy:y1;
itotal = length(gx) * length(gy);

%set(2,'pos',[ 0.01 0.9 0.4 0.2])
figure_w_normalized_uicontrolunits(2)
set(2,'pos',[ 0.1  0.1 0.4 0.3])
clf
set(gca,'visible','off')
txt1 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0.1 0.50 0 ],...
    'Rotation',0 ,...
    'FontSize',16 );
set(txt1,'String', '')
set(txt1,'String',  ' Please Wait...' )
pause(0.1)
%  make grid, calculate start- endtime etc.  ...
%
%[g1,g2] = meshgrid(gx,gy);
t0b = a(1,3) * 365/par1  + a(1,4)* 30./par1 + a(1,5)/par1;
n = a.Count;
teb = a(n,3) * 365/par1  + a(n,4)* 30 /par1 + a(n,5)/par1;
tdiff = round(teb - t0b);

cumu = 0:1:tdiff+2;
cumu2 = 0:1:tdiff-1;
ncu = length(cumu);
cumuall = zeros(tdiff+5,length(gx)*length(gy));

% loop over  all points
%
i2 = 0.;
i1 = 0.;
allcount = 0.
%
% longitude  loop
%
for x =  x0:dx:x1
    i1 = i1+ 1;

    % latitude loop
    %
    for  y = y0:dy:y1

        allcount = allcount + 1.;
        i2 = i2+1;
        % calculate distance from center point and sort wrt distance
        %
        a.Depth = sqrt((a.Longitude-x).^2 + (a.Latitude-y).^2) * 92.0;
        [s,is] = sort(a);
        new = a(is(:,7),:) ;       % re-orders matrix to agree row-wise
        % take first ni points
        %
        new = new(1:ni,:);      % new data per grid point is sorted in distance
        % re-sort wrt time for cumulative count
        %
        [st,ist] = sort(new);
        new = new(ist(:,3),:);
        b = new;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;
        % binning
        %
        n = length(b(:,1));
        t =  b(1:n,3) * 365/par1  + b(1:n,4)* 30 /par1 + b(1:n,5)/par1;
        t = (round(t - t0b)) ;

        for ii = 1:n
            if t(ii) > 0
                cumu(t(ii)) = cumu(t(ii)) + 1;
            end
        end

        cumuall(:,allcount) = [cumu';  x; y ];

    end  % for y0

    percent = allcount/itotal * 100	;
    set(txt1,'String', '')
    set(txt1,'String', [num2str(percent) ' Percent Done'] )
    pause(0.1)
    i2 = 0;
end  % for x0

%
% save data
%
save cumugrid.mat cumuall par1 ni dx dy gx gy tdiff


%[file1,path1] = uigetfile('*.mat','Save AS:',10,10);

echo  on
% ____________________________________________________________
%  The cumulative number file was saved in file 'cumugrid.mat'
%  Please rename the file if desired!
%
%_____________________________________________________________
echo off
txt3 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0.1 0.40 0 ],...
    'Rotation',0 ,...
    'FontSize',16);
set(txt1,'String', '');
set(txt1,'String', 'The cumulative no. curve was saved in file' );
set(txt3,'String', 'cumugrid.mat, please rename it if desired.' );

txt4 = text(...
    'EraseMode','normal',...
    'Position',[0. 0.30 0 ],...
    'Rotation',0 ,...
    'FontSize',16);
set(txt4,'String', 'Use button to calculate maximum Z-values (LTA)' );

uicontrol('Units','normal','Position',...
    [.9 .10 .1 .06],'String','Maxz ', 'Callback','diag1')


