function think()
    report_this_filefun(mfilename('fullpath'));

    global action_button
    try
        set(action_button, 'String', 'Working, hang on...');
    catch ME
        error_handler(ME, @do_nothing)
    end
    %watchon
    drawnow
end

