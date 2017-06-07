function done
    global action_button mess

    report_this_filefun(mfilename('fullpath'));

    try
        set(action_button, 'String', 'Ready, now idling!');
    catch ME
        error_handler(ME, @do_nothing)
    end
    watchoff(mess)
    drawnow

