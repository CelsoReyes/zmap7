function slshow()
    % slshow slide show of images in a directory
    % now essentially self-contained.
    % - CGR
    
    report_this_filefun(mfilename('fullpath'));
    setup_slideshow();
end

function setup_slideshow()
    hodi = evalin('base','hodi');
    file_extensions = {'jpg','png','bmp','gif'};
    slides = dir(fullfile(hodi, 'slides', ['*.', file_extensions{1}]));
    for n=2:numel(file_extensions)
        slides = [slides; dir(fullfile(hodi, 'slides', ['*.', file_extensions{n}]))];  %#ok<AGROW>
    end
    
    fn = fullfile(slides(1).folder,{slides.name});
    slides = sort(fn);
    
    % set up slide viewer
    
        fsl = figure_w_normalized_uicontrolunits('Menubar','none','NumberTitle','off');
        viewport = axes('pos',[0 0 1 1]);axis off; axis ij

        userdata.slides = slides;
        userdata.idx = 0;
        userdata.ga = viewport;

        uicontrol(fsl,...
            'Units','normalized',...
            'Callback',@(s,e)close(fsl),...
            'String','Close',...
            'BackgroundColor' ,[0.8 0.8 0.8],...
            'Position',[0.90 0.01 0.10 0.06]);

        next_button = uicontrol(fsl,...
            'Units','normalized',...
            'Callback',@next_slide,...
            'String','Next ',...
            'BackgroundColor' ,[0.8 0.8 0.8],...
            'Position',[0.90 0.12 0.10 0.06],...
            'UserData', userdata);
        next_slide(next_button,[]);
end

function next_slide(s, ~)
    s.UserData.idx = s.UserData.idx + 1;
    if s.UserData.idx > numel(s.UserData.slides)
        s.UserData.idx = 1;
    end
    this_slide_info = s.UserData.slides{s.UserData.idx};
    try
        [x,~] = imread(this_slide_info);
    catch ME
        error_handler(ME, @do_nothing)
    end
    
    image(s.UserData.ga, x);
    drawnow
end