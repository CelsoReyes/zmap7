%  doinvers
% This file calculates orintation of the stress tensor
% based on Gephard's algorithm.
% stress tensor orientation. The actual calculation is done
% using a call to a fortran program.
%
% Stefan Wiemer 03/96


global mi mif1 mif2  hndl3 a newcat2 mi2
global tmp cumu2
report_this_filefun(mfilename('fullpath'));
think

tmp = [newt2(:,10:14)];
save /home/stefan/ZMAP/invers/data.inp tmp -ascii
infi = ['/home/stefan/ZMAP//invers/data.inp'];
outfi = ['/home/stefan/ZMAP/tmpout.dat'];

cd /home/stefan/ZMAP/invers
com1 =input('Which computer?','s');
tic
comm = ['! rsh ' com1 ' /home/stefan/ZMAP/invers/invshell1 ',...
    num2str(length(tmp(:,1))) ' ' num2str(i)  ' &']
eval(comm)

t = toc/60
