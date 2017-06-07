report_this_filefun(mfilename('fullpath'));

dx = uiInput1 ;
dy = dx;
gx = x0:dx:x1;
gy = y0:dy:y1;
itotal = length(gx) * length(gy);


[g1,g2] = meshgrid(gx,gy);
t0b = a(1,3) * 365/par1  + a(1,4)* 30./par1 + a(1,5)/par1;
n = length(a(:,1));
teb = a(n,3) * 365/par1  + a(n,4)* 30 /par1 + a(n,5)/par1;
tdiff = round(teb - t0b);
cumu = 0:1:tdiff+2;
cumu2 = 0:1:tdiff-1;
ncu = length(cumu);
cumuall = zeros(tdiff+5,length(gx)*length(gy));


i2 = 0.;
i1 = 0.;
allcount = 0.
for x =  x0:dx:x1
    i1 = i1+ 1;
    for  y = y0:dy:y1
        allcount = allcount + 1.;
        percent = allcount/itotal * 100
        i2 = i2+1;
        a(:,7) = sqrt((a(:,1)-x).^2 + (a(:,2)-y).^2) * 92.0;
        [s,is] = sort(a);
        new = a(is(:,7),:) ;
        newt = new(1:ni,:);
        [st,ist] = sort(newt);
        newt2 = newt(ist(:,3),:);
        b = newt2;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;

        n = length(b(:,1));
        t =  b(1:n,3) * 365/par1  + b(1:n,4)* 30 /par1 + b(1:n,5)/par1;
        t = (round(t - t0b)) ;
        for ii = 1:n
            if t(ii) > 0
                cumu(t(ii)) = cumu(t(ii)) + 1;
            end
        end

        cumuall(:,allcount) = [cumu';  x; y ];

    end  % for y0
    i2 = 0;
end  % for x0
%save cumugrid.mat cumuall par1 ni dx dy gx gy tdiff

[file1,path1] = uigetfile('*.mat','Save AS:',10,10);
save(file1)

