% prepfocal
% to prepare the events for inversion based
% on Lu Zhongs code.

report_this_filefun(mfilename('fullpath'));

think
tmp = [a(:,10:12)];
data_inp_file=fullfile(ZmapGlobal.Data.out_dir,'data.inp');
do = ['save ', data_inp_file,' tmp -ascii'];
err =  ['Error - could not save file ' data_inp_file ' - permission?'];
err2 = ['errordlg(err);return'];
eval(do,err2)

infi = fullfile(ZmapGlobal.Data.out_dir, 'tmp.inp');
outfi = fullfile(ZmapGlobal.Data.out_dir, 'tmp.out');


fid = fopen(fullfile(ZmapGlobal.Data.out_dir, 'inmifi.dat'),'w');

fprintf(fid,'%s\n',infi);
fprintf(fid,'%s\n',outfi);

fclose(fid);
comm = ['delete ' outfi];
eval(comm)

comm = ['!  ' fullfile(ZmapGlobal.Data.hodi,'external','datasetupDD'),' < ' ZmapGlobal.Data.out_dir 'inmifi.dat ' ]
eval(comm)
fid = fullfile(ZmapGlobal.Data.out_dir, 'tmpout.dat');

format = ['%f%f%f%f%f'];
[d1 d2 d3 d4,  d5] = textread(fid,format,'headerlines',1);
