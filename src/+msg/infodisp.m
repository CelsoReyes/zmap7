function infodisp(msg, msgTitle)
    % INFODISP provide information to user in command window
    %
    % infodisp(message, title) prints the message with an optional title to the command window
    if exist('msgTitle','var')
        fprintf('\n---<strong> ZMAP info: %s </strong>---\n',msgTitle);
    else
        fprintf('\n---<strong> ZMAP info: </strong>');
    end
    disp(msg)
end
    