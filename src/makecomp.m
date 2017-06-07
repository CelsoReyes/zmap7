report_this_filefun(mfilename('fullpath'));

% Lets make sure the file is closed...
try
    fclose(fid);
catch ME
    error_handler(ME, @do_nothing);
end

% reset paramteres
a = []; b = []; n = 0; new = [];
fid = fopen('/home/stefan/ZMAP/eq_data/new.sum','r') ;
while  ferror(fid) == ''
    n = n+1;
    % vari name   yr mo da hr mi se lat   la  lon    lo de ma1
    % variabl #   1  2  3  4  5  6  7      8  9      10 11 12
    % position    2  4  6  8  10 14 16 17  21 24 25  29 34 36
    l = fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d',...
        [12 10000]) ;
    %if ferror(fid) ~= '' ; break; end

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ; l(1,:);l(2,:);l(3,:);
        l(12,:)/10;l(11,:)/100;l(4,:);l(5,:)];
    b = b';
    new = [new ; b(:,:)];
    disp([ num2str(n*10000) ' earthquakes scanned, ' num2str(length(new)) ' EQ found'])
end
ferror(fid)
fclose(fid);


% Convert the third column into time in decimals
new(:,3) = decyear(new(:,[3:5 8 9]));


old = []; b = []; n = 0;
fid = fopen(['/home/stefan/ZMAP/eq_data/old.sum'],'r') ;;
while  ferror(fid) == ''
    n = n+1;
    % vari name   yr mo da hr mi se lat   la  lon    lo de ma1
    % variabl #   1  2  3  4  5  6  7      8  9      10 11 12
    % position    2  4  6  8  10 14 16 17  21 24 25  29 34 36
    l = fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d',...
        [12 10000]) ;
    %if ferror(fid) ~= '' ; break; end

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ; l(1,:);l(2,:);l(3,:);
        l(12,:)/10;l(11,:)/100;l(4,:);l(5,:)];
    b = b';
    old = [old ; b(:,:)];
    disp([ num2str(n*10000) ' earthquakes scanned, ' num2str(length(old)) ' EQ found'])
end
ferror(fid)
fclose(fid);

% Convert the third column into time in decimals
new(:,3) = decyear(new(:,[3:5 8 9]));

% call the map window
a = new;
subcata


% calculate the distance between the events in km

las = mean(new(:,2));
l = sqrt(((new(:,1)-old(:,1))*cos(pi/180*las)*111).^2 + ((new(:,2)-old(:,2))*111).^2) ;
dx = (new(:,1)-old(:,1))*cos(pi/180*las)*111;
dy = (new(:,2)-old(:,2))*111;
al = atan(dx./dy);

figure

orient tall
clf
% compare the magnitudes
rect = [0.20 0.70 0.55 0.250];
axes('position',rect)
histogram((new(:,6)-old(:,6)),-0.5:0.10:0.5);
set(gca,'XLim',[-0.4 0.4])
xlabel('Mag')


% compare the depth
rect = [0.20 0.375 0.55 0.25];
axes('position',rect)
histogram((new(:,7)-old(:,7)),-20:0.2:20.);
set(gca,'XLim',[-10. 10.])
xlabel('Depth')

% compare the distance
rect = [0.20 0.05 0.55 0.25];
axes('position',rect)
histogram(l,0:0.5:20);
set(gca,'XLim',[0. 15.])
xlabel('Distance')


a = new;
ty1 = 'o'; ty2 = 'o'; ty3 = 'o';
ms6 = 3; co = 'k';

subcata
hold on
plot(old(:,1),old(:,2),'xk')

for i = 1:length(new(:,1))
    plot([new(i,1) old(i,1)],[new(i,2) old(i,2)],'r')
end
