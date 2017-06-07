function str=ms2strv(mat)
    %       str=ms2strv(mat)
    % convert a matrix of strings to a vector with the strings
    % delineated by commas.
    %
    % OR
    %       mat=ms2strv(str)
    % convert a string vector containing commas to a matrix of
    % strings where each string was separated by commas.
    %
    % EXAMPLE
    %  str='A,BB,CCC'
    %  mat=ms2strv(str)   mat =  A
    %                            BB
    %                            CCC
    % OR
    %  str=ms2strv(mat)   str = A,BB,CCC
    %
    %                                rcobb 9/95
    %
    [m,n]=size(mat);
    if m ~= 1
        str(1:length(deblank(mat(1,:))))=deblank(mat(1,:));
        for i=2:m
            str=[str,',', deblank(mat(i,:))];
        end
    else
        I=findstr(',',mat);
        if length(I) >= 1
            if I(1) ~= 1
                str=mat(1:I(1)-1);
            end
            for i=2:length(I)
                str=char(str,mat(I(i-1)+1:I(i)-1));
            end
            str=char(str,mat(I(length(I))+1:max(m,n)));
        else
            str=mat;
        end
    end

