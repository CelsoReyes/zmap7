% This is runasp - the ZMAP to aspar interface

report_this_filefun(mfilename('fullpath'));

if isunix ~= 1
    errordlg('ASPAR only implemented  for UNIX version! ');
    return
end

save_aspar;

def = {num2str(min(newt2.Magnitude)-0.1) };
ni2 = inputdlg('Minimum Magnitude used? ','Input',1,def);
l = ni2{:};
mi = str2double(l);

! echo 't1.sum' >! inpu
! echo '1' >> inpu
do = [ '! echo ' num2str(mi) ' >> inpu '];
eval(do)
! echo '5' >> inpu
do = [ ' ! '  hodi '/aspar/aspar3x < inpu' ]
eval(do)

