report_this_filefun(mfilename('fullpath'));

warning off
% read isc data

% defines the data limitations
tmin   = 1960.0001;
tmax   = 1999.000;
lonmin = -180.0;
lonmax =  180.0;
latmin =  -90.00;
latmax =  90.0 ;
Mmin   = 4.5;
Mmax   = 10.;
mindep = -10;
maxdep = 9999;

%%%%%%%%%%%%%%%%
a = zeros(le,9);
c = 0;

def = {'400000'};
ni2 = inputdlg('Maximum number of events in catalog?','anput',1,def);
l = ni2{:};
le = str2double(l);

[file1,path1] = uigetfile([ '*'],' ISC Datafile');

[fid, mess] = fopen([path1 file1],'r');

for i = 1:le
    lin = fgets(fid);
    pr = lin(6);

    if pr == '*'
        try
            ma = lin(46:48);
        catch ME
            ma = [];
            error_handler(ME,@do_nothing);
        end
        if ~isempty(ma)
            ma = str2double(ma);

            if ma >= Mmin && ma <= Mmax
                c = c+1;

                a(c,6) = ma;
                a(c,3) = str2double(lin(7:10));
                a(c,4) = str2double(lin(12:13));
                a(c,5) = str2double(lin(15:16));
                a(c,8) = str2double(lin(18:19));
                a(c,9) = str2double(lin(21:22));
                a(c,2) = str2double(lin(26:30));
                if lin(32) == 'S' ; a(c,2) = -a(c,2); end
                a(c,1) = str2double(lin(34:39));
                if lin(40) == 'W' ; a(c,1) = -a(c,1); end

                try
                    a(c,7) = str2double(lin(42:44));
                catch ME
                    a(c,7) = nan;
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
    end


end

l = a.Date == 0;
a(l,:) = [];
a = a;
par1 = 14;
mainmap_overview()
fclose(fid)
