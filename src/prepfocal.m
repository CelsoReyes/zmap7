% prepfocal
% to prepare the events for inversion based
% on Lu Zhongs code.

report_this_filefun(mfilename('fullpath'));

think
tmp = [a(:,10:12)];
do = ['save ' hodo 'data.inp tmp -ascii'];
err =  ['Error - could not save file ' hodo 'data.inp - permission?'];
err2 = ['errordlg(err);return'];
eval(do,err2)

infi = [hodo 'tmp.inp'];
outfi = [hodo 'tmp.out'];


fid = fopen([hodo 'inmifi.dat'],'w');

fprintf(fid,'%s\n',infi);
fprintf(fid,'%s\n',outfi);

fclose(fid);
comm = ['delete ' outfi];
eval(comm)

comm = ['!  ' hodi fs 'external' fs 'datasetupDD < ' hodo 'inmifi.dat ' ]
eval(comm)
fid = ([hodo 'tmpout.dat']);

format = ['%f%f%f%f%f'];
[d1 d2 d3 d4,  d5] = textread(fid,format,'headerlines',1);
