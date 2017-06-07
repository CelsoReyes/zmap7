% Calculates magnitude signatures, yet another version, this time
% Computes a synthetic signature, using corrections found by bvalfit
%
%                                  R. Zuniga IGF-UNAM/GI-UAF  7/94

report_this_filefun(mfilename('fullpath'));

uicontrol('Units','normal','Position',[.90 .10 .10 .10],'String','Wait... ')
xt_backg = t1p(1):par1/365:t2p(1);
xt_foreg = t3p(1):par1/365:t4p(1);
tbckg = length(t1p(1):par1/365:t2p(1));
tforg = length(t3p(1):par1/365:t4p(1));

pause(0.1)
minmag2 = min(newcat(:,6) + 0.1 );
minmag2 = minmag2*10 ;
minmag2 = round(minmag2);
minmag2 = minmag2/10 ;       %  round to 0.1
masi = zeros(size(minmag2:0.1:maxmag));
masi2 = masi;
masi_syn = masi;
masi_syn2 = masi;
%
%                     loop over all magnitude bands
%
wai = waitbar(0,'Please wait...');
set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent completed');
nmag = length(minmag2:0.1:maxmag);
ind = 0;
for i = minmag2:0.1:maxmag
    waitbar(ind/length(masi));
    ind = ind+1;
    % disp(i)
    % and below
    %
    l = backg(:,6) <= i;
    junk = backg(l,:);
    if ~isempty(junk)
        [cum_mag, xt_backg] = hist(junk(:,3),xt_backg);      %    background
        l = foreg(:,6) <= i;                                 %    foreground
        junk = foreg(l,:);
        if ~isempty(junk)
            [cum_mag2, xt_foreg] = hist(junk(:,3),xt_foreg);
            l =  backg_new(:,6) <= i;
            junk = backg_new(l,:);
            if ~isempty(junk)
                [cum_syn, xt_backg] = hist(junk(:,3),xt_backg);      % synthetic foreground

                l =  junk(:,6) < magis;    % find out events below cut off for rate factor
                if length(junk(l,:)) > 0
                    [cum_junk, xt_backg] = hist(junk(l,3),xt_backg);
                    cum_junk = cum_junk*fac;                           % apply rate factor
                    dif_cum = round(cum_junk-cum_syn);  %  find out overall diffs in time histogram
                    cum_syn = cum_syn+dif_cum;          %  apply dif corrections to synthetic
                end  % if junk4
                mean1 = mean(cum_mag(1:tbckg));
                mean2 = mean(cum_mag2(1:tforg));
                means = mean(cum_syn(1:tbckg));
                var1 = cov(cum_mag(1:tbckg));
                var2 = cov(cum_mag2(1:tforg));
                vars = cov(cum_syn(1:tbckg));
                if sqrt(var1/tbckg+var2/tforg) > 0
                    %  masi = [masi  (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg))];
                    masi(ind) = (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg));  end
                if sqrt(var1/tbckg+vars/tbckg) > 0
                    %  masi_syn = [masi_syn  (mean1 - means)/(sqrt(var1/tbckg+vars/tbckg))];
                    masi_syn(ind) = (mean1 - means)/(sqrt(var1/tbckg+vars/tbckg));  end
            end   % if junk1
        end   % if junk2
    end   % if junk3

    % and above
    %
    l = backg(:,6) >= i;
    junk = backg(l,:);
    if ~isempty(junk)
        [cum_mag, xtbackg] = hist(junk(:,3),xt_backg);       %    background
        l = foreg(:,6) >= i;                                 %    foreground
        junk = foreg(l,:);
        if ~isempty(junk)
            [cum_mag2, xt_foreg] = hist(junk(:,3),xt_foreg);
            l =  backg_new(:,6) >= i;
            junk = backg_new(l,:);
            if ~isempty(junk)
                [cum_syn, xt_backg] = hist(junk(:,3),xt_backg);         % synthetic  foreground
                if i <= magis
                    l =  junk(:,6) < magis;    % find out events below cut off for rate factor
                    if length(junk(l,:)) > 0;
                        [cum_junk, xt_backg] = hist(junk(l,3),xt_backg);
                        cum_junk = cum_junk*fac;                           % apply rate factor
                        dif_cum = round(cum_junk-cum_syn);  % find out overall diffs in time histogram
                        cum_syn = cum_syn+dif_cum;          %  apply dif correction to synthetic
                    end  %  if junk4
                end  % if i < magis

                mean1 = mean(cum_mag(1:tbckg));
                mean2 = mean(cum_mag2(1:tforg));
                means = mean(cum_syn(1:tbckg));
                if mean1 | mean2 > 0
                    var1 = cov(cum_mag(1:tbckg));
                    var2 = cov(cum_mag2(1:tforg));
                    vars = cov(cum_syn(1:tbckg));
                    %  masi2 = [masi2  (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg))];
                    masi2(ind) = (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg));
                    %  masi_syn2 = [masi_syn2  (mean1 - means)/(sqrt(var1/tbckg+vars/tbckg))];
                    masi_syn2(ind) = (mean1 - means)/(sqrt(var1/tbckg+vars/tbckg));
                end   % if mean1

            end   % if junk
        end   % if junk2
    end   % if junk3
    %mag(i) = i;
    cum_mag = []; cum_mag2 = [];  cum_syn = []; cum_junk = [];
