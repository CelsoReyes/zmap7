
%function clusmenu
%clusmenu.m                            A.Allmann
report_this_filefun(mfilename('fullpath'));
%interface for clustermenu
%allows further examination of clusters
%histograms,select options,special cluster examination
%
% Last modification 11/95

global dplo1_h dplo2_h dplo3_h dep1 dep2 dep3 histo hisvar strii1 strii2
global plot1_h  plot2_h     %object handle for subplots
global mess check1 cum freq_field bgevent equi cluscat par1
global file1 clu h5 bg h1 ms6 ty
global clust original cluslength         %bsubclus
global backcat backequi backbgevent swarmtmp eqtime       %subclus
global maintmp dubletttmp
global ttcat tt1cat foresh aftersh mainsh                  %sinclus
global equi_button newclcat iwl3 par5 newt2
global button1 button2 button3 st1 go_button
global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5
global sys minmag welx wely wex wey
global inp1 inp2 inp3 inp4 inp5 inp6 inp7 inp8 inp9 inp10
global tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 tmp8 tmp9 tmp10 clsel xt pyy ccum
global fore_button after_button clop1 clop2 clop3 clop4 clop5
global clu1 fore_h after_h main_h bfig new  freq_slider mouse_button
global close_ti_button pplot cinfo p1 Info_p cplot coastline
global mainfault main faults clus_button maepi clclose_button
global SizMenu TypMenu calll66 hndl1 tmvar map mapp decc
global tmm ctiplo hpndl1 callcheck magn mtpl    %cltipval

newclcat=[];
if isempty(winx)
    winx=600;
    winy=500;
end
%set(map,'visible','off')
plot1_h=[];plot2_h=[];
%load cluster data file
[file1,path1] = uigetfile([hodi fs 'eq_data2'  fs '*.mat'],'Cluster Datafile');

file2=file1;
if size(file1)~=0
    load([path1 file1])
