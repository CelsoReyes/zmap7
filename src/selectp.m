function selectp(in_or_out)
%  This .m file selects the earthquakes within a polygon
%  and plots them. Sets "a" equal to the catalogue produced after the
%  general parameter selection. Operates on "org2", replaces "a"
%  with new data and makes "a" equal to newcat
%
%   operates on main map window
% plot tags:
%  'poly_selected_events' : earthquakes in/out of polygon
%  'mouse_points_overlay' : polygon outline

global a newcat org2 newt2 hoda
echo on
% ___________________________________________________________
%  Please use the left mouse button or the cursor to select
%  the polygon vertexes.
%
%  Use the right mouse button to select the final point.
%_____________________________________________________________
report_this_filefun(mfilename('fullpath'));
echo off
%zoom off
newt2 = [ ];           % reset catalogue variables
%a = org2;              % uses the catalogue with the pre-selected main
% general parameters
newcat = a;

delete(findobj('Tag','mouse_points_overlay'));
delete(findobj('Tag','poly_selected_events'));

messtext=...
    ['To select events inside a polygon.        '
    'Please use the LEFT mouse button or the   '
    'character P to select the polygon vertexes'
    'Use the RIGHT mouse button for the final  '
    'point.  Mac Users: use the keybord:       '
    ' p: more points, l: lst point             '
    'Operates on the original catalogue        '
    'producing a reduced  subset which in turn '
    'the other routines operate on.            '];

welcome('Select EQ in Polygon',messtext);


% pick polygon points, 
ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);

welcome('Message',' Thank you .... ')
if ~exist('in_or_out','var')
    in_or_out = 'inside';
end
mask = polygon_filter(x,y, a(:,1), a(:,2), in_or_out);
newt2 = a(mask,:);


% Plot of new catalog
%
plos1 = plot(ax,newt2(:,1),newt2(:,2),'xg','Tag','poly_selected_events','DisplayName','event subset');

xy = [x y];

%save polcor.dat xy -ascii
[file1,path1] = uiputfile([hoda '*.txt'],'Save Polygon ? (yes/cancel)');
if length(file1) > 1
    if length(file1)>3
        if strcmp(file1(length(file1)-3:length(file1)),'.txt')==0
            file1=[file1 '.txt']
        end
    end
    %bollocks, changed it to a normal command
    %sapa2 = ['save ' path1 file1  '  xy -ascii '] ;
    %eval(sapa2)
    save([path1 file1],'xy', '-ascii');
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%   The new catalog (newcat) with points only within the
%   selected Polygon is created and resets the original
%   "a" .
disp(' The selected polygon was saved in the file polcor.dat')
%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++

newcat = newt2;                   % resets newcat and newt2

timeplot

h=zmap_message_center;
h.update_catalog();