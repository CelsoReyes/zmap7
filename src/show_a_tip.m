function show_a_tip(n)
    % SHOW_A_TIP
    % SHOW_A_TIP() shows a random tip
    % SHOW_A_TIP(N) shows the nth tip
    % SHOW_A_TIP('reload') forces the tip file to be reloaded, then shows a random tip;
    
    % ('showall') 
    
    persistent tips
    if exist('n','var') && (ischar(n)||isstring(n))
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
        S=fileread(fullfile(ZmapGlobal.Data.hodi,'docs/tips_en.txt'));
        titles = extractBefore(string(strsplit(S,newline)),'|');
        titles = titles(:);
        titles(ismissing(titles))=[];
        texts = extractAfter(string(strsplit(S,newline)),'|');
        texts = texts(:);
        texts = strrep(texts,'|',newline);
        texts(ismissing(texts))=[];
        tips=table(titles, texts);
    end
    if nargin==0||isempty(n)
        n=randi(height(tips));
    end
    mytitle = "ZMAP TIP #" + string(n) + ": " + tips.titles(n);
    fh = get(groot,'CurrentFigure');
    make_better_helpdlg(n, tips.texts(n), tips.titles(n));
    return
    h=helpdlg(tips.texts(n), mytitle);
    if ~isempty(fh)
        oldUnits= fh.Units;
        fh.Units='pixels';
        h.Position([1,2])=fh.Position([1,2]) + fh.Position([3,4]) .* [0.4 0.6];
        fh.Units = oldUnits;
    end
end

function h=make_better_helpdlg(n,texts,mytitle)
    
    h=helpdlg(texts, "ZMAP TIP #" + string(n));
    h.Visible = 'off';
    dlg_wh = [450 150];
    h.Position([3,4])= dlg_wh;
    child_tags = get(h.Children,'Tag');
    delete(h.Children(ismissing(child_tags))); %get rid of MessageBox axes
    
    % put this help dlg somewhere useful
    fh = get(groot,'CurrentFigure');
    if ~isempty(fh)
        oldUnits = fh.Units;
        fh.Units = 'pixels';
        h.Position([1,2]) = fh.Position([1,2]) + (fh.Position([3,4])./2 - dlg_wh ./ 2);
        fh.Units = oldUnits;
    end
    
    h.Children(2).Position = [7 110 32 32];
    uicontrol(h,'Style','text','Position',[60 125 350 20],...
        'String',mytitle,...
        'FontSize',15,...
        'FontWeight','bold');
    uicontrol(h,'Style','text','Position',[60 40 350 75],...
        'String',texts,...
        'FontSize',12,...
        'HorizontalAlignment','left');
    h.Visible = 'on';
end