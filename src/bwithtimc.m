%%
% Calculates b based on time using Mc and plots it - called from
% cumulative window
%%


report_this_filefun(mfilename('fullpath'));

if selt == 'in'

    figure_w_normalized_uicontrolunits(...
        'Name','b with time input parameters',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ 200 200 450 250]);
    axis off

    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];
    labelPos = [0.2 0.85  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',5);

    time_button = uicontrol('Style','checkbox',...
        'string','Constant time',...
        'Position',[.20 .70 .6 .12], 'Callback','set(ni_button,''value'',0)',...
        'Units','normalized');

    set(time_button,'value',1);


    ni_button =  uicontrol('Style','checkbox',...
        'string','Constant number of events',...
        'Position',[.20 .58 .6 .12], 'Callback','set(time_button,''value'',0)',...
        'Units','normalized');


    inter_field=uicontrol('Style','edit',...
        'Position',[.20 .50 .6 .12],...
        'Units','normalized','String',num2str(inter),...
        'Callback','inter=str2double(get(inter_field,''String'')); set(inter_field,''String'',num2str(inter));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inpr1 = get(hndl2,''Value'');time_button =get(time_button,''Value'');ni_button =get(ni_button,''Value'');close,selt =''ca'';, bwithtimc',...
        'String','Go');

    inter_txt=text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 .42 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Constant time or event interval');


    set(gcf,'visible','on');
    watchoff
end  %% end of if self == in

if selt == 'ca'

    %%
    % set step_cat as a dummy variable so that newt2 can be reassigned
    % for use in mcperc_ca3.  newt2 is reset at end.
    %%

    step_cat = newt2;

    bv2 = [];
    bv3 = [] ;
    me = [];
    bvm = [];
    ctr = 0;
    i=1;
    Nmin=50;
    b=newt2;  %% initialization for bvalca3.m
    day_start=0;
    day_end=0;
    %def = {'150'};
    %ni2 = inputdlg('Number of events in each window?','Input',1,def);
    %l = ni2{:};
    %ni = str2double(l);

    if time_button == 1
        decy=inter/365.0;
        starty = min(step_cat(:,3));
        endy = max(step_cat(:,3));
        for ind = starty:decy:endy-decy
            day_start = min(find(step_cat(:,3) >= starty+(ctr*decy)));
            day_end = min(find(step_cat(:,3) >= step_cat(day_start,3)+decy));
            newt2 = step_cat(day_start:day_end,:);



            %%
            % calculation based on 90% probability
            %%
            if inpr1 == 3
                mcperc_ca3;
                l = newt2.Magnitude >= Mc90-0.05;
                magco = Mc90;
                if length(newt2(l,6)) >= Nmin
                    disp(['%%Warning --bwithtimc--%%  less than 50 events in step ', step_cat(day_end,3)]);
                end


                %%
                % calculation based on 95% probability
                %%
            elseif inpr1 == 4
                mcperc_ca3;
                l = newt2.Magnitude >= Mc95-0.05;
                magco = Mc95;
                if length(newt2(l,6)) <= Nmin
                    disp(['%%Warning --bwithtimc--%%  less than 50 events in step ', step_cat(day_end,3)]);
                end
                %%
                % calculation based on best combination of 90% and 95% probability -- default
                %%

            elseif inpr1 == 5
                mcperc_ca3;
                if isnan(Mc95) == 0 
                    magco = Mc95;
                elseif isnan(Mc90) == 0 
                    magco = Mc90;
                else
                    [bv magco stan av me mer me2,  pr] =  bvalca3(newt2.Magnitude,1,1);
                end
                l = newt2.Magnitude >= magco-0.05;
                if length(newt2(l,6)) <= Nmin
                    disp(['%%Warning --bwithtimc--%%  less than 50 events in step ', step_cat(day_end,3)]);
                end

                %%
                % calculation based on MAX CURVATURE
                %%
            elseif inpr1 == 1
                [bv magco stan av me mer me2,  pr] =  bvalca3(newt2.Magnitude,1,1);
                l = newt2.Magnitude >= magco-0.05;
                if length(newt2(l,:)) <= Nmin
                    disp(['%%Warning --bwithtimc--%%  less than 50 events in step ', step_cat(day_end,3)]);
                end

                %%
                % calculation based on FIXED Mc
                %%
            elseif inpr1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(newt2.Magnitude,2,2);
            end


            [mea bv stand,  av] = bmemag(newt2(l,:));


            %       mcperc_ca3;
            %       if isnan(Mc95) == 0 
            %          magco = Mc95;
            %       elseif isnan(Mc90) == 0 
            %          magco = Mc90;
            %       else
            %          [bv magco stan av me mer me2,  pr] =  bvalca3(newt2.Magnitude,1,1);
            %       end
            %       l = newt2.Magnitude >= magco-0.05;
            %       if length(newt2(l,6)) <= 50
            %          disp(['%%Warning --bwithtimc--%%  less than 50 events in step ', step_cat(day_end,3)]);
            %       end
            %       [mea bv stand,  av] = bmemag(newt2(l,:));

            events = length(step_cat(1:day_end,6))-length(step_cat(1:day_start,6));

            bvm = [bvm; bv step_cat(day_end,3) magco events];
            ctr = ctr + 1;
        end   %% end of for

    elseif ni_button == 1
        ni = inter;
        for ind = 1:ni:length(step_cat)-ni
            newt2 = step_cat(ind:ind+ni,:);
            mcperc_ca3;
            if isnan(Mc95) == 0 
                magco = Mc95;
            elseif isnan(Mc90) == 0 
                magco = Mc90;
            else
                [bv magco stan av me mer me2,  pr] =  bvalca3(newt2.Magnitude,1,1);
            end
            l = newt2.Magnitude >= magco-0.05;
            if length(newt2(l,6)) <= 50
                disp('%%Warning --bwithtimc--%%  less than 50 events in step');
            end
            meb = newt2(l,:);
            [mea bv stand,  av] = bmemag(meb);

            days = (max(newt2.Date)-min(newt2.Date))*365.0;

            bvm = [bvm; bv step_cat(ind+ni,3) magco days];
        end  %% end of for loop!!
    end

    think

    %% [bv magco,  stan] =  bvalcalc(step_cat(i:i+ni,:));
    % [bv magco stan ] =  bvalca2(step_cat(i:i+ni,:));
    % [ mema bmean sigb ] = bmemag(step_cat(i:i+ni,:));

    % bv2 = [bv2 ; bv step_cat(i+ni,3) stan];
    % bv3 = [bv3 ; bv step_cat(i,3) ; bv step_cat(i+ni-1,3) ; inf inf];
    % me = [me ; step_cat(i+ni,3) mema bmean sigb];


    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('b-value with time',1);
    newdepWindowFlag=~existFlag;
    bdep= figNumber;

    % Set up the window

    if newdepWindowFlag
        bdep = figure_w_normalized_uicontrolunits( ...
            'Name','b-value with time',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','on');

        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
             'Callback','infoz(1)');
        matdraw
        uicontrol('Style','Pushbutton',...
            'Position',[.0 .05 .10 .08 ],...
            'Units','normalized',...
            'Callback',',selt =''pl'';, bwithtimc','String','bin plot')

    end

    hold on
    figure_w_normalized_uicontrolunits(bdep)
    hold on
    delete(gca)
    delete(gca)
    axis off

    %rect = [0.15 0.70 0.7 0.25];

    %%
    % plot for least squares solution
    %%

    %axes('position',rect)
    %errorbar(bv2(:,2),bv2(:,1),bv2(:,3))
    %hold on
    %pl = plot(bv3(:,2),bv3(:,1),'b')
    %set(pl,'LineWidth',1.0)

    %set(pl,'LineWidth',2.5)
    %grid
    %set(gca,'Color',color_bg)
    %set(gca,'box','on',...
    %        'SortMethod','childorder','TickDir','out','FontWeight',...
    %        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    %
    %ylabel('b-value')
    %set(gca,'Xlim',[t0b teb]);


    %%
    % not sure what this is for
    %%

    %rect = [0.15 0.30 0.7 0.25];
    %axes('position',rect)
    %pl = plot(me(:,1),me(:,2))
    %set(pl,'LineWidth',2.5)
    %set(gca,'Xlim',[t0b teb]);
    %grid
    %set(gca,'Color',color_bg)
    %set(gca,'box','on',...
    %'SortMethod','childorder','TickDir','out','FontWeight',...
    %'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    %
    %ylabel('mean magnitude')
    %

    %%
    % plotting for max likelihood method
    %%

    rect = [0.15 0.60 0.7 0.30];
    axes('position',rect)

    plot(bvm(:,2),bvm(:,1),'--b*')

    grid
    set(gca,'Color',color_bg)
    set(gca,'Xlim',[t0b teb]);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

    ylabel('b-value')
    title('b value with time  based on Maximum Likelihood');

    %plot(bvm(:,2),bvm(:,1),':ks')

    rect = [0.15 0.15 0.7 0.30];
    axes('position',rect)

    plot(bvm(:,2),bvm(:,3),'--kx')

    grid
    set(gca,'Color',color_bg)
    set(gca,'Xlim',[t0b teb]);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

    ylabel('Mc')
    xlabel('Time')
    title('Mc with time  based on Maximum Likelihood');
    done

    newt2 = step_cat;
end  %% end of if sel == ca



if selt == 'pl'



    figure
    plot(bvm(:,4))
    xlabel('Bin');
    if time_button == 1
        ylabel('Number of Events');
        title('Number of Events per Bin');
    elseif ni_button == 1
        ylabel('Number of Days');
        title('Number of Days per Bin');
    end
end
