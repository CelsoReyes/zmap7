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

report_this_filefun(mfilename('fullpath'));

selgp

itotal = length(newgri(:,1));
if length(gx) < 2  ||  length(gy) < 2
    errordlg('Selection too small! (not a matrix)');
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
cumuall = zeros(ncu,length(newgri(:,1)));
loc = zeros(3,length(newgri(:,1)));

% loop over  all points
%
i2 = 0.;
i1 = 0.;
allcount = 0.;
%
% loop for all grid points
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid - Percent completed');;
drawnow


x = newgri(:,1);y = newgri(:,2);
% calculate distance from center point and sort wrt distance
%
lea = a.Count;
lex = length(x(:,1));
al  = a.Longitude * ones(1,lex);
ala = a.Latitude * ones(1,lex);
alt = a.Date * ones(1,lex);
al  = (al' - x * ones(1,lea)) * cos(pi/180*mean(y)*111);
ala  = (ala' - y * ones(1,lea)) * 111;
l = sqrt(al.^2 + ala.^2);
[s,is] = sort(l);
l2 = is <= ni;
alt = reshape(alt(l2),ni,lea);
cumuall = [histogram(alt,t0b:par1/365:teb) ];

%cumuall(:,allcount) = [cumu';  x; l(ni,:)];
loc= [x ; y; s(:,ni)];

waitbar(allcount/itotal)


%
% save data
%
%  set(txt1,'String', 'Saving data...')
close(wai)
drawnow
%save cumugrid.mat cumuall par1 ni dx dy gx gy tdiff t0b teb loc

catSave3 =...
    [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
    ' [file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile'');',...
    ' sapa2 = [''save '' path1 file1 '' x y tmpgri newgri xvect yvect ll cumuall par1 ni dx dy gx gy tdiff t0b teb loc a main faults mainfault coastline''];',...
    ' if length(file1) > 1, eval(sapa2),end , done'];

eval(catSave3)

watchoff
zmapmenu
return

figure_w_normalized_uicontrolunits(mess)
clf
set(gca,'visible','off')

te = text(0.01,0.95,'The cumulative number array \newlinehas been saved in \newlinefile cumugrid.mat \newlinePlease rename it \newlineto protect if from overwriting.');
set(te,'FontSize',fontsz.m,'FontWeight','bold')

uicontrol('Units','normal','Position',...
    [.7 .10 .2 .12],'String','Options ', 'Callback','zmapmenu')

uicontrol('Units','normal','Position',...
    [.3 .10 .2 .12],'String','Back', 'Callback','welcome')

