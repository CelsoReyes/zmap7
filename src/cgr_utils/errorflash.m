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

    flashcolor = [0.6 0.0 0.0] % medium-red
    flashweight = 'bold';
    origweight=get(h,'FontWeight');
    origColor=get(h,'ForegroundColor');
    
    if ~exist('n','var')
        n=2;
    end
    
    for i=1:n
        set(h,'ForegroundColor',flashcolor,'FontWeight',flashweight);
        pause(.5); drawnow;
        set(h,'ForegroundColor',origColor,'FontWeight',origweight);
        pause(.1); drawnow;
    end
end