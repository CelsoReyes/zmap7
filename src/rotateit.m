if ~exist('lat1')
    errordlg('Create a cross-section first!');
else
    [lat1, lat2, lon1, lon2] = rotate_xsection(lat1, lat2, lon1, lon2, rotationangle);

    [xsecx xsecy,  inde] = mysect(tmp1,tmp2,a(:,7),wi,0,lat1,lon1,lat2,lon2);
    nlammap2;
end
