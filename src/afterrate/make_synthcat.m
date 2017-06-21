% produces synthetic Omori aftershock sequence using given epicentres
% Omori parameters can be chosen arbitraily
%
% Samuel Neukomm, 27.2.2004

[filename,pathname] = uigetfile('*.mat','Load earthquake sequence');
do = ['load ' pathname filename]; eval(do)

lon = a.Longitude; lat = a.Latitude; mag = a.Magnitude; dep = a.Depth;
[m_main, main] = max(a.Magnitude);
if size(a,2) == 9
    date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,zeros(size(a,1),1));
else
    date_matlab = datenum(a.Date.Year,a.Date.Month, a.Date.Day,a.Date.Hour,a.Date.Minute,a(:,10));
end

date_main = date_matlab(main);
time_aftershock = date_matlab-date_main;

l = time_aftershock(:) > 0;
t_aftershock = time_aftershock(l);
eqcatalogue = a.subset(l);

ncum = (1:length(t_aftershock))';

prompt = {'p value:','c value:','k value:'};
def = {'0.9','0.05','1000'};
dlgTitle = 'Choose Omori parameters';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);

pv = str2double(answer{1});
cv = str2double(answer{2});
kv = str2double(answer{3});

tasnew = (cv^(1-pv)-ncum*(pv-1)/kv).^(1/(1-pv))-cv;

date_mat_new = tasnew + date_main;
[yr,mon,day,hr,mn,sec] = datevec(date_mat_new);

datum = [yr mon day hr mn sec];
yr = decyear(datum);

if size(a,2) == 9
    a = [a(main,:) 0; eqcatalogue(:,1) eqcatalogue(:,2) yr mon day eqcatalogue(:,6) eqcatalogue(:,7) hr mn sec];
else
    a = [a(main,1:10); eqcatalogue(:,1) eqcatalogue(:,2) yr mon day eqcatalogue(:,6) eqcatalogue(:,7) hr mn sec];
end

[filename, pathname] = uiputfile('*.mat', 'Save synthetic catalog as');

try
    save(fullfile(pathname, filename),'a','pv','cv','kv');
catch
    disp('failed to save'); %complain
end