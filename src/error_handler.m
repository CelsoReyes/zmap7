function error_handler(ME, optional)
    % unhandled_error provides a one-stop place to track certain errors
    %
    % it is designed to be a drop-in replacement for simple try-catch display
    %
    % usage:
    %   try
    %      do something that might fail
    %   catch ME
    %      unhandled_error(ME) % prints the error message
    %      unhandled_error(ME, "oops") % prints "oops"
    %      unhandled_error(ME, @do_nothing) % does nothing
    %      unhandled_error(ME, @function_name) % executes function function_name
    %   end
    %
    %  Celso G Reyes, 2017

    if exist('optional','var') && ~isempty(optional)
        if isa('optional','function_handle')
            optional();
        else
            disp(optional)
        end
    elseif exist('ME', 'var')
        disp('ignored exception:');
        disp(ME)
    else
        % do nothing
    end
