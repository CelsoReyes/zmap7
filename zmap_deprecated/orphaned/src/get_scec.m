report_this_filefun(mfilename('fullpath'));

warning off
% read isc data

% defines the data limitations
tmin   = 1975.0001;
tmax   = 2001.000;
lonmin = -130.0;
lonmax =  -110.0;
latmin =  30.00;
latmax =  38.0 ;
Mmin   = 1;
Mmax   = 10.;
mindep = -4;
maxdep = 9999;

%%%%%%%%%%%%%%%%
c = 0;

def = {'300000'};
ni2 = inputdlg('Maximum number of events in catalog?','anput',1,def);
l = ni2{:};
le = str2double(l);

a = zeros(le,10);

[file1,path1] = uigetfile([ '*.cat'],' SCEC *.cat Datafile');
drawnow;

[fid, mess] = fopen([path1 file1],'r');

for i = 1:le
    lin = fgets(fid);
    if length(lin) > 2 
        c = c+1;

        a(c,10) = str2double(lin(72:79));
        a(c,6) = str2double(lin(47:49));
        a(c,3) = str2double(lin(1:4));
        a(c,4) = str2double(lin(6:7));
        a(c,5) = str2double(lin(9:10));
        a(c,8) = str2double(lin(13:14));
        a(c,9) = str2double(lin(16:17));
        a(c,2) = str2double(lin(26:28)) + str2double(lin(29:33))/60 ;
        a(c,1) = str2double(lin(34:38)) - str2double(lin(39:44))/60 ;
        try
            a(c,7) = str2double(lin(55:59));
        catch ME
            a(c,7) = nan;
            error_handler(ME,@do_nothing); %track that this error happened
        end

        l =  a(c,6) >= Mmin & a(c,1) >= lonmin & a(c,1) <= lonmax & ...
            a(c,2) >= latmin & a(c,2) <= latmax & a(c,3) <= tmax   & ...
            a(c,7) >= mindep & a(c,7) <= maxdep & ...
            a(c,3) >= tmin  ;

        if l == 0
            a(c,:) = a(c,:)*0;
        end
        if rem(c,100) == 0; disp([ num2str(i) ' events scanned; ' num2str(c) ' events found ']); end

    end
end

l = a.Date == 0;
a(l,:) = [];
a.Date = decyear(a(:,[3:5 8 9]));
par1 = 14;
minmag = 8;
update(mainmap())
fclose(fid)
