%  doinvers
% This file calculates orintation of the stress tensor
% based on Gephard's algorithm.
% stress tensor orientation. The actual calculation is done
% using a call to a fortran program.
%
% Stefan Wiemer 03/96


global mi mif1 mif2 term  hndl3 a newcat2 fontsz mi2
global tmp cumu2
report_this_filefun(mfilename('fullpath'));
think

% select the gridpoints


% do the loop

i2 = 0;
clear howmany
for i= 1:length(newgri(:,1))
    x = newgri(i,1);y = newgri(i,2);
    allcount = allcount + 1.;
    i2 = i2+1;

    % calculate distance from center point and sort wrt distance
    l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
    [s,is] = sort(l);
    b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
    b = b(1:ni,:);

    tmp = [b(:,10:14)];
    comm = ['!mkdir /home/david/tmp/in' num2str(i2)]
    eval(comm)
    comm = ['save /home/david/tmp/in' num2str(i2) '/data.inp tmp -ascii']
    eval(comm)
    comm = ['save /home/david/tmp/in' num2str(i2) '/loc.inp  x y  -ascii']
    eval(comm)
end
save tmpinv.mat

com =['gps        '
    'ugle       '
    'dutton     '
    'kiska      '
    'moment     '
    %'nordic     '
    'kanaga     '
    'spurr      '
    'chaos      '
    'megathrust '
    %'pele       '
    %'geoid      '
    'model      '
    'marvin     '];


cd /home/stefan/ZMAP/invers
i = 1;


while i <  length(newgri(:,1))

    for k = 1:length(com(:,1))

        comm = ['!/bin/rm /home/stefan/ZMAP/invers/howmany.dat '];
        eval(comm)
        comm = ['!rsh ' com(k,:) ' ps -axuw | grep fmsiWindow | cut -c10-15 ',...
            ' > /home/stefan/ZMAP/invers/howmany.dat '];
        eval(comm)
        pause(3)
        comm =['load /home/stefan/ZMAP/invers/howmany.dat '];
        eval(comm,'disp('' no'')')

        if exist('howmany') ==0 ; howmany = 0; end
        if com(k,:) == 'moment     ' ; howmany(1:2) = [] ; end
        if length(howmany(:,1)) < 2
            comm = ['! rsh ' com(k,:) ' /home/stefan/ZMAP/invers/invshell ',...
                num2str(length(tmp(:,1))) ' ' num2str(i)  ' &']
            eval(comm)
            i = i+1
            clear howmany
            pause(3)
        end   % if  length
        clear howmany
    end   % for k

    % wait for 1 minutes
    pause(10)

end  % while i

