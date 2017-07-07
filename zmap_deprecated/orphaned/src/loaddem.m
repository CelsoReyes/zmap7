%  Matlab script to read DEM 3 arc seconds file.
%
%  Creates the following variables:
%    elev: elevation data (row = lat; col = lon)
%    xv: longitude vector
%    yv: latitude vector
%    clat & clon: SouthEast corner latitude and longitude of the file

%  Written 27 Nov 96  by Guy Tytgat

report_this_filefun(mfilename('fullpath'));

[file,path] = uigetfile('*','Select a .3CD file',300,300);

if file == []
    disp('Error selecting file')
    clear file path
    return
elseif file == 0
    disp('No file selected')
    clear file path
    return
end

filename = sprintf('%s%s',path,file);
[fid,message2] = fopen(filename);
if file(7:9) ~= '3cd'
    error('Wrong file type selected')
    return
end

nrow = 1201;
clat = str2double(file(1:2));
clon = str2double(file(3:5));

if fid ~= -1
    if clat < 50
        ncol = 1201;
    elseif (50 <= clat)  &&  (clat < 70)
        ncol = 601;
    elseif (70 <= clat)  &&  (clat < 75)
        ncol = 401;
    elseif (75 <= clat)  &&  (clat < 80)
        ncol = 301;
    elseif (80 <= clat)  &&  (clat <= 90)
        ncol = 201;
    else
        error('Incorrect file type selected')
        return
    end

    elev = ones([nrow,ncol]);
    [elev, count] = fread(fid,[nrow,ncol],'short');
    if (nrow*ncol) ~= count
        disp('WARNING: Not all data points were read')
    end

    xv = -(clon+1):1/ncol:-clon;
    yv = clat:1/nrow:clat+1;
    clear count fid file filename message2 ncol nrow path
else
    clear fid file filename message2 clat clon path nrow
end
