%  This subroutine "setup.m" allows the user to setup
%  the earthquake datafile, overlaying faults, mainshocks

% make the interface

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('Load ASCIwI Data',1);
newMapWindowFlag=~existFlag;


% Set up the setup window Enviroment
%
if newMapWindowFlag
    loasci = figure_w_normalized_uicontrolunits( ...
        'Name','Load ASCII Data',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Visible','off', ...
        'Position',[ 100 500 950 250]);
    set(gca,'visible','off');

    set(gca,'box','off',...
        'SortMethod','childorder','TickDir','out','FontWeight','bold',...
        'visible','off','FontSize',fontsz.m,'Linewidth',1.2)

    set(loasci,'Visible','on');
    figure_w_normalized_uicontrolunits(loasci)

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.65 .13 .25 .10 ],...
        'Units','normalized','Callback','close; setup','String','Close');

    load_button=uicontrol('Style','Pushbutton',...
        'Position',[.15 .13 .25 .10 ],...
        'Units','normalized',...
        'Callback','sa =''on'';loadasci',...
        'String','Load ');

end   %if figure exist

% load earthquake data
%
if da == 'eq'

    te = text(0.03,0.96,'Please setup an ascii file (e.g., data.dat) in the following format:');

    t2 = text(0.03,0.82,'lon          lat    year  month   day  mag  depth  hour   min ') ;
    t3 = text(0.03,0.68,' -116.86  34.35   1986        03     27    4.21    15.0   10   25 ') ;

    t4 = text(0.03,0.40,'Press <Load> when you are ready to load this file.');
    set(te,'FontSize',fontsz.m,'FontWeight','bold')
    set(t2,'FontSize',fontsz.m,'Color','r','FontWeight','bold')
    set(t3,'FontSize',fontsz.m,'FontWeight','bold')
    set(t4,'FontSize',fontsz.m,'FontWeight','bold')

    %Load earthquake data
    if sa =='on'
        str = []; sa = 'of';
        [file1, newpath] = uigetfile('*', 'Load EQ Data File');
        if length(newpath) >  1
            think;drawnow
            load  ([newpath file1])
            do = find(file1 == '.');
            if isempty(do) == 1; do = length(file1)+1;end
            tr = file1(1:do-1);
            befehl=['a = ',tr,';'];
            eval(befehl);
            clear(tr)
            %check for 0 in day or month - set to 1
            l = a.Date.Day == 0; a(l,5) = 1;
            l = a.Date.Month == 0; a(l,4) = 1;

            if length(a(1,:))== 7
                a.Date = decyear(a(:,3:5));
            elseif length(a(1,:))>=9       %if catalog includes hr and minutes
                a.Date = decyear(a(:,[3:5 8 9]));
            end

            % Sort the catalog in time just to make sure ...
            [s,is] = sort(a.Date);
            a = a(is(:,1),:) ;
            minmag = max(a.Magnitude) -0.2;       %  as a default to be changed by inpu

            close;done;inpu;setup
        else
            close, setup
        end % if
    end   %if sa
end   % if da == eq

%load focal mechanism data
if da == 'fo'

    te = text(0.03,0.96,'Please setup an ascii file (e.g., data.dat) in the following format (12 or 13 colums):');

    t2 = text(0.03,0.82,'lon          lat    year  month   day  mag  depth  hour   min dip-direction dip  rake (otional: solution uncertainty) ') ;
    t3 = text(0.03,0.68,' -116.86  34.35   86        03     27    4.21    15.0   10   2  5     230      75                 137    ') ;

    t4 = text(0.03,0.40,'Press <Load> when you are ready to load this file.');
    set(te,'FontSize',fontsz.m,'FontWeight','bold')
    set(t2,'FontSize',fontsz.m,'Color','r','FontWeight','bold')
    set(t3,'FontSize',fontsz.m,'FontWeight','bold')
    set(t4,'FontSize',fontsz.m,'FontWeight','bold')

    %load focal mechanism data
    if sa =='on'
        str = []; sa = 'of';
        [file1, newpath] = uigetfile('*.m', 'Load EQ Data File');
        if length(newpath) >  1
            think;drawnow
            load  ([newpath file1])
            do = find(file1 == '.');
            if isempty(do) == 1; do = length(file1)+1;end
            tr = file1(1:do-1);
            befehl=['a = ',tr,';'];
            eval(befehl);
            clear(tr)
            %check for 0 in day or month - set to 1
            l = a.Date.Day == 0; a(l,5) = 1;
            l = a.Date.Month == 0; a(l,4) = 1;

            if length(a(1,:))== 7
                a.Date = decyear(a(:,3:5));
            elseif length(a(1,:))>=9       %if catalog includes hr and minutes
                a.Date = decyear(a(:,[3:5 8 9]));
            end
            % create a 13 column if none exists and set it to zero

            if length(a(1,:))< 13 ; a = [a ; a(:,12)*0]; end

            % Sort the catalog in time just to make sure ...
            [s,is] = sort(a.Date);
            a = a(is(:,1),:) ;
            minmag = max(a.Magnitude) -0.2;       %  as a default to be changed by inpu
            % set up the focal mechanism data
            %prepfocal

            close;done;inpu;setup
        else
            close, setup
        end % if
    end   %if sa
