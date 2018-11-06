function show_a_tip(n)
    % SHOW_A_TIP
    % SHOW_A_TIP() shows a random tip
    % SHOW_A_TIP(N) shows the nth tip
    % SHOW_A_TIP('reload') forces the tip file to be reloaded, then shows a random tip;
    
    % ('showall') 
    
    persistent tips
    if exist('n', 'var') && (ischar(n)||isstring(n))
        switch n
            case "reload"
            tips=[];
            n=[];
            case "showall"
                disp(tips);
            otherwise
                error('unknown input to show_a_tip');
        end
    end
    if isempty(tips)
        S=fileread(fullfile(ZmapGlobal.Data.hodi, 'docs/tips_en.txt'));
        titles = extractBefore(string(strsplit(S,newline)), '|');
        titles = titles(:);
        titles(ismissing(titles))=[];
        texts = extractAfter(string(strsplit(S,newline)), '|');
        texts = texts(:);
        texts = strrep(texts, '|',newline);
        texts(ismissing(texts))=[];
        tips=table(titles, texts);
    end
    if nargin==0||isempty(n)
        n=randi(height(tips));
    end
    n=mod(n-1,height(tips))+1;
    make_better_helpdlg(n, tips.texts(n), tips.titles(n));
end

function h=make_better_helpdlg(n,texts,text_heading)
    dlg_width = 450;
    dlg_height = 160;
    dlg_title = "ZMAP TIP #" + string(n);
    
    h=findobj('Tag', 'ZmapTips');
    if isempty(h)
        
        h=figure('Name',dlg_title,...
            'Tag', 'ZmapTips',...
            'Visible', 'off',...
            'NumberTitle', 'off',...
            'Position', get_reasonable_pos(dlg_width, dlg_height),...
            'MenuBar', 'none');
        
        add_icon(h);
        
        % header for dialog
        h_hdr = uicontrol(h, 'Style', 'text',...
            'Position', [60 135 350 20],...
            'String',text_heading,...
            'FontSize',15,...
            'FontWeight', 'bold', 'Tag', 'title');
        h_hdr.Units = 'normalized';
        
        % text for dialog
        h_txt = uicontrol(h, 'Style', 'text',...
            'Position', [50 40 370 85],...
            'String',texts,...
            'FontSize',12,...
            'HorizontalAlignment', 'left',...
            'Tag', 'message');
        h_txt.Units = 'normalized';
        
        % buttons for dlg
        uicontrol(h, 'Style', 'pushbutton',...
            'Tag', 'prev button', 'String', '<',...
            'Position', [30,7,40,30],...
            'FontWeight', 'bold',...
            'Callback',@(~,~)show_a_tip(n-1));
        
        uicontrol(h, 'Style', 'pushbutton', 'Position', [75,7,60,30],...
            'Tag', 'rand button', 'String', 'random',...
            'Callback', @(~,~)show_a_tip());
        
        uicontrol(h, 'Style', 'pushbutton',...
            'Tag', 'next button', 'String', '>',...
            'Position', [140,7,40,30],...
            'FontWeight', 'bold',...
            'Callback',@(~,~)show_a_tip(n+1));
        
        uicontrol(h, 'Style', 'pushbutton', 'Position', [353,7,70,30],...
            'Tag', 'close button', 'String', 'close tips',...
            'Callback',@(~,~)close(h));
    else
        h.Visible = 'off';
        h.Name = dlg_title;
        hbutts = findobj(h.Children, 'flat', 'Style', 'pushbutton');
        set(findobj(h.Children, 'Tag', 'message'), 'String',texts);
        set(findobj(h.Children, 'Tag', 'title'), 'String',text_heading);
        hbutts(get(hbutts, 'Tag')=="prev button").Callback = @(~,~)show_a_tip(n-1);
        hbutts(get(hbutts, 'Tag')=="next button").Callback = @(~,~)show_a_tip(n+1);
    end
    h.Visible = 'on';
    
end

function p = get_reasonable_pos(w,h)
    fh = get(groot, 'CurrentFigure');
    
    if ~isempty(fh)
        oldUnits = fh.Units;
        fh.Units = 'pixels';
        fpos = fh.Position;
        left = fpos(1) + (fpos(3) - w) ./ 2;
        bot  = fpos(2) + (fpos(4) - w) ./ 2;
        p    = [left, bot, w, h];
        fh.Units = oldUnits;
    end
end

function add_icon(f)
    % modified from msgbox
    IconAxes=axes(...
        'Parent'    , f,...
        'Units'     , 'points',...
        'Position'  , [7 120 32 32] ,...
        'Tag'       , 'IconAxes');
    
    [iconData] = matlab.ui.internal.dialog.DialogUtils.imreadDefaultIcon('help');  
    Img=image('CData',iconData, 'Parent',IconAxes);
    if ~isempty(Img.XData) && ~isempty(Img.YData)
        IconAxes.Visible = 'off';
        IconAxes.YDir = 'reverse';
    end
end