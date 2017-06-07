function str=vec2str(vec)
    %       string=vec2str(vector)
    % convert a numeric vector to an equivalent string
    % so that eval(string)=vector                                rcobb 9/95
    %
    if min(size(vec)) > 1,error('error, expecting vector input'),end
    if isempty(vec)
        str = '';
    else
        str=['[',num2str(vec(1))];
        len=length(vec);
        indx = 2;
        while indx <= len
            sindx = indx;
            while vec(sindx-1)+1 == vec(sindx) & sindx <= len-1
                sindx = sindx + 1;
                if sindx == len && vec(sindx-1)+1 == vec(sindx)
                    str=[str,':',num2str(vec(sindx))];
                    str=[str,']'];
                    return
                end
            end
            if sindx == indx
                str=[str,',',num2str(vec(indx))];
                indx =sindx + 1;
            else
                str=[str,':',num2str(vec(sindx-1))];
                indx =sindx;
            end
        end
        str=[str,']'];
    end
