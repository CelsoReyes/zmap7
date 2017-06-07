% prepfocal
% to prepare the events for inversion based
% on Lu Zhongs code.

report_this_filefun(mfilename('fullpath'));

think
tmp = [newt2(:,10:12)];
do = ['save ' hodo 'data.inp tmp -ascii'];
err =  ['Error - could not save file ' hodo 'data.inp - permission?'];
err2 = ['errordlg(err);return'];
eval(do,err2)

infi = [hodo 'data.inp'];
outfi = [hodo 'tmpout.dat'];
outfi2 = [hodo 'tmpout2.dat'];


fid = fopen([hodo 'inmifi.dat'],'w');

fprintf(fid,'%s\n',infi);
fprintf(fid,'%s\n',outfi);

fclose(fid);
comm = ['!/bin/rm ' outfi];
eval(comm)

comm = ['!  ' hodi '/stinvers/datasetupDD < ' hodo 'inmifi.dat ' ]
eval(comm)

comm = ['!grep  "1.0" ' outfi  '>'  outfi2];
eval(comm)

comm = ['load ' hodo 'tmpout2.dat'];
eval(comm)

%l = newt2(:,length(newt2(1,:)));
%a(:,10:13) = [];
%a = [a  tmpout2  l tmp];

done
