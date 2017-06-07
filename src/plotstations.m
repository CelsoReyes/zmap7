

report_this_filefun(mfilename('fullpath'));


st1 = [' In order to plot stations plus station names on top of a map'...
    ' please prepare a file with: lat, long , Name. These varables must be in column (1-10), (11-23), and after 23 to be read '...
    ' correctely  (e.g.:"   33.16660  -116.35390     YAQ  ")' ];

uiwait(msgbox(st1,'Plotting stations','modal'));

str = [];
[newmatfile, newpath] = uigetfile([ hodo '*'], 'Name of station file'); %disabled window positioning

fid = fopen([newpath newmatfile],'r') ;
axes(h1)
hold on
dx = abs(s1-s2)/130
nam0 = 'none';
while isempty(ferror(fid))
    li = fgets(fid)
    le = length(li)
    lat = str2double(li(1:10));
    lon = str2double(li(11:23));
    nam =  (li(25:le));
    if ~strcmp(nam,nam0)
        disp('I draw')
        nam0 = nam;
        pl = plot(lon,lat,'^k','era','back');
        set(pl,'LineWidth',1.,'MarkerSize',6,...
            'MarkerFaceColor','k','MarkerEdgeColor','k');
        te1 = text(lon+dx,lat,nam,'era','back','clipping','on');
        set(te1,'FontWeight','bold','Color','k','FontSize',9);
        drawnow
    end
end
fclose(fid);





