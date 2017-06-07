% ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
% does the calculation and makes displays the map
% stefan wiemer 11/94
%
% make dialog interface and call maxzlta
%


% Input Rubberband
%
report_this_filefun(mfilename('fullpath'));

if in2 ~= 'calma'

    %initial values
    iwl3 = 1.5;
    it = t0b +1;
    figure_w_normalized_uicontrolunits(mess)
    clf
    set(gca,'visible','off')
    set(gcf,'Units','pixel','NumberTitle','off','Name','Input Parameters');

    set(gcf,'pos',[ wex  wey welx+200 wely-50])


    % creates a dialog box to input some parameters
    %

    inp2_field=uicontrol('Style','edit',...
        'Position',[.80 .775 .18 .15],...
        'Units','normalized','String',num2str(it),...
        'Callback','it=str2double(get(inp2_field,''String''));set(inp2_field,''String'',num2str(it));');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.9 0 ],...
        'Rotation',0 ,...
        'FontWeight','bold',...
        'FontSize',fontsz.m ,...
        'String','Please input time of cut in years (e.g. 86.5):');

    if in == 'rub' | in == 'lta'

        txt3 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.65 0 ],...
            'Rotation',0 ,...
            'FontWeight','bold',...
            'FontSize',fontsz.m ,...
            'String','Please input window length in years (e.g. 1.5):');
        inp3_field=uicontrol('Style','edit',...
            'Position',[.80 .575 .18 .15],...
            'Units','normalized','String',num2str(iwl2),...
            'Callback','iwl2=str2double(get(inp3_field,''String''),4); set(inp3_field,''String'',num2str(iwl2));');

    end   % if in = rub

    close_button=uicontrol('Style','Pushbutton',...
        'Position', [.60 .05 .15 .15 ],...
        'Units','normalized','Callback','welcome','String','Cancel');

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.25 .05 .15 .15 ],...
        'Units','normalized',...
        'Callback','welcome,think,watchon;drawnow,in2 = ''calma'';show_cro',...
        'String','Go');

    set(gcf,'visible','on');watchoff

    % do the calculations:
    %
else     % if in2 ~=calma

    % check if the times are with limits
    %
    if it > teb | it < t0b
        errordlg('Time out of limits')
        in2 = 'nocal';
        % show_cro
        %return
    end
    % initial parameter
    iwl = iwl2* 365/par1; ti = (it -t0b)*365/par1;
    [len, ncu] = size(cumuall); len = len-2;
    var1 = zeros(1,ncu);
    var2 = zeros(1,ncu);
    mean1 = zeros(1,ncu);
    mean2 = zeros(1,ncu);
    as = zeros(1,ncu);


    % loop over all grid points for percent
    %
    %
    if in =='per'

        for i = 1:ncu
            mean1(i) = mean(cumuall(1:ti,i));
            mean2(i) = mean(cumuall(ti:len,i));
        end    %for i

        as = -((mean1-mean2)./mean1)*100;

        strib = 'Change in Percent';
        stri2 = ['ti=' num2str(ti*par1/365 + t0b)  ];

    end  % if in = = per

    % loop over all point for rubber band
    %
    if in =='rub'

        for i = 1:ncu
            mean1(i) = mean(cumuall(1:ti,i));
            mean2(i) = mean(cumuall(ti+1:ti+iwl,i));
            var1(i) = cov(cumuall(1:ti,i));
            var2(i) = cov(cumuall(ti+1:ti+iwl,i));
        end %  for i ;
        as = (mean1 - mean2)./(sqrt(var1/ti+var2/iwl));

    end % if in = rub

    % make the AST function map
    if in =='ast'
        for i = 1:ncu
            mean1(i) = mean(cumuall(1:ti,i));
            var1(i) = cov(cumuall(1:ti,i));
            mean2(i) = mean(cumuall(ti+1:len,i));
            var2(i) = cov(cumuall(ti+1:len,i));
        end    %for i
        as = (mean1 - mean2)./(sqrt(var1/ti+var2/(len-ti)));
    end % if in = ast

    if in =='lta'
        disp('Calculate LTA')
        cu = [cumuall(1:ti-1,:) ; cumuall(ti+iwl+1:len,:)];
        mean1 = mean(cu(:,:));
        mean2 = mean(cumuall(ti:ti+iwl,:));
        for i = 1:ncu
            var1(i) = cov(cu(:,i));
            var2(i) = cov(cumuall(ti:ti+iwl,i));
        end     % for i
        as = (mean1 - mean2)./(sqrt(var1/(len-iwl)+var2/iwl));
    end % if in = lta


    if in == 'maz'

        maxlta = zeros(1,ncu);
        maxlta = maxlta -5;
        mean1 = mean(cumuall(1:len,:));
        wai = waitbar(0,'Please wait...')
        set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent done');

        for i = 1:ncu
            var1(i) = cov(cumuall(1:len,i));
        end     % for i
        for ti = 1:step: len - iwl
            waitbar(ti/len)
            mean1 = mean(cumuall(1:len,:));
            mean2 = mean(cumuall(ti:ti+iwl,:));
            for i = 1:ncu
                var1(i) = cov(cumuall(1:len,i));
                var2(i) = cov(cumuall(ti:ti+iwl,i));
            end     % for i
            as = (mean1 - mean2)./(sqrt(var1/len+var2/iwl));
            maxlta2 = [maxlta ;  as ];
            maxlta = max(maxlta2);
        end    % for it
        as = reshape(maxlta,length(gy),length(gx));
        close(wai)

    end   % if in = 'maz'

    % recreate rectengular matrix
    normlap2=NaN(length(tmpgri(:,1)),1);

    normlap2(ll)= as(:);
    %construct a matrix for the color plot
    re3=reshape(normlap2,length(yvect),length(xvect));

    [n1, n2] = size(cumuall);
    s = cumuall(n1,:);
    normlap2(ll)= s(:);
    %construct a matrix for the color plot
    r=reshape(normlap2,length(yvect),length(xvect));
    tresh = max(max(r));

    % find max and min of data for automatic scaling
    %
    maxc = max(max(re3));
    maxc = fix(maxc)+1;
    minc = min(min(re3));
    minc = fix(minc)-1;
    %plot imge
    %
    det = 'nop';
    old = re3;
    %if do == 'anom'
    %findano2
    %else
    %end
    vi_cucro

end   % if calma ~| in2

