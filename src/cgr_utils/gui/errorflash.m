function errorflash(h, n)
    %errorflash flashes the text color and weight for a GUI item
    % errorflash(handleForObject) used to bring attention to an object, default # of flashes
    % errorflash(handleForObject, numberOfFlashes), specify number of flashes
    % often, this is after an error message.
    % ex.
    %
    % h=errordlg('Incomplete Request: You must first do something important.', 'error','modal');
    % waitfor(h);  %pause execution until the error box is closed
    % errorflash(handles.data_provider);
    
    flashcolor = [0.6 0.0 0.0]; % medium-red
    if isprop(h,'FontColor')
        colorField = 'FontColor';
    elseif isprop(h,'ForegroundColor')
        colorField = 'ForeroundColor';
    else
        colorField = 'BackgroundColor';
    end
    
    flashweight = 'bold';
    origweight=get(h,'FontWeight');
    origColor=get(h,colorField);
    
    if ~exist('n','var')
        n=2;
    end
    
    for i=1:n
        set(h,colorField,flashcolor,'FontWeight',flashweight);
        pause(.5); drawnow;
        set(h,colorField,origColor,'FontWeight',origweight);
        pause(.1); drawnow;
    end
end