end
file1=file2;
if length(equi(1,:))==9         %counter to have a specific number for every
    tmp=1:length(bg);                 %cluster
    equi=[equi,tmp'];
    clear tmp;
end
newcat=original;
newclcat=[];        %variable for selection options
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Cluster Menu',1);
newClusterFlag=~existFlag;
if newClusterFlag
    clu=figure_w_normalized_uicontrolunits(...
        'NumberTitle','off','Name','Cluster Menu',...
        'MenuBar','none', ...
        'visible','off',...
        'Position',[100 200 winx+100 winy]);
    set(gca,'visible','off');
    clear options op2 op3

    par1 = (newcat(newcat.Count,3)-newcat(1,3))/100*365;
    if par1 < 1
        par1 = 0.1;
    else
        par1 = round(par1);
    end

    %Menuline for options
    %

    %Workspace
    matdraw
    callbackStr= ...
        ['set(clu,''visible'',''off'');set(map,''visible'',''on'');if ~isempty(backequi),equi=backequi;end;if ~isempty(backbgevent),bgevent=backbgevent;end;'];

    % Make the menu to change symbol size and type
    %
    symbolmenu = uimenu('Label',' Symbol ');
    SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
    TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
    uimenu(SizeMenu,'Label','3','Callback','ms6 =3;eval(cal66)');
    uimenu(SizeMenu,'Label','6','Callback','ms6 =6;eval(cal66)');
    uimenu(SizeMenu,'Label','9','Callback','ms6 =9;eval(cal66)');
    uimenu(SizeMenu,'Label','12','Callback','ms6 =12;eval(cal66)');
    uimenu(SizeMenu,'Label','14','Callback','ms6 =14;eval(cal66)');
    uimenu(SizeMenu,'Label','18','Callback','ms6 =18;eval(cal66)');
    uimenu(SizeMenu,'Label','24','Callback','ms6 =24;eval(cal66)');

    uimenu(TypeMenu,'Label','dot','Callback','ty =''.'';eval(cal66)');
    uimenu(TypeMenu,'Label','+','Callback','ty=''+'';eval(cal66)');
    uimenu(TypeMenu,'Label','o','Callback','ty=''o'';eval(cal66)');
    uimenu(TypeMenu,'Label','x','Callback','ty=''x'';eval(cal66)');
    uimenu(TypeMenu,'Label','*','Callback','ty=''*'';eval(cal66)');

    cal66 = ...
        [ 'set(dplo1_h,''MarkerSize'',ms6,''LineStyle'',ty);',...
        'set(dplo2_h,''MarkerSize'',ms6,''LineStyle'',ty);',...
        'set(dplo3_h,''MarkerSize'',ms6,''LineStyle'',ty);' ];


    %select different areas
    op1    = uimenu('Label','Select','BackgroundColor','m');

    uimenu(op1,'Label',' Select EQ in Polygon -Menu ',...
        'Callback','decc=2;clkeysel',...
        'BackgroundColor',[0.2 0.8 0.8]);
    uimenu(op1,'Label',' Select EQ in Polygon ',...
        'Callback','decc=2;clpickp(4);',...
        'BackgroundColor',[0.2 0.8 0.8],...
        'Accelerator','N');
    uimenu(op1,'Label','Select EQ in Circle (Menu) ',...
        'Callback','set(gcf,''Pointer'',''watch''); stri = ['' %''];stri1 = ['' ''];clcircle(1);',...
        'BackgroundColor',[0.7 0.6 0.8]);


    %calculate several histogramms
    stt1='Magnitude ';stt2='Depth ';stt3='Duration ';st4='Foreshock Duration ';
    st5='Foreshock Percent ';st6='Number of Eqs ';

    op2 = uimenu('Label','Hist','BackgroundColor','m');

    uimenu(op2,'Label','Biggest Event Magnitude',...
        'Callback','hisgra(bgevent(:,6),stt1);');
    uimenu(op2,'Label','Equivalent Event Magnitude',...
        'Callback','hisgra(equi(:,6),stt1);');
    uimenu(op2,'Label','Duration',...
        'Callback','hisgra(dura(equi(:,10)),stt3);');
    uimenu(op2,'Label','Foreshock Duration',...
        'Callback','hisgra(foretime(equi(:,10)),st4);');
    uimenu(op2,'Label','Foreshock Percentage',...
        'Callback','hisgra(forepercent(equi(:,10))*100,st5);');
    uimenu(op2,'label','Number of Eqs',...
         'Callback','hisgra(cluslength(equi(:,10)),st6);');
    uimenu(op2,'Label','Magnitude',...
        'Callback','if ~isempty(newclcat),if ~isempty(backcat),if length(newclcat(:,1))>length(cluscat(:,1)),hisgra(cluscat(:,6),stt1);else,hisgra(newclcat(:,6),stt1);end;else,hisgra(newclcat(:,6),stt1);end;else,hisgra(cluscat(:,6),stt1);end;');
    uimenu(op2,'Label','Depth',...
        'Callback','if ~isempty(newclcat),if ~isempty(backcat),if length(newclcat(:,1))>length(cluscat(:,1)),hisgra(cluscat(:,7),stt2);else,hisgra(newclcat(:,7),stt2);end;else,hisgra(newclcat(:,7),stt2);end;else,hisgra(cluscat(:,7),stt2);end;');


    %some tools
    %
    op3 = uimenu('Label','Tools','BackgroundColor','m');

    uimenu(op3,'Label','Plot Cumulative Number',...
        'Callback','cltiplot(1);');
    opp3=uimenu(op3,'label','B-Value Plot');
    uimenu(opp3,'Label','manual',...
        'Callback','clbvalpl(1);');
    uimenu(opp3,'Label','automatic',...
        'Callback','clbdiff(1);');
    uimenu(opp3,'Label','with magnitude',...
        'Callback','global bcat nh dx dy ni;if ~isempty(newclcat),if ~isempty(backcat),if length(newclcat(:,1))>length(cluscat(:,1)),bvalmag(cluscat,1);else,bvalmag(newclcat,1);end;else,bvalmag(newclcat,1);end;else,bvalmag(cluscat,1);end;');
    %special cluster
    op4 = uimenu('Label','Special','BackgroundColor','m');

    op5 = uimenu(op4,'Label','Main');
    op6 =uimenu(op4,'Label','Single');

    uimenu(op5,'Label','Complete',...
        'Callback','subclus(1);');
    uimenu(op5,'Label','Foreshocks',...
        'Callback','subclus(2)');
    uimenu(op5,'Label','Aftershocks',...
        'Callback','subclus(3)');
    uimenu(op4,'Label','Swarms',...
        'Callback','subclus(4)');
    uimenu(op4,'Label','Dubletts',...
        'Callback','subclus(5)');
    uimenu(op6,'Label','Select by Mouse',...
        'Callback','sinclus(1);');
    uimenu(op6,'Label','Position Input',...
        'Callback','sinclus(2);');
    uimenu(op6,'Label','Input Clusternumber',...
        'Callback','sinclus(3);');

    %Display
    %
    op7=uimenu('Label','Display','BackgroundColor','m');
    uimenu(op7,'Label','Refresh Window','Callback','figure_w_normalized_uicontrolunits(clu);set(equi_button,''value'',0);set(bg_button,''value'',0);plot1_h=[];plot2_h=[];cluoverl(7);');
    uimenu(op7,'Label','Back', 'Callback','figure_w_normalized_uicontrolunits(clu);if isempty(newclcat),if ~isempty(backcat),cluscat=backcat;equi=backequi;bgevent=backbgevent;end;backcat=[];cluoverl(7);else newclcat=[];equi=backequi;bgevent=backbgevent;if ~isempty(backcat),cluscat=backcat;end;cluoverl(7);set(equi_button,''value'',0);plot2_h=[];plot1_h=[];backcat=[];end;');
    uimenu(op7,'Label','Show Map Window','Callback','set(mapp,''visible'',''on'')');
    uimenu(op7,'Label','Hide Map Window','Callback','set(mapp,''visible'',''off'')');

    %Cuts
    %
    op8=uimenu('Label','Cuts','BackgroundColor','m');
    uimenu(op8,'Label','Time Cut',...
        'Callback','cluticut(1);');
    uimenu(op8,'Label','Magnitude Cut',...
        'Callback','clmagcut(1);');
    uimenu(op8,'Label','Depth Cut',...
        'Callback','cldepcut(1);');
    uimenu(op8,'Label','Number Cut',...
        'Callback','bigclu(1);');



    st1=['if get(bg_button,''Value'')==0,cluoverl(1);else cluoverl(2);end']; % st1 is global(?!?)
    bg_button = uicontrol('Units','normal',...
        'Position',[.9 .93 .08 .06],'String','Big',...
        'Style','check','Callback','if get(bg_button,''Value'')==0,cluoverl(1);else cluoverl(2);end');
    equi_button=uicontrol('Units','normal',...
        'Position',[.8 .93 .08 .06],'String','Equi',...
        'Style','check','Callback','if get(equi_button,''Value'')==1,cluoverl(3);else,cluoverl(4);end');
    clus_button=uicontrol('Units','normal',...
        'Position',[.7 .93 .08 .06],'String','Clus',...
        'Style','check','Callback','if get(clus_button,''Value'')==0,cluoverl(5);else,cluoverl(6);end');
    pri_button = uicontrol('Style','Pushbutton',...
        'Position',[.01 .05 .1 .06],...
        'Units','normalized','Callback', 'myprint',...
        'String','Print');
    uicontrol('Units','normal',...
        'Position',[.00 .93 .10 .06],'String','Info',...
        'Style','Pushbutton','Callback','clinfo(6);');

    uicontrol('Units','normal',...
        'Position',[.00 .83 .10 .06],'String','Close',...
        'Style','Pushbutton','Callback','close(clu);zmap_message_center.set_info('' '','' '');');

else
    figure_w_normalized_uicontrolunits(clu)
    reset(gca)
    plot1_h=[];
    plot2_h=[];
end             %if figure not already existing
watchon
set(clu,'Visible','off');
cluoverl(7);
csubcat;
set(clu,'Visible','on');
figure_w_normalized_uicontrolunits(clu);
whitebg;
watchoff(clu);
watchoff(mess);
