function [dlgstruct , cancelled, varargout] = smart_inputdlg(dlgtitle, dlgstruct)
    % smart_inputdlg smarter replacement for inputdlg that doesn't require user to do conversions
    %
    % [dlgstruct] = smart_inputdlg(dlgtitle, dlgstruct) get a structure containing responses.  If
    % the operation was cancelled, all the dlgstruct.value will be unchanged
    %
    % [dlgstruct , cancelled] = smart_inputdlg(dlgtitle, dlgstruct) additionally, find out
    % if the operation was cancelled
    %
    % [~ , cancelled, varargout] = smart_inputdlg(dlgtitle, dlgstruct) return the values 
    % directly into variables. eg:
    %
    %    dlgtitle = 'title'
    %    s.prompt = 'enter a'; s.value = a; 
    %    s(2).prompt = 'enter b'; s(2).value = b;
    %    s(3).prompt = 'enter c'; s(3).value = c;
    %
    %    [~, cancelled, a, b, c] = smart_inputdlg(dlgtitle, s)
    %
    %
    % dlgstruct is an array of struct with:
    %    prompt - prompt f
    %    value - default value
    %    toChar - function to convert to char
    %    toValue - function to convert back to value
    %
    %
    % sample converters to use..
    %   for a datetime:
    %   	toChar = @(d) char(d,'uuuu-MM-dd HH:mm:ss');
    %   	toValue = @(s) datetime(s,'InputFormat','uuuu-MM-dd HH:mm:ss');
    %
    %   for a duration:
    %       toChar = @(d)  num2str(days(d))
    %       toValue = @(s) days(str2double(d))
    %     * COULD BE years,days,hours,minutes,seconds *
    %
    % SIDE-EFFECT: dlgstruct will be populated with toChar and toValue, if this program can figure it out.
    varargout={};
    
    % build knowldege of dlgstruct
    for i = 1:numel(dlgstruct)
        v = dlgstruct(i).value;
        if isfield(dlgstruct(i), 'toChar') && ~isempty(dlgstruct(i).toChar)
            def(i) = {dlgstruct(i).toChar(v)};
            continue;
        end
        
        %otherwise try to interpret it...
        
        if isnumeric(v)
            dlgstruct(i).toChar = @(x)num2str(x);
            dlgstruct(i).toValue = @(x)str2num(x);
        elseif isa(v,'datetime')
            dlgstruct(i).toChar = @(x)char(x, 'uuuu-MM-dd HH:mm:ss');
            dlgstruct(i).toValue = @(s)datetime(s, 'InputFormat', 'uuuu-MM-dd HH:mm:ss');
        elseif isa(v,'duration')
            % search prompt for clues....
            p=dlgstruct(i).prompt;
            if contains(p, 'year', 'IgnoreCase', true)
                dlgstruct(i).toChar = @(d)num2str(years(d));
                dlgstruct(i).toValue = @(s) years(str2double(s));
            elseif contains(p, 'day', 'IgnoreCase', true)
                dlgstruct(i).toChar = @(d)num2str(days(d));
                dlgstruct(i).toValue = @(s) days(str2double(s));
            elseif  contains(p, 'hour', 'IgnoreCase', true)
                dlgstruct(i).toChar=@(d)num2str(hours(d));
                dlgstruct(i).toValue = @(s) hours(str2double(s));
            elseif  contains(p, 'minute', 'IgnoreCase', true)
                dlgstruct(i).toChar = @(d)num2str(minutes(d));
                dlgstruct(i).toValue = @(s) minutes(str2double(s));
            elseif  contains(p, 'second', 'IgnoreCase', true)
                dlgstruct(i).toChar = @(d)num2str(seconds(d));
                dlgstruct(i).toValue = @(s) seconds(str2double(s));
            else
                error('cannot tell from prompt what the units are. specify units in prompt or define a toChar/toVlaue pair');
            end
        elseif ischar(v)
            dlgstruct(i).toChar = @(x)x;
            dlgstruct(i).toValue = @(x)x;
        end
        def(i) = {dlgstruct(i).toChar(v)};
    end
    
    % TODO inputdlg appears anywhere, but would be best put somewhere specific
    v = inputdlg({dlgstruct.prompt}, dlgtitle, 1, def);
    cancelled = isempty(v);
    if ~cancelled()
        for i=1:numel(v)
            dlgstruct(i).value = dlgstruct(i).toValue(v{i});
        end
    end
    nout = max(nargout,1) - 2;
    if nout == numel(dlgstruct)
        % one item per position
        for i = 1:numel(dlgstruct)
            varargout(i) = {dlgstruct(i).value};
        end
    elseif nout > 0
        error('number of output variables doesn''t match number of input variables')
    end
end