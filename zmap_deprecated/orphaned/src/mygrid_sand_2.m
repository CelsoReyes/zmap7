% Function MYGRID_SAND	Read bathymetry data from Sandwell Database
%      [image_data,vlat,vlon] = mygrid_sand(region,iopt)
%
% program to get bathymetry from topo_8.2.img  (Smith and Sandwell bathymetry)
%  (values are even numbered if interpolated, odd-numbered if from a ship sounding)
% WARNING: change DatabasesDir to the correct one for your machine
%						Catherine de Groot-Hedlin
% latitudes must be between -72.006 and 72.006;
%	input:
%		region =[south north west east];
%               iopt = 1 if bathymetry is wanted (default)
%		       2 if ship tracks are wanted
%	output:
%		image_data
%                (for iopt = 1) - matrix of sandwell bathymetry/topography
%                (for iopt = 2) - matrix of ones and zeros, where 1 represents
%                    a ship location, 0 represents a depth based on interpolation
%		vlat - vector of latitudes associated with image_data
%      		vlon - vector of longitudes

%
function  [image_data,vlat,vlon] = mygrid_sand(region,iopt)

    DatabasesDir = '/export/home/grunion/cdh/airforce/sandwell.d';

    % determine the requested region
    blat = region(1);
    tlat = region(2);
    wlon = region(3);
    elon = region(4);

    % Setup the parameters for reading Sandwell data
    db_res         = 2/60;		% 2 minute resolution
    db_loc         = [-72.006 72.006 0.0 360-db_res];
    db_size        = [6336 10800];
    nbytes_per_lat = db_size(2)*2;	% 2-byte integers
    image_data     = [];

    % Determine if the database needs to be read twice (overlapping prime meridian)
    if ((wlon<0)&(elon>=0))
        wlon      = [wlon           0];
        elon      = [360-db_res  elon];
    end

    % Calculate number of "records" down to start (latitude) (0 to db_size(1)-1)
    % (mercator projection)
    rad=pi/180;arg1=log(tan(rad*(45+db_loc(1)/2)));
    arg2=log(tan(rad*(45+blat/2)));
    iblat = fix(db_size(1) +1 - (arg2-arg1)/(db_res*rad))

    arg2=log(tan(rad*(45+tlat/2)));
    itlat = fix(db_size(1) +1 - (arg2-arg1)/(db_res*rad))

    if (iblat < 0 ) | (itlat > db_size(1)-1)
        errordlg([' Requested latitude is out of file coverage ']);
    end

    % Go ahead and read the database
    for i = 1:length(wlon);

        % Open the data file
        fid = fopen([DatabasesDir '/topo_8.2.img'], 'r');
        if (fid < 0)
            errordlg(['Could not open database: ' DatabasesDir '/topo_8.2.img'],'Error');
        end

        % Make sure the longitude data goes from 0 to 360
        if wlon(i) < 0
            wlon(i) = 360 + wlon(i);
        end

        if elon(i) < 0
            elon(i) = 360 + elon(i);
        end

        % Calculate the longitude indices into the matrix (0 to db_size(1)-1)
        iwlon(i) = fix((wlon(i)-db_loc(3))/db_res)
        ielon(i) = fix((elon(i)-db_loc(3))/db_res)
        if (iwlon(i) < 0 ) | (ielon(i) > db_size(2)-1)
            errordlg([' Requested longitude is out of file coverage ']);
        end

        % allocate memory for the data
        data = zeros(iblat-itlat+1,ielon(i)-iwlon(i)+1);

        % Skip into the appropriate spot in the file, and read in the data
        disp('Reading in bathymetry data');
        for ilat = itlat:iblat
            offset = ilat*nbytes_per_lat + iwlon(i)*2;
            status = fseek(fid, offset, 'bof');
            data(iblat-ilat+1,:)=fread(fid,[1,ielon(i)-iwlon(i)+1],'integer*2');
        end

        % close the file
        fclose(fid);

        % put the two files together if necessary
        if (i>1)
            image_data = [image_data data];
        else
            image_data = data;
        end
    end

    % Determine the coordinates of the image_data
    vlat=zeros(1,iblat-itlat+1);
    arg2 = log(tan(rad*(45+db_loc(1)/2.)));
    for ilat=itlat+1:iblat+1;
        arg1 = rad*db_res*(db_size(1)-ilat+0.5);
        term=exp(arg1+arg2);
        vlat(iblat-ilat+2)=2*atan(term)/rad -90;
    end
    vlon=db_res*((iwlon+1:ielon+1)-0.5);
    % now choose between bathymetry and ship track
    if iopt==2
        image_data=mod(image_data,2);
    end
    % to plot it up
    if iopt ==2
        imagesc(vlon,vlat,image_data),axis('xy'),colormap(1-gray)
        title('ship track soundings')
    else
        imagesc(vlon,vlat,image_data),axis('xy'),colormap(jet),colorbar('vert')
        title('Smith and Sandwell bathymetry')
    end
    xlabel('longitude'),ylabel('latitude')

