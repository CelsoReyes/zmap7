function incube()
    % This subroutine assigns Parameter values for the grid
    % which is used to calculate a Max Z value map.
    % dx, dy is the grid spacing in degrees.
    % For each one of the grid points, Ni events are counted.
    %
    
    global step iwl2
    report_this_filefun(mfilename('fullpath'));
    
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
    ni = 100;
    
    %
    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Alarm Cube Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 450 250]);
    axis off
    
    % creates a dialog box to input grid parameters
    %
    freq_field  =uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(step),...
        'callback',@callbackfun_001);
    
    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'callback',@callbackfun_002);
    
    uicontrol('Units','normal',...
        'Position',[.1 .70 .20 .12] ,'String','Load Alarm',...
        'callback',@callbackfun_003)
    
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.80 .05 .15 .12 ],...
        'Units','normalized','callback',@callbackfun_004,'String','Cancel');
    
    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.10 .05 .35 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_005,...
        'String','Rubberband');
    
    go_button2=uicontrol('Style','Pushbutton',...
        'Position',[.50 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_006,...
        'String','LTA');
    
    
    txt3 = text(...
        'Position',[0.30 0.84 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'Color','r' ,...
        'FontWeight','bold',...
        'String',' Alarm Cube Parameters ');
    
    
    txt5 = text(...
        'Position',[0. 0.42 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time length of iwl in years');
    
    txt6 = text(...
        'Position',[0. 0.20 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Select one of the statistics below ');
    
    txt1 = text(...
        'Position',[0. 0.53 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Step width (Integer): ');
    
    
    set(gcf,'visible','on');
    watchoff
    
    function allhist(sta)
        % ZMAP script allhist.m.
        % calculates a histogram of all z-value in space and time
        % using the rubberband function with a window length of 1.5 years
        %
        % stefan wiemer 11/94
        %
        % sta : either rub (rubber band) or lta
        
        global iala
        
        % Input Rubberband
        %
        report_this_filefun(mfilename('fullpath'));
        
        tre2 = 4.00;
        
        clear abo;
        abo=[];
        
        % initial parameter
        iwl = floor(iwl2* 365/ZG.bin_days);
        [len, ncu] = size(cumuall); len = len-2;
        var1 = zeros(1,ncu);
        var2 = zeros(1,ncu);
        mean1 = zeros(1,ncu);
        mean2 = zeros(1,ncu);
        as = zeros(1,ncu);
        n2 = [];
        
        
        % loop over all grid points for percent
        %
        %
        
        % loop over all point for rubber band
        %
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Allhist - Percent done');
        pause(1)
        think
        drawnow
        
        n2 = zeros(1,length(-15:0.1:15));
        if sta == 'lta'
            
            for ti = iwl:step:len-iwl
                cu = [cumuall(1:ti-1,:) ; cumuall(ti+iwl+1:len,:)];
                mean1 = mean(cu);
                mean2 = mean(cumuall(ti:ti+iwl,:));
                for i = 1:ncu
                    var1(i) = cov(cu(:,i));
                    var2(i) = cov(cumuall(ti:ti+iwl,i));
                end     % for i
                as = (mean1 - mean2)./(sqrt(var1/(len-iwl)+var2/iwl));
                [m,n] = size(as);
                reall = reshape(as,1,m*n);
                
                % set values gretaer tresh = nan
                %
                %s = cumuall(len,:);
                %r = reshape(as,length(gy),length(gx));
                l = reall > tre2;
                s = [  loc(1,l) loc(2,l) loc(3,l)   reall(l) ];
                s = [reshape(s,length(s)/4,4) ones(length(s)/4,1)*ti];
                abo = [abo ;  s];
                [n,x] =histogram(reall,(-15:0.10:15));
                n2 = n2 + n;
                waitbar((ti-iwl)/(len-2*iwl))
            end   % for ti
        end % if lta
        
        if sta == 'rub'
            for ti = iwl:step:len-iwl
                for i = 1:ncu
                    mean1(i) = mean(cumuall(1:ti,i));
                    mean2(i) = mean(cumuall(ti+1:ti+iwl,i));
                    var1(i) = cov(cumuall(1:ti,i));
                    var2(i) = cov(cumuall(ti+1:ti+iwl,i));
                end %  for i ;
                as = (mean1 - mean2)./(sqrt(var1/ti+var2/iwl));
                
                
                [m,n] = size(as);
                reall = reshape(as,1,m*n);
                
                % set values gretaer tresh = nan
                %
                s = cumuall(len,:);
                %r = reshape(s,length(gy),length(gx));
                l = reall > tre2;
                s = [  loc(1,l) loc(2,l) loc(3,l)   reall(l) ];
                s = [reshape(s,length(s)/4,4) ones(length(s)/4,1)*ti];
                abo = [abo ;  s];
                
                [n,x] =histogram(reall,(-15:0.10:15));
                n2 = n2 + n;
                waitbar((ti-iwl)/(len-2*iwl))
            end   % for ti
        end   % if riub
        
        close(wai)
        figure
        bar(x,n2,'k');
        grid
        xlabel('z-value ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        watchoff
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.l,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on')
        
        set(gca,'Color',[1 1 0.7])
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
            'callback',@callbackfun_007)
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
            'callback',@callbackfun_008)
        
        
        abo2 = abo;
        iala = iwl2;
        try
            zmap_message_center.set_info('Save Alarm Cube?','  ');
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Save Alarm Cube Datafile?',400,400);
            sapa2 = ['save ' path1 file1 ' cumuall abo loc abo2 iala iwl2'];
            if length(file1) > 1
                eval(sapa2);
            end
        catch ME
            warning(ME)
        end
        done
        
        
        done;
        % plot the cube
        plotala()
    end
    
    function loadala()
        % Load the alarm data set
        % TODO Define what is an alarm datafile
        report_this_filefun(mfilename('fullpath'));
        
        cupa = cd;
        
        try
            delete(pd)
        catch ME
            error_handler(ME, ' ');
        end
        
        [file1,path1] = uigetfile(['*.mat'],'Alarm Data File?');
        
        if length(path1) > 1
            load([path1 file1])
            plotala()
        else
            return
        end
        
    end
end
function callbackfun_001(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    step=str2double(freq_field.String);
    freq_field.String=num2str(step);
end

function callbackfun_002(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    iwl2=str2double(freq_field2.String);
    freq_field2.String=num2str(iwl2);
end

function callbackfun_003(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    close;
    loadala;
end

function callbackfun_004(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    close;
    done;
end

function callbackfun_005(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    close;
    allhist('rub');
end

function callbackfun_006(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    close;
    allhist('lta');
end

function callbackfun_007(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    myprint;
end

function callbackfun_008(mysrc,myevt)
    % automatically created callback function from text
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    f1=gcf;
    f2=gpf;
    set(f1,'Visible','off');
    if f1~=f2;
        zmap_message_center();
        done;
    end
end

