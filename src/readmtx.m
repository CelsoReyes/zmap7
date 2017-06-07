function data = readmtx(filename,nrows,ncols,precision,readrows,readcols,machineformat,nheadbytes,nRowHeadBytes,nRowTrailBytes,nFileTrailBytes,recordlen)

    %READMTX read a matrix stored in a file
    %
    %  mtx = READMTX(filename,nrows,ncols,precision) reads a matrix stored in a
    %  file.  The file contains only a matrix of numbers with the dimensions
    %  nrows by ncolumns stored with the specified precision.  Recognized
    %  precision strings are described below.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols) reads a subset
    %  of the matrix.  readrows and readcols specify which rows and columns are
    %  to be read.  They can be vectors containing the row or column numbers, or
    %  two-element row vectors of the form [start end], which are expanded using
    %  the colon operator to start:1:end. To read just two noncontiguous rows or
    %  columns, provide the indices as a column matrix.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols,machineformat)
    %  specifies the format used to write the file. machineformat can be any
    %  string recognized by FOPEN. This option is used to automatically swap
    %  bytes for file written on platforms with a different byte ordering.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols,machineformat,...
    %  nheadbytes) skips the file header, whose length is specified in bytes.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols,machineformat,...
    %  nheadbytes,nRowHeadBytes) also skips a header which precedes every row of
    %  the matrix.  The length of the header is specified in bytes.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols,machineformat,...
    %  nheadbytes,nRowHeadBytes,nRowTrailBytes) also skips a trailer which
    %  follows every row of the matrix.  The length of the trailer is
    %  specified in bytes.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols,machineformat,...
    %  nheadbytes,nRowHeadBytes,nRowTrailBytes,nFileTrailBytes) accounts for the
    %  length of data following the matrix. The sizes of the components of the
    %  matrix are used to compute an expected file size, which is compared to
    %  the actual file size.
    %
    %  READMTX(filename,nrows,ncols,precision,readrows,readcols,machineformat,...
    %  nheadbytes,nRowHeadBytes,nRowTrailBytes,nFileTrailBytes,recordlen)
    %  overrides the record length calculated from the precision and number of
    %  columns, and instead uses the record length given in bytes. This is used
    %  for formatted data with extra spaces or line breaks in the matrix.
    %
    %  This function reads both binary and formatted data files.  If the file is
    %  binary, the precision argument is a format string recognized by FREAD.
    %  Repetition modifiers such as '40*char' are NOT supported.
    %
    %  If the file is formatted with a fixed format (the number of characters per
    %  number is fixed), precision is a FSCANF and SSCANF-style format string of
    %  the form '%nX', where n is the number of characters within which the
    %  formatted data is found, and X is the conversion character such as g or d.
    %  Fortran-style double precision output such as '0.0D00' may be read using a
    %  precision string such as '%nD', where n is the number of characters per
    %  element.  This is an extension to the C-style format strings accepted by
    %  SSCANF. Formatted files with line endings need to provide the number of
    %  trailing bytes per row, which may be 1 for platforms with carriage returns
    %  OR linefeed (Macintosh, Unix) , or 2 for platforms with carriage returns
    %  AND linefeeds (DOS).
    %
    %  This function also reads formatted files with a variable number of
    %  characters per row. Use a precision string of the form '%X', where
    %  X is the conversion character such as g or d.  Users unfamiliar with
    %  C should note that '%d' is preferred over '%i' for formatted integers,
    %  because Matlab follows C in interpreting '%i' integers with leading zeros
    %  as octal. All values for a row of the matrix must be stored within a single
    %  record (no line breaks within a row).
    %
    %  See also READFIELDS, TEXTREAD, SPCREAD, DLMREAD

    % Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    % $Revision: 1399 $  $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    % Parse input arguments

    if nargin == 4
        readrows = [1 nrows];
        readcols = [1 ncols];
        machineformat = 'native';
        nheadbytes = 0;
        nRowHeadBytes = 0;
        nRowTrailBytes = 0;
        nFileTrailBytes = 0;
        recordlen = [];
    elseif nargin == 6
        machineformat = 'native';
        nheadbytes = 0;
        nRowHeadBytes = 0;
        nRowTrailBytes = 0;
        nFileTrailBytes = 0;
        recordlen = [];
    elseif nargin == 7
        nheadbytes = 0;
        nRowHeadBytes = 0;
        nRowTrailBytes = 0;
        nFileTrailBytes = 0;
        recordlen = [];
    elseif nargin == 8
        nRowHeadBytes = 0;
        nRowTrailBytes = 0;
        nFileTrailBytes = 0;
        recordlen = [];
    elseif nargin == 9
        nRowTrailBytes = 0;
        nFileTrailBytes = 0;
        recordlen = [];
    elseif nargin == 10
        nFileTrailBytes = 0;
        recordlen = [];
    elseif nargin == 11
        recordlen = [];
    elseif nargin ~= 12
        error('Incorrect number of arguments')
    end


    % Catch a case with readrows = n, which needs to be [n n];

    if all(size(readrows) == [1 1]); readrows = [readrows readrows]; end
    if all(size(readcols) == [1 1]); readcols = [readcols readcols]; end

    % Catch a case [ n; n], which really means [n n];

   if all(size(readrows) == [2 1])  && diff(readrows) == 0; readrows = readrows'; end
   if all(size(readcols) == [2 1])  && diff(readcols) == 0; readcols = readcols'; end

    % Check for proper inputs

  if ~all(size(readrows) == [1 2])  && ~(min(size(readrows)) == 1  && length(readrows) > 2 )  &&  ~all(size(readrows) == [2 1])
        error('readrows must be a vector of the form row number, [start end], start:step:end or [row1; row2]')
    end
  if ~all(size(readcols) == [1 2])  && ~(min(size(readcols)) == 1  && max(size(readcols)) > 2 )   &&  ~all(size(readcols) == [2 1])
        error('readcols must be a vector of the form column number, [start end], start:step:end or [col1; col2]')
    end


    % Check for reads of block of data

   if (length(readrows) == 2  && all(size(readrows) == [1 2])) | ...
            (length(readrows) > 2 & max(diff(readrows)) == 1)
        rowstep = 1; % read every record sequentially
    else
        rowstep = NaN;
    end

   if (length(readcols) == 2  && all(size(readcols) == [1 2]) ) | ...
            (length(readcols) > 2 & max(diff(readcols)) == 1)
        colstep = 1; % read every field sequentially
    else
        colstep = NaN;
    end

    % Open file
    if isempty(filename)
        [filename,filepath] = uigetfile('*','Select the file');
        filename = [filepath,filename];
    end

    fid = fopen(filename,'rb', machineformat);

    if fid == -1
        [filename,filepath] = uigetfile(filename,['Where is ',filename,'?']);
        if filename == 0 ; data = []; return; end
        fid = fopen([filepath,filename],'rb', machineformat);
    end


    % Find end of file

    fseek(fid,0,1);
    eof = ftell(fid);
    fseek(fid,0,-1);
    pos = ftell(fid);

    % Identify length of a field and record in bytes

    [fieldlen,datatype] = fieldlength(precision,fid);

    if isempty(recordlen)
        recordlen = nRowHeadBytes + fieldlen*ncols + nRowTrailBytes;
    end

    % Sizes of steps between things

   if length(readrows) == 2  && all(size(readrows) == [1 2]);
        rowskip = 1;
        nrowread = readrows(end)-readrows(1)+1;
    else
        rowskip = readrows(2)-readrows(1);  								% correct when used in vectorized read
        nrowread = length(readrows);
    end

   if length(readcols) == 2  && all(size(readcols) == [1 2]);
        colskip = 1;
        ncolread = readcols(end)-readcols(1)+1;
    else
        colskip = readcols(2)-readcols(1); 									% correct when used in vectorized read
        ncolread = length(readcols);
    end


    % Check that the inputs square with the file size if fixed length records
    % expectedfilesize = nheadbytes + nrows*(nRowHeadBytes + fieldlen*ncols + nRowTrailBytes) + nFileTrailBytes;

    switch datatype
        case {'binary', 'formatted, fixed length'}
            expectedfilesize = nheadbytes + nrows*recordlen + nFileTrailBytes;
            if (expectedfilesize ~= eof);
                fclose(fid);
                error(sprintf(['File size does not match inputs. Expected \n' ...
                    num2str(expectedfilesize) ...
                    ' bytes, but file size is ' num2str(eof) ' bytes'] ))
            end
    end

    % If possible, do a vectorized read, otherwise read a row at a time.

    if ( ...
            (rowstep == 1 & colstep == 1) | ... 									% every value
            (colstep == 1 & size(unique(diff(readrows))) == [1 1]) ...  			% runs of data fields, with constant skips in record number
            ) ...
            & ...
            isempty(findstr('%',precision))										% not a formatted (fscanf) read

        byteskip = 	nheadbytes + ... 										% skip header
            (readrows(1)-1)*recordlen + ... 						% skip undesired records
            nRowHeadBytes + fieldlen*(readcols(1)-1) ;				% skip undesired fields in the first desired field

        fseek(fid,byteskip,'bof'); 											% reposition to just before the first desired record

        byteskip = fieldlen*(ncols-readcols(end)) + nRowTrailBytes + ... 	% remainder of data in record
            (rowskip-1)*recordlen + ...								% undesired records
            nRowHeadBytes + fieldlen*(readcols(1)-1); 				% skip undesired fields in the next desired record


        [data,count] = fread(fid,nrowread*ncolread,[num2str(ncolread) '*' precision], byteskip);
        if count ~= nrowread*ncolread;
            error('Incorrect number of values read')
        end

        data = (reshape(data,ncolread,length(data)/ncolread))';

    else	% unvectorized read



        data = NaN*ones(nrowread,ncolread); 								% preallocate matrix to avoid time consuming malloc

        % Expand [start end] row and column specifications

        if all(size(readrows) == [1 2]); readrows = readrows(1):readrows(2); end
        if all(size(readcols) == [1 2]); readcols = readcols(1):readcols(2); end

        % different methods depending on whether data is formatted, or if field lengths are variable

        switch datatype

            case 'binary'  % unformatted (fread)


                for i=1:nrowread

                    byteskip = 	nheadbytes + ... 									% skip header
                        (readrows(i)-1)*recordlen + ... 					% skip undesired records
                        nRowHeadBytes;

                    fseek(fid,byteskip,'bof'); 										% reposition to just before the first desired record

                    [rowdata,count] = fread(fid,ncols,precision); 					% the whole record
                    if count ~= ncols
                        error('Incorrect number of values read')
                    end

                    rowdata = rowdata(readcols(:));
                    data(i,:) = rowdata(:)';

                end

            case 'formatted, fixed length'

                if ~isempty(findstr('D',precision))
                    fortranformat = 1;
                    precision = strrep(precision,'D','e');
                else
                    fortranformat = 0;
                end

                for i=1:nrowread

                    byteskip = 	nheadbytes + ... 									% skip header
                        (readrows(i)-1)*recordlen + ... 					% skip undesired records
                        nRowHeadBytes;

                    fseek(fid,byteskip,'bof'); 										% reposition to just before the first desired record

                    [str,count] = fread(fid,recordlen-nRowHeadBytes-nRowTrailBytes,'char'); 				% the whole record as characters
                    str = char(str');

                    if count ~= recordlen-nRowHeadBytes-nRowTrailBytes
                        fclose(fid);
                        error('Incorrect number of bytes read.')
                    end

                    if fortranformat					 						% extension to C conversion characters for Fortran 0.0D00 data
                        str = strrep(str,'D','e');
                    end

                    if isempty(recordlen) 										% No line endings in formatted data. Enforce field lengths
                        [rowdata,count] = sscanf(str,precision,ncols); 			% keep as '%15g'
                    else 														% Has line endings in formatted data. Ignore field lengths. Needs spaces between data
                        [rowdata,count] = sscanf(str,precision([1 end]),ncols); % convert '%15g' to '%g'
                    end

                    if count ~= ncols
                        fclose(fid);
                        error(['Incorrect number of values parsed. Expected ' num2str(ncols) ' values, but parsed ', num2str(count)])
                    end

                    rowdata = rowdata(readcols(:));
                    data(i,:) = rowdata(:)';

                end

            case 'formatted, variable length' 									% variable length fields.
                % Read a row at a time, discarding unneeded rows,
                % and subscript in to get desired columns

                if ~isempty(findstr('D',precision))
                    fortranformat = 1;
                    precision = strrep(precision,'D','e');
                else
                    fortranformat = 0;
                end


                byteskip = 	nheadbytes; 											% skip header
                fseek(fid,byteskip,'bof'); 										% reposition to just before the first record

                j = 1;
                for i=1:nrows

                    str = fgetl(fid);

                    if ismember(i,readrows)

                        str(1:nRowHeadBytes) = [];									% remove row header bytes
                        str(end-nRowTrailBytes:end) = [];							% remove row trailer bytes

                        if fortranformat					 						% extension to C conversion characters for Fortran 0.0D00 data
                            str = strrep(str,'D','e');
                        end

                        [rowdata,count] = sscanf(str,precision);

                        if count ~= ncols
                            fclose(fid);
                            strerr = ['Incorrect number of values parsed. Expected ' num2str(ncols), ...
                                ' values, but parsed ', num2str(count), ...
                                '.\nUse a numeric field width (e.g. ''%%12g'') for files with no delimiters between fields.' ];

                            error(sprintf(strerr))
                        end

                        rowdata = rowdata(readcols(:));
                        data(j,:) = rowdata(:)';

                        j = j+1;

                    end

                    if i+1 > max(readrows); break; end

                end

        end % switch

    end	% vectorized or unvectorized


    % if matrix contains character data, convert ascii codes to character

    switch precision
        case {'char', 'uchar','schar'}
            data = char(data);
    end

    if ~isempty(findstr('%',precision))	& ...
            ( ~isempty(findstr('c',precision)) ...
            | ...
            ~isempty(findstr('s',precision)) ...
            )

        data = char(data);
    end

    fclose(fid);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fieldlen,datatype] = fieldlength(precision,fid)

    %FIELDLENGTH returns the length of a field in bytes by matching the precision string


    datatype = 'binary';

    switch precision

        % Platform indpendent precision strings

        case {	'int8'   , 'integer*1',...   		% integer, 8 bits, 1 byte
                'uint8',...				    		% unsigned integer, 8 bits, 1 byte
                'char', 'uchar','schar'  }			% character

            fieldlen = 1;

        case {	'int16'  , 'integer*2',...      	% integer, 16 bits, 2 bytes
                'uint16' }      					% unsigned integer, 16 bits, 2 bytes

            fieldlen = 2;

        case {	'int32'  , 'integer*4',...      	% integer, 32 bits, 4 bytes
                'uint32' ,... 	      				% unsigned integer, 32 bits, 4 bytes
                'float32', 'real*4'}         		% floating point, 32 bits, 4 bytes

            fieldlen = 4;

        case{	'int64'  , 'integer*8',...      	% integer, 64 bits, 8 bytes
                'uint64' ,...       				% unsigned integer, 64 bits, 8 bytes
                'float64', 'real*8'}         		% floating point, 64 bits, 8 bytes

            fieldlen = 8;

            % The following platform dependent formats are also supported but
            % they are not guaranteed to be the same size on all platforms.
            % Assume a size, and notify user.

        case {	'short',...                     	% integer,  16 bits, 2 bytes
                'ushort' , 'unsigned short'} 		% unsigned integer,  16 bits, 2 bytes

            warning( ['Assuming machine dependent ' precision ' is 16 bits, 2 bytes long'])
            fieldlen = 2;

        case {	'int',...            				% integer,  32 bits, 4 bytes
                'long',...           				% integer,  32 or 64 bits, 4 or 8 bytes
                'uint'   , 'unsigned int',...   	% unsigned integer,  32 bits, 4 bytes
                'ulong'  , 'unsigned long',...  	% unsigned integer,  32 bits or 64 bits, 4 or 8 bytes
                'float'}          					% floating point, 32 bits, 4 bytes

            warning( ['Assuming machine dependent ' precision ' is 32 bits, 4 bytes long'])
            fieldlen = 4;

        case 'double'        						% floating point, 64 bits, 8 bytes

            warning( ['Assuming machine dependent ' precision ' is 64 bits, 8 bytes long'])
            fieldlen = 8;

            % FSCANF style formatted reads
        otherwise

            if ~isempty(findstr('%',precision)) % SCANF-style formatted data ('%5d')
                numericCharindx = find( ...
                    (double(precision) >= 49 & double(precision) <= 57) ... % numeric character ascii codes
                    | ...
                    double(precision) == 46 ); % allow a decimal point for fractional width. This is an undocumented way to allow for the presence of line ending within formatted data
                if isempty(numericCharindx);
                    fieldlen = [];
                    datatype = 'formatted, variable length';
                else
                    fieldlen = str2double(precision(numericCharindx));
                    datatype = 'formatted, fixed length';
                end
            else
                fclose(fid)
                error(['Field type ' precision ' not recognized'])
            end
    end


