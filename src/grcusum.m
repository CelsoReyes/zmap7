%
%   This .m file creates a rectangular grid and calculates the
%   cumulative number curve at each grid point. The grid is
%   saved in the file "cumugrid.mat".
%                        Operates on catalogue "a"
%
% define size of the area
%
% ________________________________________________________________________
%  Please use the left mouse button or the cursor to select the lower
%  left corner of the area of investigation. Please use the left
%  mouse again to select the upper right corner. The calculation might take
%  some time. This time can be reduced by using a smaller area and/or
%  a larger grid-spacing! The amount of calculation done will be displayed
%  in percent of the total time.
%
%_________________________________________________________________________

report_this_filefun(mfilename('fullpath'));

selgp

bvg = [];
itotal = length(newgri(:,1));
if length(gx) < 2  ||  length(gy) < 2
    errordlg('Selection too small! (not a matrix)');
    return
end

close(gpf)
zmap_message_center.clear_message();;think
%  make grid, calculate start- endtime etc.  ...
%
t0b = a(1,3)  ;
n = a.Count;
teb = a(n,3) ;
tdiff = round((teb - t0b)*365/par1);

% loop over  all points
%
i2 = 0.;
i1 = 0.;
allcount = 0.;
%
% loop for all grid points

for i= 1:length(newgri(:,1))

    x = newgri(i,1);y = newgri(i,2);
    allcount = allcount + 1.;
    i2 = i2+1;
    % calculate distance from center point and sort wrt distance
    %
    l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
    [s,is] = sort(l);
    b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
    % take first ni points
    %
    l3 = l < 25;
    b = b(l3,:);      % new data per grid point (b) is sorted in distance
    if length(b(:,3)) >30;
        [st,ist] = sort(b);   % re-sort wrt time for cumulative count
        b = b(ist(:,3),:);
        ci = cusum2(b);
        j = find(abs(b(:,3)-86) == min(abs(b(:,3)-86))  ) ;
        j = min(j);
        bvg = [bvg ; ci(j)];
    else
        bvg = [bvg ; nan];
    end

end  % for x0


normlap2=ones(length(tmpgri(:,1)),1)*nan;
normlap2(ll)= bvg(:,1);
re3=reshape(normlap2,length(yvect),length(xvect));

vi_cusum

