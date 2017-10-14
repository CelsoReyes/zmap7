function think(title_text, message_text)
    if nargin==2
        ZmapMessageCenter.set_message(title_text, message_text);
    elseif nargin==0
        % do nothing
    else
        error('wrong number of inputs');
    end
    drawnow();
end


