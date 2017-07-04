% This subroutine creates a differential bvalue map
% for two time periods. The difference in
% both b and Mc can be displayed.
%   Stefan Wiemer 1/95
%   Rev. R.Z. 4/2001

global no1 bo1 inb1 inb2

report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
    ra = 5 ;


    t1 = t0b;
    t4 = teb;
    t2 = t0b + (teb-t0b)/2;
    t3 = t2+0.01;


    def = {num2str(t1),num2str(t2),num2str(t3),num2str(t4), '50'}
    tit ='differntial b-value map ';
    prompt={'T1 = ', 'T2= ', 'T3 = ', 'T4= ', 'Min # of events in each period?'};

    ni2 = inputdlg(prompt,tit,1,def);
    l = ni2{5};
    minnu = str2double(l);
    l = ni2{4};
    t4 = str2double(l);
    l = ni2{3};
    t3 = str2double(l);
    l = ni2{2};
    t2 = str2double(l);
    l = ni2{1};
    t1 = str2double(l);


    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 450 250]);
    axis off
    labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
    labelPos = [0.2 0.7  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');



    labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
    labelPos = [0.2 0.8  0.6  0.08];
    hndl1=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList,...
        'Callback','inb1 =get(hndl1,''Value''); ');


    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ra));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inb1 =get(hndl1,''Value'');inb2 =get(hndl2,''Value'');close,sel =''ca'', bvalmapt',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Automatically estimate magn. of completeness?   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.64 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Constant Radius in km:');
    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    try
        close(wai);
    catch ME
        error_handler(ME,@do_nothing);
    end
    selgp
    itotal = length(newgri(:,1));
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(a.Date)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(a,inb1,inb2);
    bo1 = bv; no1 = a.Count;
    magco1 = NaN; magco2 = NaN;

    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a.Longitude-x) *cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        l3 = l <= ra;
        b = a.subset(l3);

        if length(b(:,1)) >= 2*minnu;
            % call the b-value function
            lt =  b(:,3) >= t1 &  b(:,3) <t2 ;
            if  length(b(lt,1)) >= minnu;
                [bv magco1 stan av me mer me2,  pr1] =  bvalca3(b(lt,:),inb1,inb2);
                bo1 = bv; no1 = length(b(lt,1));
                P6b = 10^(av-bv*6.5)/(t2-t1); %%

            else
                [bv magco1 stan av0 me mer me2,  pr1] =  bvalca3(b(:,:),inb1,inb2);
                av2 = log10(length(b(lt,1))) + bv*magco1;
                P6b = 10^(av2-bv*5)/(t2-t1);
                bv = NaN; pr = 50;
            end
            lt = b(:,3) >= t3 &  b(:,3) < t4 ;
            if  length(b(lt,1)) >= minnu;
                [bv2 magco2 stan av me mer me2,  pr] =  bvalca3(b(lt,:),inb1,inb2);

                P6a = 10^(av-bv2*6.5)/(t4-t3);


            else
                [bv2 magco2 stan av0 me mer me2,  pr] =  bvalca3(b(:,:),inb1,inb2);
                av2 = log10(length(b(lt,1))) + bv2*magco2;
                P6a = 10^(av2-bv2*5)/(t4-t3);
                bv2 = NaN; pr = 50;
            end


            l2 = sort(l);
            b2 = b;
            if inb2 ==  1
                l = b(:,6) >= magco;
                % b2 = b(l,:);
            end
            % [av2 bv2 stan2 ] =  bmemag(b2);
            if pr >= 40
                bvg = [bvg ; bv magco1 x y length(b(:,1)) bv2 pr av P6a  magco1-magco2  bv-bv2  magco2 P6a/P6b bv2/bv*100-100];
            else
                bvg = [bvg ; NaN NaN x y NaN NaN NaN NaN NaN  NaN NaN NaN NaN NaN] ;
            end
        else
            bvg = [bvg ; NaN NaN x y NaN NaN NaN  NaN NaN NaN NaN NaN NaN NaN];
        end

        waitbar(allcount/itotal)
    end  % for newgr

    % save data
    %
    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' bvg gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    bm1=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    bm2=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    magco1=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,12);
    magco2=reshape(normlap2,length(yvect),length(xvect));

    dmag = magco1 - magco2;

    normlap2(ll)= bvg(:,7);
    pro=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,8);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,9)-bvg(:,7);
    stanm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,13);
    maxm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,11);
    db12=reshape(normlap2,length(yvect),length(xvect));


    normlap2(ll)= bvg(:,14);
    dbperc=reshape(normlap2,length(yvect),length(xvect));

    re3 = db12;
    old = re3;

    % View the b-value map
    view_bvtmap

end   % if sel = na

%RZ Load existing  diff b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'Diff b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        normlap2=ones(length(tmpgri(:,1)),1)*nan;
        normlap2(ll)= bvg(:,1);
        bm1=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,6);
        bm2=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,2);
        magco1=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,12);
        magco2=reshape(normlap2,length(yvect),length(xvect));

        dmag = magco1 - magco2;

        normlap2(ll)= bvg(:,7);
        pro=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,8);
        avm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,9);
        stanm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,10);
        maxm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,11);
        db12=reshape(normlap2,length(yvect),length(xvect));

        re3 = db12;
        old = re3;

        view_bvtmap
    else
        return
    end
end
