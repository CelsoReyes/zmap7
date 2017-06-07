report_this_filefun(mfilename('fullpath'));

be_a=newcat;									% get catalog in question
% be_a=a;

bet0=clock;										% start timing of calculation

ben=length(be_a);								% ben is number of eqs in data set

betimin=min(be_a(:,3));							% time of first eq
betimax=max(be_a(:,3));							% time of last eq
betidiff=(betimax-betimin);					% interval duration in years
inc=1/ceil(betidiff*365/30);					% sets increment to about 30 days, not integer
be_norm(:,1)=ceil((be_a(:,3)-betimin)/(betidiff*inc));	% be_norm consists of number of intervals eq's belong into
be_norm(1,1)=1;									% artificially put first value into first interval

for bei=1:(1/inc)									% count # eqs in each interval
    be_int(bei,1)= sum(be_norm(:,1)==bei);
end

clear bei be_a be_norm;

% be_int consists of # eq's in each interval
% 0-inc is interval 1, with upper included

% variables: be_int, inc, betimin, betimax, betidiff, ben, bet0

beZ(1:(1/inc+1), 1:(1/inc+1))=NaN;			% shall give matrix for plotting

for bei=1:(1/inc)
    beti=bei*inc;
    for bej=1:bei
        bedelta=bej*inc;
        bem=sum(be_int((bei-bej+1):bei,1));				% bem is number of events in time interval in question
        beZ(bej+1, bei+1)=(bem-ben*bedelta)/sqrt(ben*bedelta*(1-bedelta));
    end
end

clear bei bej beti bel bem be_int bedelta;

becalc=etime(clock, bet0)				% shows duration of calculation
clear becalc;

bet0=clock;									% starts timing of plotting

figure;
[beX,beY]=meshgrid(0:inc:1);
beX=beX*betidiff+betimin;
beY=beY*betidiff;
contour(beX, beY, beZ);
% bev=[-3.8 -3.8;0 0;3.8 3.8];
% [beC,beh]=contour(beX, beY, beZ, bev);
[beC,beh]=contourf(beX, beY, beZ);
% clabel(beC,beh);

axis equal;
axis([betimin betimax 0 betidiff ]);
xlabel('end time');
ylabel('duration [years]');
betitle1=['increment ',num2str(inc'),' (equals ',num2str(betidiff*inc*365),' days)'];
betitle2=['duration ',num2str(betidiff),' years; ',num2str(ben), ' eqs'];
title({betitle1 , betitle2});
clear betitle1 betitle2;
colorbar;
print -dpsc2 betafig.eps

clear result beX beY beC beh inc betimin betimax betidiff;
clear be_a ben;

befig=etime(clock, bet0)				% shows duration of plotting
clear befig bet0 bedisp;
