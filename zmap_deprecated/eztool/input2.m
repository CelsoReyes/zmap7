function out = input2(text,def)
    %
    %	out = input2(text,default)
    %
    %	Compliments of Charles Stark Draper Labs
    if ischar(def) == 1
        eval(['y = input('' ',text,' [',def,'] '',''s'');'])
        if isempty(y)
            out = def;
        else
            out = y;
        end
    else
        eval(['y = input('' ',text,' [',num2str(def),'] '',''s'');'])
        if isempty(y)
            out = def;
        else
            out = eval(y);
        end
    end



