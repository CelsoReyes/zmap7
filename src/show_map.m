function show_map(calc_type, in2, compare_window_dur) 
    % ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
    % does the calculation and makes displays the map
    % stefan wiemer 11/94
    %
    % make dialog interface and call maxzlta
    %
    % turned into function by Celso G Reyes 2017
    
    %FIXME (maybe) changing compare_window_dur doesn't change the global version.
    
    % Input Rubberband
    %
    report_this_filefun();
    
    % compare_window_dur is shared among the parts of this function
    it=[]
    
    
    if in2 ~= 'calma'
        create_the_figure(calc_type)
    else
        do_calma(calc_type)
    end
    
    function create_the_figure(calc_type)
        %initial values
        ZG=ZmapGlobal.Data; % used by get_zmap_globals
        ZG.compare_window_dur_v3 = years(1.5);
        it = t0b +1;
        figure(mess);
        clf
        set(gca,'visible','off')
        set(gcf,'Units','pixel','NumberTitle','off','Name','Input Parameters');
        
        set(gcf,'pos',[ ZG.welcome_pos, ZG.welcome_len +[200, -50]]);
        
        
        % creates a dialog box to input some parameters
        %
        add_timecut_controls(it)
        
        if calc_type == "rub" || calc_type == "lta"
            add_compareduration_controls(compare_window_dur)
        end
        
        uicontrol('Style','Pushbutton',...
            'Position', [.60 .05 .15 .15 ],...
            'Units','normalized',...
            'Callback',@(~,~)close(),...
            'String','Cancel');
        
        uicontrol('Style','Pushbutton',...
            'Position',[.25 .05 .15 .15 ],...
            'Units','normalized',...
            'callback',@cb_go,...
            'String','Go');
        
        set(gcf,'visible','on');
        watchoff
    end
    
    function do_calma(calc_type)
        % check if time are with limits
        %
        if ~exist('it', 'var')
            it = t0b + (teb-t0b)/2;
        end
        if it + compare_window_dur > teb || it < t0b
            errordlg('Time out of limits')
            in2 = 'nocal';
            show_map
        end
        
        
        % initial parameter
        winlen_days = floor(compare_window_dur/ZG.bin_dur); 
        ti = floor((it -t0b)/days(ZG.bin_dur));
        [len, ncu] = size(cumuall); 
        len = len-2;
        var1 = zeros(1,ncu);
        var2 = zeros(1,ncu);
        mean1 = zeros(1,ncu);
        mean2 = zeros(1,ncu);
        as = zeros(1,ncu);
        
        
        % loop over all grid points for percent
        %
        %
        switch calc_type
            case 'per'
                [as, strib, stri2] = calc_percent_change();   
            case 'rub'
                [as, var1, var2] = calc_rubberband(ncu, ti, winlen_days);
            case 'ast'
                [as, var1, var2] = calc_ast(ncu, ti, len);
            case 'lta'
                [as, var1, var2] = calc_lta(ncu, ti, winlen_days, len, cumuall);
            case 'maz'
                [maxlta, maxlta2, mean1, mean2] = calc_maz(ncu, cumuall, len);
            otherwise
                error('ZMAP:show_map:unknownOperation','not sure which operation to do')
        end
        
        %normalisation of lap1
        normlap1=nan(length(tmpgri(:,1)),1)
        normlap2=nan(length(tmpgri(:,1)),1)
        
        lv = logical(ll) ;  % having to do with the grid(?)
        normlap2(lv)= as(:);
        %construct a matrix for the color plot
        valueMap=reshape(normlap2,length(yvect),length(xvect));
        
        
        [n1, n2] = size(cumuall);
        s = cumuall(n1,:);
        normlap2(lv)= s(:);
        %construct a matrix for the color plot
        r = reshape(normlap2, length(yvect), length(xvect));
        ZG.tresh_km = max(r(:));
        % find max and min of data for automatic scaling
        %
        ZG.maxc = max(valueMap(:));
        ZG.maxc = fix(max(valueMap(:)))+1;
        ZG.minc = min(valueMap(:));
        ZG.minc = fix(min(valueMap(:)))-1;
        %plot imge
        %
        det = 'nop';
        old = valueMap;
        view_max(valueMap,gx,gy,stri,'nop')
        

    end
    
    function add_timecut_controls(default_value)
        uicontrol('Style','edit',...  # was inp2_field
            'Position',[.80 .775 .18 .15],...
            'Units','normalized',...
            'String',num2str(default_value),...
            'callback',@cb_timecut_year);
        
        text(...  #was txt2
            'Position',[0. 0.9 0 ],...
            'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'String','Please input time of cut in years (e.g. 86.5):');
    end
    
    function add_compareduration_controls(compare_window_dur)
        text(...  # was txt3
            'Position',     [0. 0.65 0 ],...
            'FontWeight',   'bold',...
            'FontSize',     ZmapGlobal.Data.fontsz.m ,...
            'String',       'Please input window length in years (e.g. 1.5):');
        uicontrol('Style',  'edit',...
            'Position',     [.80 .575 .18 .15],...
            'Units',        'normalized',...
            'String',       num2str(years(compare_window_dur)),...
            'callback',     @cb_window_duration_edit);
    end
    
    %% callbacks
    
    function cb_timecut_year(mysrc,~)
        it = str2double(mysrc.String);
    end
    
    function cb_window_duration_edit(mysrc,~)
        compare_window_dur = years(str2double(mysrc.String));
    end
    
    function cb_go(mysrc, myevt)
        watchon;
        drawnow;
        do_calma(calc_type);
    end
end

%% calculation functions

function [as, strib, stri2] = calc_percent_change(cumuall, ti, len)
    for i = ncu:-1:1
        mean1(i) = mean(cumuall(1:ti,i));
        mean2(i) = mean(cumuall(ti:len,i));
    end    %for i
    
    as = -((mean1-mean2)./mean1)*100;
    
    strib = 'Change in Percent';
    stri2 = ['ti=' num2str(ti*days(ZG.bin_dur) + t0b)  ];
end

function [as, var1, var2] = calc_rubberband(ncu, ti, winlen_days)
    for i = ncu:-1:1
        mean1(i) = mean(cumuall(1:ti,i));
        mean2(i) = mean(cumuall(ti+1:ti+winlen_days,i));
        var1(i) = cov(cumuall(1:ti,i));
        var2(i) = cov(cumuall(ti+1:ti+winlen_days,i));
    end %  for i ;
    as = (mean1 - mean2)./(sqrt(var1/ti+var2/winlen_days));
end

function [as, var1, var2] = calc_ast(ncu, ti, len)
    for i = ncu:-1:1
        mean1(i) = mean(cumuall(1:ti,i));
        var1(i) = cov(cumuall(1:ti,i));
        mean2(i) = mean(cumuall(ti+1:len,i));
        var2(i) = cov(cumuall(ti+1:len,i));
    end
    as = (mean1 - mean2)./(sqrt(var1/ti+var2/(len-ti)));
end

function [as, var1, var2] = calc_lta(ncu, ti, winlen_days, len, cumuall)
    mean1 = mean([cumuall(1:ti-1,:) ; cumuall(ti+winlen_days+1:len,:)]);
    mean2 = mean(cumuall(ti:ti+winlen_days,:));
    for i = ncu : -1 : 1
        var1(i) = cov([cumuall(1:ti-1,i) ; cumuall(ti+winlen_days+1:len,i)]);
        var2(i) = cov(cumuall(ti:ti+winlen_days,i));
    end     % for i
    as = (mean1 - mean2)./(sqrt(var1/(len-winlen_days)+var2/winlen_days));
end

function [maxlta, maxlta2, mean1, mean2] = calc_maz(ncu, cumuall, len)
            maxlta = zeros(1,ncu);
            maxlta = maxlta -5;
            mean1 = mean(cumuall(1:len,:));
            wai = waitbar(0,'Please wait...');
            set(wai,'Color',[0.8 0.8 0.8], 'NumberTitle','off', 'Name','Percent done');
            
            for i = ncu:-1:1
                var1(i) = cov(cumuall(1:len,i));
            end
            
            for ti = 1:step: len - winlen_days
                waitbar(ti/len)
                mean1 = mean(cumuall(1:len,:));
                mean2 = mean(cumuall(ti:ti+winlen_days,:));
                for i = 1:ncu
                    var1(i) = cov(cumuall(1:len,i));
                    var2(i) = cov(cumuall(ti:ti+winlen_days,i));
                end
                as = (mean1 - mean2)./(sqrt(var1/len+var2/winlen_days));
                maxlta2 = [maxlta ;  as ];
                maxlta = max(maxlta2);
            end
            %as = reshape(maxlta,length(gy),length(gx));
            close(wai)
end