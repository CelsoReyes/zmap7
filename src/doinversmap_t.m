%  doinvers
% This file calculates orintation of the stress tensor
% based on Gephard's algorithm.
% stress tensor orientation. The actual calculation is done
% using a call to a fortran program.
%
% Stefan Wiemer 03/96


global mi mif1 mif2 term  hndl3 a newcat2 fontsz mi2
global tmp cumu2
report_this_filefun(mfilename('fullpath'));
think

% select the gridpoints


if var1==1


    % get the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    ra = 5;

    % get the time periods of interest

    t1 = t0b;
    t4 = teb;
    t2 = t0b + (teb-t0b)/2;
    t3 = t2+0.01;


    def = {num2str(t1),num2str(t2),num2str(t3),num2str(t4)}
    tit ='differntial b-value map ';
    prompt={'T1 = ', 'T2= ', 'T3 = ', 'T4= '};

    ni2 = inputdlg(prompt,tit,1,def);
    l = ni2{4};
    t4 = str2double(l);
    l = ni2{3};
    t3 = str2double(l);
    l = ni2{2};
    t2 = str2double(l);
    l = ni2{1};
    t1 = str2double(l);


    %input window
    %
    %default parameters
    dx= .5;                      %grid spacing east-west
    dy= .5;                      %grid spacing north-south
    ldx=100;                     %side length of interaction zone in km
    tlap=300;                    %interaction time in days
    Mmin=3;                      %minimum magnitude
    stime=a(find(a(:,6)==max(a(:,6))),3);
    stime=stime(1);


    %create a input window
    figure_w_normalized_uicontrolunits(...
        'Name','Inversion Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 450 250]);
    axis off

    %create a dialog box for the input
    freq_field1=uicontrol('Style','edit',...
        'Position',[.60 .36 .15 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(dx));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .27 .15 .08],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dy));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .48 .15 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(ni));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');


    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','close; var1 = 2; doinversmap_t;',...
        'String','Go');

    txt4 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.50 0.74 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.35 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.25 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.5 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String',' # of EQ Ni:');

    set(gcf,'visible','on');
    watchoff

elseif var1==2           %area selection

    selgp
    % do the loop

    i2 = 0;
    clear howmany

    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;
        % calculate distance from center point and sort wrt distance
        %
        l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        % take first ni points
        %
        b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
        [st,ist] = sort(b);   % re-sort wrt time for cumulative count
        b = b(ist(:,3),:);

        % time 1
        l = b(:,3) >= t1 & b(:,3) < t2;
        tmp = [b(l,10:14)];
        comm = ['!mkdir /home2/stefan/stressinv/inA' num2str(i2)];
        anz = length(b(l,1));
        eval(comm)
        comm = ['save /home2/stefan/stressinv/inA' num2str(i2) '/data.inp tmp -ascii']
        eval(comm)
        pat = ['/home2/stefan/stressinv/inA' num2str(i2) '/anz' ];
        fid = fopen(pat,'w');
        fprintf(fid,'%3.0f\n',anz);
        fclose(fid);
        comm = ['save /home2/stefan/stressinv/inA' num2str(i2) '/loc.inp  x y  -ascii']
        eval(comm)
        % time 2
        l = b(:,3) >= t3 & b(:,3) <= t4;
        tmp = [b(l,10:14)];
        comm = ['!mkdir /home2/stefan/stressinv/inB' num2str(i2)];
        anz = length(b(l,1));
        eval(comm)
        comm = ['save /home2/stefan/stressinv/inB' num2str(i2) '/data.inp tmp -ascii']
        eval(comm)
        comm = ['save /home2/stefan/stressinv/inB' num2str(i2) '/loc.inp  x y  -ascii']
        eval(comm)
        pat = ['/home2/stefan/stressinv/inB' num2str(i2) '/anz' ];
        fid = fopen(pat,'w');
        fprintf(fid,'%3.0f\n',anz);
        fclose(fid);


    end



    cd /home2/stefan/stressinv
    save tmpinv.mat

    return

    le = length(newgri)

    for i = 1:le
        str = ['./doinvers_linux.sh inA' num2str(i) ];
        if i == 1
            do = [' !echo #csh  > loop_taupo1.sh ' ]; eval(do);
            do = [' !echo ' str ' >> loop_taupo1.sh ' ]; eval(do);
        else
            do = [' !echo ' str ' >> loop_taupo1.sh ' ]; eval(do);
        end
    end
    !chmod 777 loop_taupo1.sh

    for i = 1:le
        str = ['./doinvers_hp.sh inB' num2str(i)  ];
        if i == 1
            do = [' !echo #csh  > loop_blubb.sh ' ]; eval(do);
            do = [' !echo ' str ' >> loop_blubb.sh ' ]; eval(do);
        else
            do = [' !echo ' str ' >> loop_blubb.sh ' ]; eval(do);
        end
    end
    !chmod 777 loop_blubb.sh




end  % var = 2



