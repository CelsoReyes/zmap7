report_this_filefun(mfilename('fullpath'));

% now feed the endpoints one by one to mysectm
newa=[]; ma0 = [];
nlammap
po = length(b(1,:))+1;
for i=1:length(x)-1
    lat1 = y(i);lat2 = y(i+1);lon1 = x(i);lon2=x(i+1);
    ma0 = [ma0  deg2km(distance(lat1,lon1,lat2,lon2))]
    [xsecx xsecy,  inde] =mysectnoplo(tmp1,tmp2,b(:,7),wi,0,lat1,lon1,lat2,lon2);
    if sw =='on' ; xsecx = -xsecx +max(xsecx);end
    if i==1; ma = 0; else ; ma = ma0(i-1); end
    newa  = [newa ; b(inde,:) xsecx'+ma];
end
