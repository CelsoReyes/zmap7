function [X,map]=loadbmp(bmpfile)
    % LOADBMP  Load Microsoft Windows 3.x .BMP format image files.
    %
    %          [X,map]=LOADBMP(bmpfile) loads a .BMP format file specified by
    %          "bmpfile", returning the image data in variable "X" and the
    %          colormap in variable "map". The .BMP extension in the filename
    %          is optional.
    %
    %          Note: LOADBMP currently supports only uncompressed .BMP files
    %                with at most 256 colors.
    %
    %          See also SAVEBMP.

    %          Copyright (c) 1993 by
    %
    %          Ralph Sucher
    %          Dept. of Communications Engineering
    %          Technical University of Vienna
    %          Gusshausstrasse 25/389
    %          A-1040 Vienna
    %          AUSTRIA
    %
    %          Phone: +431-58801/3518
    %          Fax:   +431-5870583
    %          Email: rsucher@email.tuwien.ac.at

    report_this_filefun(mfilename('fullpath'));

    if nargin~=1
        error('LOADBMP takes one argument, which is the name of the .BMP file.');
    end

    if strfind(bmpfile,'.')==[]
        bmpfile=[bmpfile,'.bmp'];
    end

    fid=fopen(bmpfile,'rb','ieee-le');

    if fid==-1
        error('Can''t open .BMP file for input!');
    end

    % ------------------------------- BMP HEADER -------------------------------

    % read file identifier

    % bfType=fread(fid,1,'ushort');
    % if bfType~=19778
    %   fclose(fid);
    %   error('Not a valid .BMP file!');
    % end
    bfType=fread(fid,2,'char')';
    if ~all(bfType == 'BM')
        fclose(fid);
        error('Not a valid .BMP file!');
    end

    % read file length (bytes)
    status=fseek(fid,0,'eof');
    bfSize=ftell(fid);
    status=fseek(fid,6,'bof');

    % read bytes reserved for later extensions
    dummy=fread(fid,1,'long');

    % read offset from beginning of file to first data byte
    bfOffs=fread(fid,1,'long');

    % ----------------------------- BMP INFO-BLOCK -----------------------------

    % *** bitmap information header ***

    % read length of bitmap information header
    biSize=fread(fid,1,'long');

    % read width of bitmap
    biWidth=fread(fid,1,'long');

    % read height of bitmap
    biHeight=fread(fid,1,'long');

    % read number of color planes
    biPlanes=fread(fid,1,'ushort');

    % read number of bits per pixel
    biBitCnt=fread(fid,1,'ushort');
    nCol=2^biBitCnt;

    % read type of data compression
    biCompr=fread(fid,1,'long');
    if biCompr~=0
        fclose(fid);
        error('LOADBMP currently supports only uncompressed .BMP files!');
    end

    % read size of compressed image
    biSizeIm=fread(fid,1,'long');

    % read horizontal resolution (pixels/meter)
    biXPelsPerMeter=fread(fid,1,'long');

    % read vertical resolution (pixels/meter)
    biYPelsPerMeter=fread(fid,1,'long');

    % read number of used colors
    biClrUsed=fread(fid,1,'long');

    % read number of important colors
    biClrImportant=fread(fid,1,'long');

    % *** colormap ***

    MapLength=(bfOffs-54)/4;

    % read colormap
    map=zeros(4,MapLength);
    map(:)=fread(fid,MapLength*4,'uchar');
    map=map(3:-1:1,:)'/255;

    % ------------------------------ BITMAP DATA -------------------------------

    ndata=bfSize-bfOffs;
    Width=(ndata*8/biBitCnt)/biHeight;
    X=zeros(Width,biHeight);
    Xsize=Width*biHeight;

    data=fread(fid,ndata,'uchar');
    fclose(fid);

    if biBitCnt==1
        x=zeros(1,ndata);
        for i=1:8
            X(i:8:Xsize)=fix((data'-x)/2^(8-i));
            x=x+X(i:8:Xsize)*2^(8-i);
        end
    elseif biBitCnt==4
        X(1:2:Xsize)=fix(data/16);
        X(2:2:Xsize)=round(data'-X(1:2:Xsize)*16);
    elseif biBitCnt==8
        X(:)=data;
    elseif biBitCnt==24
        error('LOADBMP supports only images with at most 256 colors.');
    else
        error('This is not a valid .BMP file!');
    end

    X=X(1:biWidth,biHeight:-1:1)'+1;
