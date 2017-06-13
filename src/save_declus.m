report_this_filefun(mfilename('fullpath'));
org2 = a;
hodis = fullfile(hodi, 'external');
do = ['cd  ' hodis ]; eval(do)

str = [];

s = [  floor(a(:,3))  a(:,4)  a(:,5) a(:,8) a(:,9) a(:,6)   a(:,2)  a(:,1)  a(:,7)   ];
fid = fopen(['data'],'w') ;;
fprintf(fid,'%4.0f%2.0f%2.0f%2.0f%2.0f  %3.1fmb%7.3f%8.3f%5.1fA\n',s');
fclose(fid);
clear s

s = [taumin*60*24 taumax*60*24 P xk xmeff rfact err derr ];
fid = fopen(['para.dat'],'w') ;;
fprintf(fid,'%5.0f  %5.0f  %5.3f  %5.3f  %5.3f  %5.3f  %5.3f  %5.3f\n',s');
fclose(fid);
clear s

% This executes the clus.exe FORTRAN code
unix(['.' fs 'myclus ']);

%open datafile
fid = 'outf.clu';

try
    format = ['%12c %3f %f %f %f %d'];
    [dat,mag,lat,lon,dep,clu] = ...
        textread(fid,format,'whitespace',' \b\r\t\n mb A ');
catch
    l = lasterr;
    l1 = strfind(l,',');
    anz = str2double(l(53:l1-1));
    [dat,mag,lat,lon,dep,clu] = ...
        textread(fid,format,anz-1,'whitespace',' \b\r\t\n mb A ');
    disp(['Error in Line ' num2str(anz) ' read only lines  1 - ' num2str(anz-1) ]);

end


%transform data to ZMAP format
watchon;
disp('Reloading data ...')

yr =   str2double(dat(:,1:4));
mo=  str2double(dat(:,5:6));
da=  str2double(dat(:,7:8));
hr=  str2double(dat(:,9:10));
mi=  str2double(dat(:,11:12));

a = [lon lat a(:,3) mo da mag org2(:,7) hr mi clu];

cluslength=[];
n=0;
k1=max(clu);
for j=1:k1                         %for all clusters
    cluslength(j)=length(find(clu==j));  %length of each clusters
end

tmp=find(cluslength);      %numbers of clusters that are not empty

%cluslength,bg,mbg only for events which are not zero
cluslength=cluslength(tmp);

clustnumbers=(1:length(tmp));    %stores numbers of clusters
l = a(:,10) > 0;
clus = a(l,:);
a(l,:) = [];

% plot the results
mainmap_overview()
hold on
plot(clus(:,1),clus(:,2),'m+');

st1 = [' The declustering found ' num2str(max(clu)) ' clusters of earthquakes, a total of '...
    ' ' num2str(length(clus(:,1))) ' events (out of ' num2str(length(org2(:,1))) '). '...
    ' The map window now display the declustered catalog containing ' num2str(length(a(:,1))) ' events . The individual clusters are displayed as magenta o in the map. ' ];

msgbox(st1,'Declustering Information')
watchoff;