end  %    for i
close(wai)
if length(masi) > length(masi2), masi2(length(masi)) = 0; end
if length(masi) > length(masi_syn), masi_syn(length(masi)) = 0; end
if length(masi_syn) > length(masi_syn2), masi_syn2(length(masi_syn)) = 0; end

% plot Magnitude Signature
%
figure_w_normalized_uicontrolunits(hisfg)
rect = [0.2, 0.05, 0.3, 0.25];
axes('position',rect)
min1 = min([masi masi2 masi_syn masi_syn2]);
max1 = max([masi masi2 masi_syn masi_syn2] );
axis([minmag2 maxmag min1 max1 ]);
ploma1 = plot(minmag2:0.1:maxmag,masi,'om');
hold on;
plomas1 = plot(minmag2:0.1:maxmag,masi_syn,'+g');
set(ploma1,'MarkerSize',8)
set(plomas1,'MarkerSize',8)
hold on
mag1 = gca;
set(mag1,'TickLength',[0 0])
nu = [0.5 0 ; 3.0 0 ];
plot(nu(:,1),nu(:,2),'-.g')
title('Magnitude ')
xlabel('and below')
ylabel('z-value')
axis([minmag2 maxmag min1 max1 ]);
rect = [0.5,  0.05 0.30, 0.25];
axes('position',rect)
axis([0.5 maxmag  min1 max1 ])
ploma2 = plot(minmag2:0.1:maxmag,masi2,'om');
hold on;
plomas2 = plot(minmag2:0.1:maxmag,masi_syn2,'+g');
set(ploma2,'MarkerSize',8)
set(plomas2,'MarkerSize',8)
hold on
axis([minmag2 maxmag min1 max1 ]);
%ploma3 = plot(mag(5:maxmag*10)/10,masi2(5:maxmag*10),'y')
%set(ploma3,'LineWidth',3)
axis([minmag2 maxmag min1 max1 ]);
h = gca;
set(h,'YTick',[-10 10])
xlabel('and above')
title('Signature ')
nu = [0.5 0 ; 3.0 0 ];
plot(nu(:,1),nu(:,2),'-.g')

uicontrol('Units','normal','Position',[.90 .10 .10 .10],'String','Done... ')
uicontrol('Units','normal','Position',[.90 .51 .10 .05],'String','Print ', 'Callback','print -Psparc')
uicontrol('Units','normal','Position',[.90 .71 .10 .05],'String','Save  ', 'Callback','save_ma')
uicontrol('Units','normal','Position',[.90 .01 .10 .05],'String','Back  ', 'Callback','close, ic = 0; dispma2')

%clear junk cum_junk cum_syn cum_mag  cum_mag2 masi masi2 masi_syn masi_syn2 %xt_backg xt_foreg
