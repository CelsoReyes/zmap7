function addAboutMenuItem(fig)
    % ADDABOUTMENUITEM add about menu to Help menu and zmap videos and report issue
    if ~exist('fig','var')
        fig = gcf;
    end
    
    hAbout = findall(fig,'Tag','zmaphelpmenuitem');
    if ~isempty(hAbout)
        delete(hAbout);
    end
    mainhelp=findall(fig,'Tag','figMenuHelp');
    if isempty(mainhelp)
        mainhelp=findobj(fig,'Label','Help');
        
        if isempty(mainhelp)
            mainhelp=uimenu(fig,'Label','Help');
        end
        
    end
    uimenu(mainhelp,'Label','v-- ZMAP --v','Separator','on','Enable','off','Tag','zmaphelpmenuitem');
    uimenu(mainhelp,'Label','Report a ZMAP Issue','Separator','on',...
        MenuSelectedField(),@(~,~)reportIssue,'Tag','zmaphelpmenuitem');
    
    uimenu(mainhelp,'Label','ZMAP Tutorial videos','Tag','zmaphelpmenuitem',...
        MenuSelectedField(),@(~,~) web('https://www.youtube.com/playlist?list=PLXUrwVIXIt9wQ5gkCP5B96k8EHzAX6bJX','-browser'))
    
    uimenu(mainhelp,'Label','About ZMAP','Separator','on','Tag','zmaphelpmenuitem',...
        MenuSelectedField(),@(~,~)aboutZmapDialog);
        uimenu(mainhelp,'Label','ZMAP Tips','Tag','zmaphelpmenuitem',...
            MenuSelectedField(),@(~,~)show_a_tip);
end

function reportIssue()
        h=helpdlg('Please enter an issue in the Github project main page');
        uiwait(h);
    if datetime < datetime(2018,12,31)
        %web('https://gitlab.seismo.ethz.ch/reyesc/zmap/issues','-browser');
        web('https://github.com/CelsoReyes/zmap7/issues','-browser');
    else
        errordlg('Need to determine where to report issues');
    end
end

function aboutZmapDialog()
    
    % if possible, recycle the existing figure
    fig=findobj('Name','About Zmap','-and','Type','figure');
    if ~isempty(fig)
        figure(fig)
        return
    end
    
    % define the text items that will be displayed in the window
    
    ZG=ZmapGlobal.Data;
    
    zmapVerMsg = ['ZMAP Version ', ZG.zmap_version];
    citationText = ['Wiemer, S., 2001. ', ...
        'A software package to analyze seismicity: ZMAP. ',...
        'Seismological Research Letters, 72(3), pp.373-382.'];
    
    citationDOI = 'https://doi.org/10.1785/gssrl.72.3.373';
    
    copyrightSymbol = char(169);
    copyrightMsg = sprintf('%s %s SED at ETH',copyrightSymbol,'1993 - 2018');
    
    matlabVerMsg = sprintf('Min. MATLAB vers : %s - R%s',ZG.min_matlab_version, ZG.min_matlab_release);
    tooltipMsg = ['<html><b>', strrep(citationText, '. ' , '.<br>'), '</b>', ...
        '<br><br>Left-click for copy options'];
    
    contributors = fileread('ZmapContributorList.txt');
    
    % create the window
    
    H = 400;
    W = 600;
    B1 = 10; % border width
    fig=figure('MenuBar','none','NumberTitle','off','Name','About Zmap','Units','pixels');
    fig.Position([3 4])=[W H];
    
    
    uicontrol(fig,'Style','Text','Tag','zmap version msg',...
        'Units','pixels','Position',[B1 H-60 W-2*B1 45 ],...
        'FontSize',24,'FontWeight','bold',...
        'String',zmapVerMsg);
    
    
    uicontrol(fig,'Style','Text','Tag','copyright msg',...
        'Units','pixels','Position',[B1 H-70 W-2*B1 20 ],...
        'FontSize',14,...
        'String',copyrightMsg);
    
    uicontrol(fig,'Style','Text', 'Tag', 'min matlab version msg',...
        'Units','pixels','Position',[B1 285 250 20 ],...
        'FontSize',12,...
        'String',matlabVerMsg);
    
    %citation
    
    h=uipanel(fig,'Units','pixels','position',[10 179 265 70],'Tag','citation container');
    h.Title='CITATION';
    
    t=uicontrol(h,'Style','Text','Units','Pixels','Position',[1 1 265 50],'Tag', 'citation msg');
    t.String=citationText;
    
    % add a context menu that allows contents to be copied.
    c = uicontextmenu('Tag','citation contextmenu');
    uimenu(c,'Label','view original document',...
        MenuSelectedField(),@(~,~)web('https://doi.org/10.1785/gssrl.72.3.373','-browser'));
    uimenu(c,'Label','copy to clipboard',...
        MenuSelectedField(),@(~,~)clipboard('copy',[citationText '. doi: ' citationDOI]));
    h.UIContextMenu=c;
    t.UIContextMenu=c;
    t.TooltipString = tooltipMsg;
    
    % contributors
    
    uicontrol(fig,'Style','Text','Tag','contributors title',...
        'Units','pixels','Position',[280  300 310 14],...
        'FontWeight','bold',...
        'String','Authors and Contributors');
    uicontrol(fig,'Style','listbox','Position',[280  178 309 118],...
        'String', contributors,'Tag','contributors list' );
    
    % show the SED logo, which will bring user to the main SED webpage
    
    upan = uipanel(fig,'Units','pixels','Position',[B1 50 W-2*B1 120],'BackgroundColor','w',...
        'Tag','ETH Logo container');
    rgb=imread('resrc/logos/SED_ETH_Lang_2014_RGB.jpg');
    ax=axes(upan,'units','pixels','Position',[5 5 upan.Position(3:4)-10]);
    im=image(ax,rgb);
    axis(ax,'equal')
    ax.Visible='off';
    im.ButtonDownFcn=@(~,~)web('www.seismo.ethz.ch','-browser');
    
    % add a centered close button
    
    p=fig.Position;
    p(1)=p(3)/2 - 30;
    p(3)=60;
    p(4)=30;
    p(2)=B1;
    uicontrol(fig,'Style','pushbutton','String','Close','Tag','close',...
        'Units','pixels','Position',p,'Callback',@(~,~)close(fig));
end
