%  doinvers
% This file calculates orintation of the stress tensor
% based on Gephard's algorithm.
% stress tensor orientation. The actual calculation is done
% using a call to a fortran program.
%
% Stefan Wiemer 03/96


global mi mif1 mif2  hndl3 a newcat2 mi2
global tmpi cumu2
report_this_filefun(mfilename('fullpath'));
think

if isunix ~= 1
    errordlg('Misfit calculation only implemented for UNIX version! ');
    return
end

prepfocal2
hodis = [hodi '/stinvers'];
tmpi = tmpout2;
do = ['save ' ZmapGlobal.Data.out_dir 'data.inp tmpi -ascii'];
err =  ['Error - could not save file ' ZmapGlobal.Data.out_dir '/tmpin.dat - permission?'];
err2 = ['errordlg(err);return'];
eval(do,err2)

infi = [ZmapGlobal.Data.out_dir 'data.inp'];
outfi = [ZmapGlobal.Data.out_dir 'tmpout.dat'];


%com1 =input('Which computer would you like to do the inversion on?','s');

%comm = ['! rsh ' com1 ' '  hodis '/invshell1 ',...
%        num2str(length(tmpi(:,1))) ' ' num2str(i) ' ' hodis ' ' infi  ' &']
comm = [ '! '   hodis '/invshell1 ',...
    num2str(length(tmpi(:,1))) ' ' num2str(10) ' ' hodis ' ' infi  ' & ']
eval(comm)
%plot95
%helpdlg('Inversion submitted, type plot95 to plot the results when job completed ');
