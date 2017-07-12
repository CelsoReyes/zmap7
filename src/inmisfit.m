%
% make dialog interface for misfit calculation
%
% S. Wiemer/Zhong Lu/Alex Allmann

%
report_this_filefun(mfilename('fullpath'));

%if isunix ~= 1
%  errordlg('Misfit laculation only implemented for UNIX version, sorry');
%  return
%end

newcat = a;
global ptime lapf

%if ~exist('/home/lu/stress/bin/fmsietab_matlab')
%errordlg('Please contact stefan@giseis.alaska.edu for executable code for misfit calculation !');
%return
%end

if size(a(1,:)) < 12
    errordlg('You need 12 columns of Input Data to calculate misfit!');
    return
end

sig = 1;
az = 180.;
plu = 35.;
R = 0.5;
phi = 16;


%initial values
figure
clf
set(gca,'visible','off')
set(gcf,'Units','pixel','NumberTitle','off','Name','Input Parameters for Misfit Calculation');

set(gcf,'pos',[ wex  wey welx+100 wely+50])

bev=find(ZG.newcat.Magnitude==max(ZG.newcat.Magnitude)); %biggest events in catalog


%default values of input parameters
ldx=100;
tlap=100;
latt=ZG.newcat(bev(1),2);
longt=ZG.newcat(bev(1),1);
binlength=1;
Mmin=3;
ldepth=ZG.newcat(bev(1),7);

% creates a dialog box to input some parameters
%
txt1 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.96 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Sigma 1 or 3? : ');


txt2 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.81 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Please input Plunge ');


txt3 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.66 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Please input Azimuth :');

txt4 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.51 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','R value:');
txt5 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.36 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Phi :');
%

inp1_field  = uicontrol('Style','edit',...
    'Position',[.85 .87 .13 .08],...
    'Units','normalized','String',num2str(sig),...
    'Callback','sig=str2double(inp1_field.String);inp1_field.String=num2str(sig);');



inp2_field  = uicontrol('Style','edit',...
    'Position',[.85 .75 .13 .08],...
    'Units','normalized','String',num2str(plu),...
    'Callback','plu=str2double(inp2_field.String);inp2_field.String=num2str(plu);');


inp3_field=uicontrol('Style','edit',...
    'Position',[.85 .63 .13 .08],...
    'Units','normalized','String',num2str(az),...
    'Callback','az=str2double(inp3_field.String);     inp3_field.String=num2str(az);');

inp4_field=uicontrol('Style','edit',...
    'Position',[.85 .51 .13 .08],...
    'Units','normalized','String',num2str(R),...
    'Callback','R=str2double(inp4_field.String); inp4_field.String=num2str(R);');


inp5_field=uicontrol('Style','edit',...
    'Position',[.85 .39 .13 .08],...
    'Units','normalized','String',num2str(phi),...
    'Callback','phi=str2double(inp5_field.String); inp5_field.String=num2str(phi);');
%
close_button=uicontrol('Style','Pushbutton',...
    'Position', [.72 .05 .15 .12 ],...
    'Units','normalized','Callback','close;welcome','String','Cancel');

inflap_button=uicontrol('Style','Pushbutton',...
    'Position', [.49 .05 .15 .12 ],...
    'Units','normalized','Callback','infoz(1)','String','Info');

compare_button=uicontrol('Style','Pushbutton',...
    'Position', [.27 .05 .15 .12 ],...
    'Units','normalized','Callback','compMisfit','String','CompMod');

go_button=uicontrol('Style','Pushbutton',...
    'Position',[.05 .05 .15 .12 ],...
    'Units','normalized',...
    'Callback','close;welcome;domisfit',...
    'String','Go');

set(gcf,'visible','on');watchoff

