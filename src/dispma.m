%
% calculates Magnitude Signatures, operates on catalogue newcat
%

report_this_filefun(mfilename('fullpath'));

figure
set(gcf,'Units','normalized','NumberTitle','off','Name','b-value curves');
set(gcf,'pos',[ 0.2  0.8 0.5 0.8])
if isempty(newcat), newcat = a ; end ;
maxmag = max(newcat.Magnitude);
t0b = min(newcat.Date);
teb = max(newcat.Date);
n = newcat.Count;
tdiff = round(teb - t0b);


% number of mag units
nmagu = (maxmag*10)+1;

bval = zeros(1,nmagu);
bval2 = zeros(1,nmagu);
bvalsum = zeros(1,nmagu);
bvalsum2 = zeros(1,nmagu);
bvalsum3 = zeros(1,nmagu);
bvalsum4 = zeros(1,nmagu);

l = newcat.Date > t1p(1) & newcat.Date < t2p(1) ;
bval =  newcat.subset(l);
[bval,xt2] = hist(bval(:,6),(0:0.1:maxmag));
bvalsum = cumsum(bval);
bvalsum3 = cumsum(bval(length(bval):-1:1));
xt3 = (maxmag:-0.1:0);


l = newcat.Date > t2p(1) & newcat.Date < t3p(1) ;
bval2 = newcat.subset(l);
bval2 = histogram(bval2(:,6),(0:0.1:maxmag));
bvalsum2 = cumsum(bval2);
bvalsum4 = cumsum(bval2(length(bval2):-1:1));


% normalisation
td12 = t2p(1) - t1p(1);
td23 = t3p(1) - t2p(1);
bvalsum = bvalsum *  td23/td12;
bvalsum3 = bvalsum3 *  td23/td12;
bval = bval *  td23/td12;


orient tall
rect = [0.2,  0.7, 0.60, 0.25];
axes('position',rect)
semilogy(xt2,bvalsum,'om')
hold on
semilogy(xt2,bvalsum2,'xb')
semilogy(xt2,bvalsum,'-.m')
semilogy(xt2,bvalsum2,'b')
semilogy(xt3,bvalsum4,'xb')
semilogy(xt3,bvalsum4,'b')
semilogy(xt3,bvalsum3,'-.m')
semilogy(xt3,bvalsum3,'om')
te1 = max([bvalsum  bvalsum2 bvalsum4 bvalsum3]);
te1 = te1 - 0.2*te1;
title(['o: ' num2str(t1p(1)) ' - ' num2str(t2p(1)) '     x: ' num2str(t2p(1)) ' - '  num2str(t3p(1)) ])

xlabel('Magnitude ')
ylabel('Cumulative Number -normalized')

rect = [0.2,  0.38 0.60, 0.25];
axes('position',rect)
plot(xt2,bval,'om')
hold on
plot(xt2,bval2,'xb')
plot(xt2,bval,'-.m')
plot(xt2,bval2,'b')

xlabel('Magnitude ')
ylabel('Number')

pause(0.1)

tm1 = round((t1p(1) - t0b)*365/par1);
tm2 = round((t3p(1) - t0b)*365/par1);
tmid = round((t2p(1) - t1p(1))*365/par1)


% masi2 =  1:1:maxmag*10;
% masi2 = masi2 * 0;
% masi =  1:1:maxmag*10;
% masi = masi2 * 0;
% cumunew = tm1:1:tm2+2;
% cumunew = cumunew * 0;
% cumunew2 = tm1:1:tm2+2;
% cumunew2 = cumunew * 0;
% n2 = length(cumunew) - tmid;

uicontrol('Units','normal','Position',[.90 .61 .10 .05],'String',' MagSig ', 'Callback','calcmags')
uicontrol(,'Units','normal','Position',[.90 .51 .10 .05],'String','Print  ', 'Callback','print')
