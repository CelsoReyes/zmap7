%TODO delete or update this. Interacts with Fortran? -CGR
report_this_filefun(mfilename('fullpath'));

head     1.1;
access   ;
symbols  ;
locks    ; strict;
comment  @@;


1.1
date     99.03.26.16.08.11;  author stefan;  state Exp;
branches ;
next     ;


desc
@/newg
exit
@



1.1
log
@Initial revision
@
text
@
%
%   This .m file creates a rectangular grid and calculates the
%   cumulative number curve at each grid point. The grid is
%   saved in the file "cumugrid.mat".
%                        Operates on catalogue "a"
%
% define size of the area
%
% ________________________________________________________________________
%  Please use the left mouse button or the cursor to select the lower
%  left corner of the area of investigation. Please use the left
%  mouse again to select the upper right corner. The calculation might take
%  some time. This time can be reduced by using a smaller area and/or
%  a larger grid-spacing! The amount of calculation done will be displayed
%  in percent of the total time.
%
%_________________________________________________________________________
echo off

%delete existing outline
try
    delete(fplo, mark1)
catch
    disp(' ');
end
as2 = [];
count = 0;
figure_w_normalized_uicontrolunits(map)
zoom off
[x0,y0]  = ginput(1);
mark1 =    plot(x0,y0,'ro','era','normal')
set(mark1,'MarkerSize',10,'LineWidth',2.0)
[x1,y1]  = ginput(1);
f = [x0 y0 ; x1 y0 ; x1 y1 ; x0 y1 ; x0 y0];
fplo = plot(f(:,1),f(:,2),'r','era','normal');
set(fplo,'LineWidth',2)

if x0 > x1; temp = x1; x1 = x0; x0 = temp; end
if y0 > y1; temp = y1; y1 = y0; y0 = temp; end

gx = x0:dx:x1;
gy = y0:dy:y1;
gz = z0:dz:z1;

itotal = length(gx) * length(gy) *length(gz);
if length(gx) < 4  ||  length(gy) < 4
    errordlg('Selection too small! (Dx and Dy are in degreees! ');
    return
end

close(gpf)
zmap_message_center.clear_message();;think
%  make grid, calculate start- endtime etc.  ...
%
t0b = min(a.Date)  ;
n = a.Count;
teb = a(n,3) ;
tdiff = round((teb - t0b)*365/par1);
cumu = zeros(length(t0b:par1/365:teb)+2);
ncu = length(cumu);
cumuall = zeros(ncu,length(gx)*length(gy)*length(gz));
loc = zeros(4,length(gx)*length(gy)*length(gz));

% loop over  all points
%
i2 = 0.;
i1 = 0.;
allcount = 0.;
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');;
drawnow
%
% longitude  loop
%
for x =  x0:dx:x1
    i1 = i1+ 1;

    % latitude loop
    %
    for  y = y0:dy:y1

        % depth loop
        for z = z0:dz:z1

            allcount = allcount + 1.;
            i2 = i2+1;
            % calculate distance from center point and sort wrt distance
            %
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + (a.Depth-z).^2) ;
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            % take first ni points
            %
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

            [st,ist] = sort(b);   % re-sort wrt time for cumulative count
            b = b(ist(:,3),:);
            cumu = cumu * 0;
            % time (bin) calculation

            n = length(b(:,1));
            cumu = histogram(b(1:n,3),t0b:par1/365:teb);
            %
            % end

            l = sort(l);
            cumuall(:,allcount) = [cumu';  x; l(ni)];
            loc(:,allcount) = [x ; y; z;  l(ni)];

            waitbar(allcount/itotal)
        end  % for z0

    end  % for y0

    i2 = 0;
end  % for x0

%
% save data
%
%  set(txt1,'String', 'Saving data...')
drawnow
%save cumugrid.mat cumuall par1 ni dx dy gx gy tdiff t0b teb loc

catSave3 =...
    [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
    '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile'');',...
    ' sapa2 = [''save '' path1 file1 '' cumuall par1 ni dx dy gx gy tdiff t0b teb loc a main faults mainfault coastline''];',...
    ' if length(file1) > 1, eval(sapa2),end , done'];

eval(catSave3)

close(wai)
watchoff
zmapmenu
return

figure_w_normalized_uicontrolunits(mess)
clf
set(gca,'visible','off')

te = text(0.01,0.95,'The cumulative number array \newlinehas been saved in \newlinefile cumugrid.mat \newlinePlease rename it \newlineto protect if from overwriting.');
set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')

uicontrol('Units','normal','Position',...
    [.7 .10 .2 .12],'String','Options ', 'Callback','zmapmenu')

uicontrol('Units','normal','Position',...
    [.3 .10 .2 .12],'String','Back', 'Callback','welcome')

@