end   % if da == eq



% load faults data
%
if da == 'fa'

    te = text(0.03,0.96,'Please setup an ascii file in the following format:');
    t2 = text(0.03,0.82,'lon        lat ') ;
    t3 = text(0.03,0.68,' -116.86  34.35 ') ;
    t4 = text(0.03,0.50,'If the file contains more than one fault #use   inf inf   to seperate the faults.#Press <Load> when you are ready to load this file.');

    set(te,'FontSize',fontsz.m,'FontWeight','bold')
    set(t2,'FontSize',fontsz.m,'Color','r','FontWeight','bold')
    set(t3,'FontSize',fontsz.m,'FontWeight','bold')
    set(t4,'FontSize',fontsz.m,'FontWeight','bold')

    %save faults data
    if sa =='on'
        str = []; sa = 'of';
        [file1, newpath] = uigetfile('*.m', 'Load Faults Data File');
        if length(newpath) >  1
            think;drawnow
            load  ([newpath file1])
            do = find(file1 == '.');
            if isempty(do) == 1; do = length(file1)+1;end
            tr = file1(1:do-1);
            befehl=['faults = ',tr,';'];
            eval(befehl);
            %    clear(tr)
            close;done;mainmap_overview(); setup
        else
            close, setup
        end % if
    end   %if sa
end   % if da == fa

% load main faults data
%
if da == 'mf'

    te = text(0.03,0.96,'Please setup an ascii file in the following format:');
    t2 = text(0.03,0.82,'lon        lat ') ;
    t3 = text(0.03,0.68,' -116.86  34.35 ') ;
    t4 = text(0.03,0.50,'If the file contains more than one continous segment #use  <inf inf> to seperate the segments.#Press <Load> when you are ready to load this file.');

    set(te,'FontSize',fontsz.m,'FontWeight','bold')
    set(t2,'FontSize',fontsz.m,'Color','r','FontWeight','bold')
    set(t3,'FontSize',fontsz.m,'FontWeight','bold')
    set(t4,'FontSize',fontsz.m,'FontWeight','bold')

    %save main faults data
    if sa =='on'
        str = []; sa = 'of';
        [file1, newpath] = uigetfile('*.m', 'Load main Faults Data File');
        if length(newpath) >  1
            think;drawnow
            load  ([newpath file1])
            do = find(file1 == '.');
            if isempty(do) == 1; do = length(file1)+1;end
            tr = file1(1:do-1);   befehl=['mainfault = ',tr,';'];
            eval(befehl);
            %  clear(tr)
            close;done;mainmap_overview(); setup
        else
            close, setup
        end % if
    end   %if sa
end   % if da == mf

% load mainshock data
%
if da == 'ma'

    te = text(0.03,0.96,'Please setup an ascii file in the following format:');
    t2 = text(0.03,0.82,'lon        lat ') ;
    t3 = text(0.03,0.68,' -116.86  34.35 ') ;
    t4 = text(0.03,0.50,  'Press <Load> when you are ready to load this file.');

    set(te,'FontSize',fontsz.m,'FontWeight','bold')
    set(t2,'FontSize',fontsz.m,'Color','r','FontWeight','bold')
    set(t3,'FontSize',fontsz.m,'FontWeight','bold')
    set(t4,'FontSize',fontsz.m,'FontWeight','bold')

    %save faults data
    if sa =='on'

        str = []; sa = 'of';
        [file1, newpath] = uigetfile('*.m', 'Load Mainshock Data File');
        if length(newpath) >  1
            think;drawnow
            load  ([newpath file1])
            do = find(file1 == '.');
            if isempty(do) == 1; do = length(file1)+1;end
            tr = file1(1:do-1);
            befehl=['main = ',tr,';'];
            eval(befehl);
            %  clear(tr)
            close;done; mainmap_overview();setup
        else
            close, setup
        end % if
    end   %if sa
end   % if da == ma

% load coastline data
%
if da == 'co'

    te = text(0.03,0.96,'Please setup an ascii file in the following format:');
    t2 = text(0.03,0.82,'lon        lat ') ;
    t3 = text(0.03,0.68,' -116.86  34.35 ') ;
    t4 = text(0.03,0.50,'If the file contains more than one continuos line#use   <inf inf>   to seperate the segments.#Press <Load> when you are ready to load this file.');

    set(te,'FontSize',fontsz.m,'FontWeight','bold')
    set(t2,'FontSize',fontsz.m,'Color','r','FontWeight','bold')
    set(t3,'FontSize',fontsz.m,'FontWeight','bold')
    set(t4,'FontSize',fontsz.m,'FontWeight','bold')

    %save coastline data
    if sa =='on'
        str = []; sa = 'co';
        [file1, newpath] = uigetfile('*.m', 'Load Coastline Data File');
        if length(newpath) >  1
            think;drawnow
            load  ([newpath file1])
            do = find(file1 == '.');
            if isempty(do) == 1; do = length(file1)+1;end
            tr = file1(1:do-1);
            befehl=['coastline = ',tr,';'];
            eval(befehl);
            %clear(tr)
            close;done; mainmap_overview();setup
        else
            close, setup
        end % if
    end   %if sa
end   % if da == co

