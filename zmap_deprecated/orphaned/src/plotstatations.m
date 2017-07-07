

report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] = uigetfile([ hodo '*'], 'Name of station file'); %disabled positioning of window

fid = fopen([newpath newmatfile],'r') ;
axes(h1)
hold on
dx = abs(s1-s2)*100;

while ferror(fid) == ''
    li = fgets(fid)
    le = length(li)
    lat = num2str(li(1:10));
    lon = num2str(li(11:23));
    nam =  (li(25:le));

    pl = plot(lon,lat,'^r');
    set(pl,'LineWidth',1.,'MarkerSize',6,...
        'MarkerFaceColor','w','MarkerEdgeColor','k');
    te1 = text(lat, lon+dx,nam); %best-guess fix from "text(lat lon+dx),nam)"-CGR
    set(te1,'FontWeight','bold','Color','k','FontSize',9,'Clipping','on');

end

fclose(fid);





