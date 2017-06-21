%  domisfit
% This file calculates the misfit for each EQ to a given
% stress tensor orientation. The actual calculation is done
% using a call to a fortran program.
%
% Stefan Wiemer 07/95


global mi mif1 mif2 term  hndl3 a newcat2 fontsz mi2
global tmp cumu2
report_this_filefun(mfilename('fullpath'));
think

hodis = fullfile(hodi, 'external');
do = ['cd  ' hodis ]; eval(do)

% prepare the focal; mechnism in Gephard format ...
tmp = [a(:,10:12) ];
l = tmp(:,2) >89.999;
tmp(l,2) = tmp(l,2)*0+89.;

try
    save data.inp tmp -ascii
catch ME
    error_handler(ME, ['Error - could not save file ' hodo 'data.inp - permission?']);
end

infi =  ['data.inp'];
outfi = ['tmpin.dat'];
fid = fopen('inmifi.dat','w');
fprintf(fid,'%s\n',infi);
fprintf(fid,'%s\n',outfi);
fclose(fid);
comm = ['delete ' outfi];
eval(comm)

comm = ['!datasetupDD < inmifi.dat ' ]
eval(comm)

fid = (['tmpin.dat']);
format = ['%f%f%f%f%f'];
[d1 d2 d3 d4,  d5] = textread(fid,format,'headerlines',1);

dall = [d1 d2 d3 d4 d5];
save tmpin.dat dall -ascii



infi = ['tmpin.dat'];
outfi = ['tmpout.dat'];

fid = fopen(['inmifi.dat'],'w');

fprintf(fid,'%s\n',infi);
fprintf(fid,'%s\n',outfi);
fprintf(fid,'%2.0f\n',sig);
fprintf(fid,'%6.2f\n',plu);
fprintf(fid,'%6.2f\n',az);
fprintf(fid,'%6.2f\n',phi);
fprintf(fid,'%3.2f\n',R);
le = a.Count;
fprintf(fid,'%6i\n',le);

fclose(fid);
comm = ['delete ' outfi];
eval(comm)

comm = ['! testfm < inmifi.dat ' ]
eval(comm)

comm = ['load tmpout.dat'];
eval(comm)
mi = tmpout;

[existFlag,figNumber]=figure_exists('Misfit Map',1);


newmif1WindowFlag=~existFlag;


if newmif1WindowFlag
    mif1 = figure_w_normalized_uicontrolunits( ...
        'Name','Misfit Map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-500 winx winy]);

    
    matdraw

    %
    omp2= uimenu('Label','Tools');
    uimenu(omp2,'label','Misfit-Magnitude',...
         'Callback','mi_ma;');
    uimenu(omp2,'label','Misfit-Depth',...
         'Callback','mi_dep;');
    uimenu(omp2,'label','Earthquake-Depth',...
         'Callback','eq_dep;');
    uimenu(omp2,'label','Earthquake-Strike',...
         'Callback','eq_str;');
    %

    labelList=['Size | Size + Thickness | Size +Thickness +color  '];
    labelPos = [0.2 0.93 0.35 0.05];
    hndl2=uicontrol(...
        'Style','popup',...
        'Units','normalized',...
        'Position',labelPos,...
        'String',labelList,...
        'BackgroundColor',[0.7 0.7 0.7]',...
        'Callback','in2 =get(hndl2,''Value''); plotmima(in2)');

    labelList=['1 | 1/2 | 1/3 | 1/4 | 1/5 | 1/6| 1/7| 1/8 | 1/9 | 1/10'];
    labelPos = [0.9 0.93 0.10 0.05];
    hndl3=uicontrol(...
        'Style','popup',...
        'Units','normalized',...
        'Position',labelPos,...
        'Value',4,...
        'String',labelList,...
        'BackgroundColor',[0.7 0.7 0.7]',...
        'Callback','in3 =get(hndl3,''Value'');in2 =get(hndl2,''Value''); plotmima(in2) ');

    uicontrol(...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.9 0.6 0.08 0.08],...
        'String','X-sec',...
        'Callback','var1 = 3;plotmimac');
    hold on
    %end killed
    uicontrol(...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.9 0.7 0.08 0.08],...
        'String','Map',...
        'Callback','var1 = 1;mifigrid');
    hold on
end

figure_w_normalized_uicontrolunits(mif1)

plotmima(4)

[existFlag,figNumber]=figure_exists('Misfit ',1);
newmif2WindowFlag=~existFlag;


if newmif2WindowFlag
    mif2 = figure_w_normalized_uicontrolunits( ...
        'Name','Misfit ',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ fipo(3)-300 fipo(4)-500 winx winy]);

    
    omp1= uimenu('Label','Tools');
    uimenu(omp1,'label','Save sorted catalog',...
         'Callback','save_sortpere;');
    uimenu(omp1,'label','AS Function',...
         'Callback','ast_misfit;');
    uimenu(omp1,'label','Compare',...
         'Callback','compare_misfit;');
    labelList=['Longitude | Latitude | Time | Magnitude | Depth | Strike | Default'];
    labelPos = [0.7 0.9 0.25 0.08];
    hndl1=uicontrol(...
        'Style','popup',...
        'Units','normalized',...
        'Position',labelPos,...
        'String',labelList,...
        'BackgroundColor',[0.7 0.7 0.7]',...
        'Callback','in2 =get(hndl1,''Value''); plotmi(in2)');
    hold on
end

figure_w_normalized_uicontrolunits(mif2)

delete(gca);delete(gca);
delete(gca);delete(gca);

plotmi(1)

done
