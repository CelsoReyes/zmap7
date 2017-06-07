function rgbedit(action)

    % Matlab function to edit an RGB matrix (colormap).

    report_this_filefun(mfilename('fullpath'));

    % GLOBAL VARIABLES:

    global  QuitFlag  NewFlag  Answr  color  EditPt
    global  infile  outfile
    global  forecolor  backcolor
    global  RedYBP  GreYBP  BluYBP  NRed  NGre  NBlu
    global  RedXBP GreXBP BluXBP  NearXPt
    global  RedData  GreData  BluData  Npts  Xvector
    global  CMName  data  ColBar
    global  hFigure  hRGB  hBar
    global  hRed  hGre  hBlu  hNone
    global  hPltRed  hPltGre  hPltBlu
    global  hNew  hOpen  hSave  hQuit
    global  hAdd  hDel
    global  hZoomOn  hZoomOff  hZoomReset

    if nargin < 1
        action = '';
        color = 'none';
        QuitFlag = 0;
        NewFlag = 1;
        % Create a new figure (to make sure we are not overwriting an existing one).
        hFigure = figure;
        set(hFigure,'NumberTitle','off','Name','RGB edit','MenuBar','none', ...
            'Tag','rgbwindow','UserData','zoomoff')

        % Create axis for RGB plot.
        hRGB = axes('Position',[.1 .15 .8 .8],'Box','on','LineWidth',1, ...
            'FontName','helvetica','FontSize',12,'FontWeight','bold', ...
            'YLim',[0 1],'Layer','bottom','SortMethod','childorder');

        % Create axis for the color bar.
        hBar = axes('Position',[.1 .05 .8 .05],'Box','on','LineWidth',1, ...
            'FontSize',12,'FontWeight','normal','SortMethod','childorder', ...
            'XTickLabel',[],'YTickLabel',[],'YTick',[]);

        % Create the Menu Bar for the various GUI elements.
        forecolor = 'green';

        hMenuFile = uimenu('Label','  File  ','Position',1, ...
            'ForeGround',forecolor);

        hNew = uimenu(hMenuFile,'Label','New', ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''new'')');

        hOpen = uimenu(hMenuFile,'Label','Open', ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''open'')');

        hSave = uimenu(hMenuFile,'Label','Save','Enable','off', ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''save'')');

        hQuit = uimenu(hMenuFile,'Label','Quit', ...
            'ForeGround',forecolor, ...
            'Separator','on', ...
            'Callback','rgbedit(''quit'')');

        hMenuEdit = uimenu('Label','  Edit  ','Position',2, ...
            'ForeGround',forecolor);

        hAdd = uimenu(hMenuEdit,'Label','  Add  ','Position',1, ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''add'')', ...
            'Enable','off');

        hDel = uimenu(hMenuEdit,'Label','  Delete  ','Position',2, ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''delete'')', ...
            'Enable','off');

        hMenuColor = uimenu('Label','  Color  ','Position',3, ...
            'ForeGround',forecolor);

        hRed = uimenu(hMenuColor,'Label','  Red  ','Position',1, ...
            'ForeGround','red', ...
            'Callback','rgbedit(''red'')','Enable','off');

        hGre = uimenu(hMenuColor,'Label','  Green  ','Position',2, ...
            'ForeGround','green', ...
            'Callback','rgbedit(''green'')','Enable','off');

        hBlu = uimenu(hMenuColor,'Label','  Blue  ','Position',3, ...
            'ForeGround','blue', ...
            'Callback','rgbedit(''blue'')','Enable','off');

        hNone = uimenu(hMenuColor,'Label','X None  ','Position',4, ...
            'ForeGround','yellow', ...
            'Callback','rgbedit(''nocolor'')','Separator','on', ...
            'Enable','off');

        hMenuTools = uimenu('Label','  Tools  ','Position',4, ...
            'ForeGround',forecolor);
        hZoomOn = uimenu(hMenuTools,'Label','  Zoom On  ','Position',1, ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''zoomon'')','Enable','off');

        hZoomOff = uimenu(hMenuTools,'Label','  Zoom Off  ','Position',2, ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''zoomoff'')','Enable','off');

        hZoomReset = uimenu(hMenuTools,'Label','  Zoom Reset  ','Position',3, ...
            'ForeGround',forecolor, ...
            'Callback','rgbedit(''zoomreset'')','Enable','off');

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmp(action,'enable')

        set(hSave,'Enable','on')
        set(hRed,'Enable','on')
        set(hGre,'Enable','on')
        set(hBlu,'Enable','on')
        set(hNone,'Enable','on')
        set(hAdd,'Enable','on')
        set(hDel,'Enable','on')
        set(hZoomOn,'Enable','on')
        set(hZoomOff,'Enable','on')
        set(hZoomReset,'Enable','on')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'new')

        if ~NewFlag
            rgbedit('savechangedlg')
            if strcmp(char(Answr),'Yes')
                rgbedit('save')
            elseif strcmp(char(Answr),'Cancel')
                return
            end
        end

        Answr = inputdlg('Enter the number of points to generate: ', ...
            '    New ColorMap Function');

        if isempty(char(Answr))
            errordlg('You Need to Enter a Value!  Try again','    ERROR')
            return
        end

        RedInit = [.8; .2];
        GreInit = [.5; .5];
        BluInit = [.2; .8];

        Npts = str2double(char(Answr));
        Xvector = (1:Npts);
        data = zeros(Npts,3);
        data(:,1) = (.8:(RedInit(2)-RedInit(1))/(Npts-1):.2)';
        data(:,2) = ones(Npts,1) * .5;
        data(:,3) = (.2:(BluInit(2)-BluInit(1))/(Npts-1):.8)';

        RedData = data(:,1);
        GreData = data(:,2);
        BluData = data(:,3);

        rgbedit('getbreakpoints')

        RedYBP = data(RedXBP,1);
        GreYBP = data(GreXBP,2);
        BluYBP = data(BluXBP,3);

        rgbedit('enable')

        rgbedit('plot')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'open')

        if ~NewFlag
            rgbedit('savechangedlg')
            if strcmp(char(Answr),'Yes')
                rgbedit('save')
            elseif strcmp(char(Answr),'Cancel')
                return
            end
        end

        [filename,pathname] = uigetfile('*.mat','Open File',300,300);
        if isempty(filename)
            warndlg('No File Selected','    WARNING')
            return
        elseif filename == 0
            return
        end

        infile = sprintf('%s%s',pathname,filename);
        eval(['load ',infile])
        if ~exist('CMName') | exist('CMName') > 1
            Answr = inputdlg('Colormap Name:','    Open ColorMap Function');

            if ~exist(char(Answr))
                errordlg('This is Not the Correct Colormap Name', ...
                    '    ERROR');
                return
            end

            if isempty(char(Answr))
                warndlg('No File Selected','    WARNING')
                return
            end

            CMName = char(Answr);
        end

        eval(['data = ',CMName,';'])
        sizedata = size(data);
        Npts = sizedata(1);
        Xvector = (1:Npts);

        RedData = data(:,1);
        GreData = data(:,2);
        BluData = data(:,3);

        rgbedit('enable')

        rgbedit('getbreakpoints')

        RedYBP = data(RedXBP,1);
        GreYBP = data(GreXBP,2);
        BluYBP = data(BluXBP,3);

        rgbedit('plot')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'save')

        Answr = inputdlg('ColorMap Name:','Save ColorMap');

        if ~isempty(char(Answr))
            CMName = char(Answr);
            eval([CMName,' = data;'])
            [filename,pathname] = uiputfile('*.mat','Save File',300,300);
            if isempty(filename)
                errordlg('No File Selected.  Data Not Saved!','   ERROR')
                return
            elseif filename == 0
                return
            end

            outfile = sprintf('%s%s',pathname,filename);
            eval(['save ',outfile,' CMName ',CMName])
            if QuitFlag
                rgbedit('quit')
            end
        else
            warndlg('File Not Saved','    WARNING')
            QuitFlag = 0;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'quit')

        if QuitFlag
            delete(hFigure)
            return
        end

        rgbedit('savechangedlg')

        if strcmp(char(Answr),'Yes')
            QuitFlag = 1;
            rgbedit('save')
        elseif strcmp(char(Answr),'No')
            QuitFlag = 1;
            rgbedit('quit')
        elseif strcmp(char(Answr),'Cancel')
            QuitFlag = 0;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'plot')

        axes(hRGB)
        set(hRGB,'XLim',[1 Npts])
        hold on

        if NewFlag
            hPltRed = plot(RedXBP,RedYBP,'r-','Marker','.','MarkerSize',5);
            hPltGre = plot(GreXBP,GreYBP,'g-','Marker','.','MarkerSize',5);
            hPltBlu = plot(BluXBP,BluYBP,'b-','Marker','.','MarkerSize',5);
            NewFlag = 0;
        else
            set(hPltRed,'XData',RedXBP,'YData',RedYBP)
            set(hPltGre,'XData',GreXBP,'YData',GreYBP)
            set(hPltBlu,'XData',BluXBP,'YData',BluYBP)
        end

        axes(hBar)
        set(hBar,'XLim',[1 Npts])
        ColBar = 1:Npts;
        image(ColBar); colormap(data);

        set(hBar,'XTickLabel',[],'YTickLabel',[],'YTick',[]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'getbreakpoints')

        DRedData = diff(RedData);
        DGreData = diff(GreData);
        DBluData = diff(BluData);

        RedXBP = 1; GreXBP = 1; BluXBP = 1;

        for i = 1:Npts-2
            if abs(DRedData(i)-DRedData(i+1)) > 1e-5
                RedXBP = [RedXBP; i+1];
            end

            if abs(DGreData(i)-DGreData(i+1)) > 1e-5
                GreXBP = [GreXBP; i+1];
            end

            if abs(DBluData(i)-DBluData(i+1)) > 1e-5
                BluXBP = [BluXBP; i+1];
            end
        end

        RedXBP = [RedXBP; Npts];
        GreXBP = [GreXBP; Npts];
        BluXBP = [BluXBP; Npts];

        NRed = length(RedXBP);
        NGre = length(GreXBP);
        NBlu = length(BluXBP);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'savechangedlg')

        Answr = questdlg('Save Changes?','    Save ColorMap');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'add')

        if strcmp(color,'none')
            warndlg('You Need to Activate a Color First!','    WARNING')
            return
        end

        axes(hRGB)
        PointNotOK = 0;
        addpt = ginput(1);
        cpx = round(addpt(1));  cpy = addpt(2);

        if strcmp(color,'red')
            if ~isempty(find(RedXBP == cpx)), PointNotOK = 1; end
        elseif strcmp(color,'green')
            if ~isempty(find(GreXBP == cpx)), PointNotOK = 1; end
        elseif strcmp(color,'blue')
            if ~isempty(find(BluXBP == cpx)), PointNotOK = 1; end
        end

        if PointNotOK
            errordlg('This Point Already Exist!  Try Again.','    ERROR')
            return
        end

        if strcmp(get(hFigure,'UserData'),'zoomon')
            rgbedit('zoomoff')
        end

        if strcmp(color,'red')
            apn = min(find(RedXBP > cpx));
            NearXPt = apn;
            RedXBP = [RedXBP(1:apn-1); cpx; RedXBP(apn:NRed)];
            RedYBP = [RedYBP(1:apn-1); cpy; RedYBP(apn:NRed)];
            NRed = NRed + 1;
            set(hPltRed,'XData',RedXBP,'YData',RedYBP)
        elseif strcmp(color,'green')
            apn = min(find(GreXBP > cpx));
            NearXPt = apn;
            GreXBP = [GreXBP(1:apn-1); cpx; GreXBP(apn:NGre)];
            GreYBP = [GreYBP(1:apn-1); cpy; GreYBP(apn:NGre)];
            NGre = NGre + 1;
            set(hPltGre,'XData',GreXBP,'YData',GreYBP)
        elseif strcmp(color,'blue')
            apn = min(find(BluXBP > cpx));
            NearXPt = apn;
            BluXBP = [BluXBP(1:apn-1); cpx; BluXBP(apn:NBlu)];
            BluYBP = [BluYBP(1:apn-1); cpy; BluYBP(apn:NBlu)];
            NBlu = NBlu + 1;
            set(hPltBlu,'XData',BluXBP,'YData',BluYBP)
        end

        rgbedit('regenerate')

        colormap(data)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'delete')

        PointNotOK = 0;

        if strcmp(color,'none')
            warndlg('You Need to Activate a Color First!','    WARNING')
            return
        elseif strcmp(color,'red')
            if NRed < 3, PointNotOK = 1; end
        elseif strcmp(color,'green')
            if NGre < 3, PointNotOK = 1; end
        elseif strcmp(color,'blue')
            if NBlu < 3, PointNotOK = 1; end
        end

        if PointNotOK
            errordlg('You Can''t Remove the Last Two Points!  Try Again.', ...
                '    ERROR')
            return
        end

        if strcmp(get(hFigure,'UserData'),'zoomon')
            rgbedit('zoomoff')
        end

        tmp = ginput(1);
        cp = get(hRGB,'CurrentPoint');
        cpx = cp(1,1);
        cpy = cp(1,2);
        NearXPt = [];
        NearYPt = [];
        PointNotOK = 0;

        if strcmp(color,'red')
            NearXPt = find(min(abs(RedXBP-cpx)) == abs(RedXBP-cpx) & ...
                abs(RedXBP-cpx) < (Npts/200));
            NearYPt = abs(RedYBP(NearXPt)-cpy) < 0.01;
            if ~isempty(NearXPt)  &&  NearYPt
                RedXBP = [RedXBP(1:NearXPt-1); RedXBP(NearXPt+1:NRed)];
                RedYBP = [RedYBP(1:NearXPt-1); RedYBP(NearXPt+1:NRed)];
                NRed = NRed - 1;
                set(hPltRed,'XData',RedXBP,'YData',RedYBP)
            end
        elseif strcmp(color,'green')
            NearXPt = find(min(abs(GreXBP-cpx)) == abs(GreXBP-cpx) & ...
                abs(GreXBP-cpx) < (Npts/200));
            NearYPt = abs(GreYBP(NearXPt)-cpy) < 0.01;
            if ~isempty(NearXPt)  &&  NearYPt
                GreXBP = [GreXBP(1:NearXPt-1); GreXBP(NearXPt+1:NGre)];
                GreYBP = [GreYBP(1:NearXPt-1); GreYBP(NearXPt+1:NGre)];
                NGre = NGre - 1;
                set(hPltGre,'XData',GreXBP,'YData',GreYBP)
            end
        elseif strcmp(color,'blue')
            NearXPt = find(min(abs(BluXBP-cpx)) == abs(BluXBP-cpx) & ...
                abs(BluXBP-cpx) < (Npts/200));
            NearYPt = abs(BluYBP(NearXPt)-cpy) < 0.01;
            if ~isempty(NearXPt)  &&  NearYPt
                BluXBP = [BluXBP(1:NearXPt-1); BluXBP(NearXPt+1:NBlu)];
                BluYBP = [BluYBP(1:NearXPt-1); BluYBP(NearXPt+1:NBlu)];
                NBlu = NBlu - 1;
                set(hPltBlu,'XData',BluXBP,'YData',BluYBP)
            end
        end

        rgbedit('regenerate')

        colormap(data)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'nocolor')

        color = 'none';
        set(hRed,'Label','  Red  ')
        set(hGre,'Label','  Green  ')
        set(hBlu,'Label','  Blue  ')
        set(hNone,'Label','X None  ')

        set(hPltRed,'ButtonDownFcn','','MarkerSize',5)
        set(hPltGre,'ButtonDownFcn','','MarkerSize',5)
        set(hPltBlu,'ButtonDownFcn','','MarkerSize',5)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'red')

        if strcmp(get(hFigure,'UserData'),'zoomon')
            rgbedit('zoomoff')
        end

        color = 'red';
        set(hRed,'Label','X Red  ')
        set(hGre,'Label','  Green  ')
        set(hBlu,'Label','  Blue  ')
        set(hNone,'Label','  None  ')

        set(hPltRed,'ButtonDownFcn','rgbedit(''buttondown'')','MarkerSize',25)
        set(hPltGre,'ButtonDownFcn','','MarkerSize',5)
        set(hPltBlu,'ButtonDownFcn','','MarkerSize',5)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'green')

        if strcmp(get(hFigure,'UserData'),'zoomon')
            rgbedit('zoomoff')
        end

        color = 'green';
        set(hRed,'Label','  Red  ')
        set(hGre,'Label','X Green  ')
        set(hBlu,'Label','  Blue  ')
        set(hNone,'Label','  None  ')

        set(hPltRed,'ButtonDownFcn','','MarkerSize',5)
        set(hPltGre,'ButtonDownFcn','rgbedit(''buttondown'')','MarkerSize',25)
        set(hPltBlu,'ButtonDownFcn','','MarkerSize',5)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'blue')

        if strcmp(get(hFigure,'UserData'),'zoomon')
            rgbedit('zoomoff')
        end

        color = 'blue';
        set(hRed,'Label','  Red  ')
        set(hGre,'Label','  Green  ')
        set(hBlu,'Label','X Blue  ')
        set(hNone,'Label','  None  ')

        set(hPltRed,'ButtonDownFcn','','MarkerSize',5)
        set(hPltGre,'ButtonDownFcn','','MarkerSize',5)
        set(hPltBlu,'ButtonDownFcn','rgbedit(''buttondown'')','MarkerSize',25)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'buttondown')

        cp = get(hRGB,'CurrentPoint');
        cpx = cp(1,1);
        cpy = cp(1,2);
        NearXPt = [];
        NearYPt = [];
        PointOK = 0;

        if strcmp(color,'none')
            set(hFigure,'WindowButtonMotionFcn','')
        elseif strcmp(color,'red')
            NearXPt = find(min(abs(RedXBP-cpx)) == abs(RedXBP-cpx) & ...
                abs(RedXBP-cpx) < (Npts/100));
            NearYPt = abs(RedYBP(NearXPt)-cpy) < 0.02;
            if ~isempty(NearXPt)  &&  NearYPt
                PointOK = 1;
                EditPt = ['RedYBP(',int2str(NearXPt),')'];
                set(hPltRed,'Erase','back')
            end
        elseif strcmp(color,'green')
            NearXPt = find(min(abs(GreXBP-cpx)) == abs(GreXBP-cpx) & ...
                abs(GreXBP-cpx) < (Npts/200));
            NearYPt = abs(GreYBP(NearXPt)-cpy) < 0.01;
            if ~isempty(NearXPt)  &&  NearYPt
                PointOK = 1;
                EditPt = ['GreYBP(',int2str(NearXPt),')'];
                set(hPltGre,'Erase','back')
            end
        elseif strcmp(color,'blue')
            NearXPt = find(min(abs(BluXBP-cpx)) == abs(BluXBP-cpx) & ...
                abs(BluXBP-cpx) < (Npts/200));
            NearYPt = abs(BluYBP(NearXPt)-cpy) < 0.01;
            if ~isempty(NearXPt)  &&  NearYPt
                PointOK = 1;
                EditPt = ['BluYBP(',int2str(NearXPt),')'];
                set(hPltBlu,'Erase','back')
            end
        end

        if PointOK
            set(hFigure,'WindowButtonMotionFcn','rgbedit(''mousemove'')')
            set(hFigure,'WindowButtonUpFcn','rgbedit(''buttonup'')')
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'mousemove')

        cp = get(hRGB,'CurrentPoint');
        cpy = cp(1,2);

        if cpy < 0, cpy = 0; end
        if cpy > 1, cpy = 1; end

        eval([EditPt,' = ',num2str(cpy),';'])

        if strcmp(color,'red')
            set(hPltRed,'YData',RedYBP)
        elseif strcmp(color,'green')
            set(hPltGre,'YData',GreYBP)
        elseif strcmp(color,'blue')
            set(hPltBlu,'YData',BluYBP)
        end

        rgbedit('regenerate')

        axes(hBar)
        colormap(data)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'buttonup')

        set(hFigure,'WindowButtonMotionFcn','')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'regenerate')

        if strcmp(color,'red')
            if NearXPt == 1
                start = NearXPt;
                stop = NearXPt;
            elseif NearXPt == NRed
                start = NearXPt-1;
                stop = NearXPt-1;
            else
                start = NearXPt-1;
                stop = NearXPt;
            end

            for i = start:stop
                deltaX = RedXBP(i+1) - RedXBP(i) + 1;
                deltaY = RedYBP(i+1) - RedYBP(i);
                if abs(deltaY) < 0.001
                    RedData(RedXBP(i):RedXBP(i+1)) = ones(deltaX,1)*RedYBP(i);
                else
                    Incr = deltaY / (deltaX - 1);
                    RedData(RedXBP(i):RedXBP(i+1)) = RedYBP(i):Incr:RedYBP(i+1);
                end
            end

        elseif strcmp(color,'green')
            if NearXPt == 1
                start = NearXPt;
                stop = NearXPt;
            elseif NearXPt == NGre
                start = NearXPt-1;
                stop = NearXPt-1;
            else
                start = NearXPt-1;
                stop = NearXPt;
            end

            for i = start:stop
                deltaX = GreXBP(i+1) - GreXBP(i) + 1;
                deltaY = GreYBP(i+1) - GreYBP(i);
                if abs(deltaY) < 0.001
                    GreData(GreXBP(i):GreXBP(i+1)) = ones(deltaX,1)*GreYBP(i);
                else
                    Incr = deltaY / (deltaX - 1);
                    GreData(GreXBP(i):GreXBP(i+1)) = GreYBP(i):Incr:GreYBP(i+1);
                end
            end

        elseif strcmp(color,'blue')
            if NearXPt == 1
                start = NearXPt;
                stop = NearXPt;
            elseif NearXPt == NBlu
                start = NearXPt-1;
                stop = NearXPt-1;
            else
                start = NearXPt-1;
                stop = NearXPt;
            end

            for i = start:stop
                deltaX = BluXBP(i+1) - BluXBP(i) + 1;
                deltaY = BluYBP(i+1) - BluYBP(i);
                if abs(deltaY) < 0.001
                    BluData(BluXBP(i):BluXBP(i+1)) = ones(deltaX,1)*BluYBP(i);
                else
                    Incr = deltaY / (deltaX - 1);
                    BluData(BluXBP(i):BluXBP(i+1));
                    (BluYBP(i):Incr:BluYBP(i+1))';
                    BluData(BluXBP(i):BluXBP(i+1)) = (BluYBP(i):Incr:BluYBP(i+1))';
                end
            end
        end

        data = [RedData GreData BluData];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'zoomon')

        rgbedit('nocolor')
        zoom xon
        set(hFigure,'UserData','zoomon')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'zoomoff')

        zoom off
        set(hBar,'XLim',get(hRGB,'XLim'))
        set(hFigure,'UserData','zoomoff')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(action,'zoomreset')

        zoom out
        set(hBar,'XLim',get(hRGB,'XLim'))

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
