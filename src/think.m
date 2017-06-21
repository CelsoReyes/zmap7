function think(title_text, message_text)
    if nargin==2
        zmap_message_center.set_message(title_text, message_text);
    elseif nargin==0
        % do nothing
    else
        error('wrong number of inputs');
    end
    
    zmap_message_center.start_action('Working, hang on...');
    drawnow();
end

