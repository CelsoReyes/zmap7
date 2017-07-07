%open datafile
fid = 'c:\Samuel\outf.clu';

format = ['%12c %3f %f %f %f %d'];
[dat,mag,lat,lon,dep,clu] = ...
    textread(fid,format,'whitespace',' \b\r\t\n mb A ');


%transform data to ZMAP format
p = 9; %number of columns in ZMAP
c = zeros(size(dat,1),p);

for i = 1:size(dat,1)

    c(i,1) = lon(i);
    c(i,2) = lat(i);
    c(i,3) = str2double(dat(i,1:4));
    c(i,4) = str2double(dat(i,5:6));
    c(i,5) = str2double(dat(i,7:8));
    c(i,6) = mag(i);
    c(i,7) = dep(i);
    c(i,8) = str2double(dat(i,9:10));
    c(i,9) = str2double(dat(i,11:12));

end

save clust_conv c
save clu clu
