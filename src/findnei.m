function [l,m] =  findnei(k)
    % This script finds overlapping alarms in space-time
    % and groups them together
    %
    % Stefan Wiemer    4/95
    global abo iala
    
    report_this_filefun(mfilename('fullpath'));
    
    d = sqrt(((abo(k,1) - abo(:,1))*cosd(34)*111).^2 + ((abo(k,2) - abo(:,2))*111).^2);
    m = d < abo(:,3)+abo(k,3) &  abs(abo(:,5)-abo(k,5)) < iala;
    l = find(m == 1);
    
end