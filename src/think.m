function think(title_text, message_text)
    h = zmap_message_center();
    if nargin==2
        h.set_message(title_text, message_text);
    elseif nargin==0
        % do nothing
    else
        error('wrong number of inputs');
    end
    
    h.start_action('Working, hang on...');
    drawnow();
end

