%This program is called from timeplot.m and displays the values of p, c and k from Omori law, together with their errors.
%Last modification May: 2001. B. Enescu

global valeg valeg2 cua2a valm1 CO

%The parameter valeg is used for choosing some options in mypval2m.m.
%The parameter valeg2 decides if c is fixed or not.

%disp(['This is rand_pvcat']);
valeg = 2;
num = 0;
numv = [];
frf = [];
ratac = [];
dursir = [];
tavg = [];
sir2 = [];

%prompt = {'Minimum magnitude','Min. time after mainshock (in days)','Enter a negative value if you wish a fix c'};
%title = 'You can change the following parameters:';
%lines = 1;
valm1 = min(newt2.Magnitude);
valtm1 = 0;
valeg2 = 0;
%def = {num2str(valm1), num2str(valtm1) num2str(valeg2)};
%answer = inputdlg(prompt,title,lines,def);
%valm1=str2double(answer{1}); valtm1 = str2num(answer{2}); valeg2 = str2num(answer{3});

if (valeg2 < 0)
    prompt = {'c-value'};
    title = 'c-value:';
    lines = 1;
    CO = 0.01;
    def = {num2str(CO)};
    answer = inputdlg(prompt,title,lines,def);
    CO = str2double(answer{1});
end

paramc1 = (newt2.Magnitude >= valm1);
pcat = newt2(paramc1,:);

lt = pcat(:,6) >= valtm1;
bpcat = pcat(lt,:);

[timpa] = timabs(pcat);
[timpar] = timabs(maepi);
tmpar = timpar(1);
pcat = (timpa-tmpar)/1440;
paramc2 = (pcat >= valtm1);
pcat = pcat(paramc2,:);
tmin = min(pcat); tmax = max(pcat);
tint = [tmin tmax];
[pv, pstd, cv, cstd, kv, kstd, rja, rjb] = mypval2m(pcat);

%[mm1,llb, llsig1, lla] = bmemag(bpcat);
%rja = (log10(kv) - llb * maepi(:,6) - min(bpcat(:,6)));
%if ~(isnan(pv))
% disp([]);
% disp(['Parameters :']);
% disp(['p = ' num2str(pv)  ' +/- ' num2str(pstd)]);
% disp(['a = ' num2str(rja)  ' +/- ' num2str(pstd)]);
% disp(['b = ' num2str(rjb)  ' +/- ' num2str(pstd)]);
% if valeg2 >= 0
%    disp(['c = ' num2str(cv)  ' +/- ' num2str(cstd)]);
% else
%    disp(['c = ' num2str(cv)]);
% end
% disp(['k = ' num2str(kv)  ' +/- ' num2str(kstd)]);
% disp(['Number of Earthquakes = ' num2str(length(pcat))]);
%events_used = sum(newt2(paramc1,3) > maepi(:,3) + cv/365);
% disp(['Number of Earthquakes greater than c  = ' num2str(events_used)]);
% disp(['tmin = ' num2str(tmin)]);
% disp(['tmax = ' num2str(tmax)]);
% disp(['Mmin = ' num2str(valm1)]);
%else
% disp([]);
% disp(['Parameters :']);
% disp(['No result']);
% disp(['Number of Earthquakes = ' num2str(length(pcat))]);
% disp(['tmin = ' num2str(tmin)]);
% disp(['tmax = ' num2str(tmax)]);
% disp(['Mmin = ' num2str(valm1)]);
%end
%
%%if plot_fig ~= 0
%
%%Find if the figure already exist.
%[existFlag,figNumber]=figure_exists('p-value graph',1);
%newpmapWindowFlag=~existFlag;
%
%%Make figure
%if newpmapWindowFlag
%   pgraph = figure_w_normalized_uicontrolunits( ...
%      'Name','p-value graph',...
%      'NumberTitle','off', ...
%      'NextPlot','new', ...
%      'backingstore','on',...
%      'Visible','off', ...
%      'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
%%     'MenuBar','none', ...
%end
%
%%If a new graph is overlayed or not
%if ho(1:2) == 'ho'
%   axes(cua2a);
%   disp('Hold');
%   hold on
%else
% hold on
% figure_w_normalized_uicontrolunits(pgraph)
% hold on
% delete(gca)
% axis off
%end
%
%
%power = -12:0.5:12;
%lung = length(power);
%
%
%
%for i = 1:lung
%  sir2(i) = 2^(power(i));
%  if ((sir2(i) <= tmin) | (sir2(i) >= tmax))
%    sir2(i) = 0;
%  end
%end
%
%limit1 = (sir2 > 0);
%sir2 = sir2(:,limit1);
%
%sir2 = sir2';
%lung = length(sir2);
%lungpc = length(pcat);
%for j = 1:(lung-1)
%   dursir(j) = sir2(j+1) - sir2(j);
%   tavg(j) = (sir2(j+1)*sir2(j))^(0.5);
%end
%
%for j = 1:(lung-1)
% for i = 1:lungpc
%   if ((pcat(i) > sir2(j)) & (pcat(i) <= sir2(j+1)))
%     num = num+1;
%   end
%end
%numv = [numv; num];
%num = 0;
%end
%
%numv = numv';
%
%%limit2 = (numv > 0);
%%dursir = dursir(:,limit2);
%%tavg = tavg(:,limit2);
%%numv = numv(:,limit2);
%
%lung = length(dursir);
%for j = 1:lung
% ratac(j) = numv(j)/dursir(j);
%end
%
%for j = 1:lung
% frf(j) = kv / ((tavg(j) + cv)^pv);
%end
%
%for j = 1:2
%   frf2(j) = kv / ((tint(j) + cv)^pv);
%end
%
%frfr = [frf2(1) frf frf2(2)];
%tavgr = [tint(1) tavg tint(2)];
%
%if ho(1:2) == 'ho'
% loglog(tavg, ratac, '-k','LineStyle', 'none', 'Marker', '+','MarkerSize',9);
% hold on
% loglog(tavgr, frfr, '-k','LineWidth',2.0);
% %loglog(tint, frf2, '-r','LineStyle', 'none', 'Marker', '+');
%else
% loglog(tavg, ratac, '-k','LineStyle', 'none', 'Marker', 'o','MarkerSize',9);
% hold on
% loglog(tavgr, frfr, '-k','LineWidth',2.0);
% %loglog(tint, frf2, 'LineStyle', 'none', 'Marker', '+');
% xlabel('Time from Mainshock (days)','FontWeight','bold','FontSize',14);
% ylabel('No. of Earthquakes / Day','FontWeight','bold','FontSize',14);
%end
%
%set(gca,'visible','on','FontSize',12,'FontWeight','normal',...
%   'FontWeight','bold','LineWidth',1.0,'TickDir','out',...
%   'Box','on','Tag','cufi')
%
%
%cua2a = gca;
%yll = get(gca,'YLim');
%xll = get(gca,'XLim');
% text(2*xll(1),yll(1)*8,['p = ' num2str(pv)  ' +/- ' num2str(pstd)],'FontWeight','Bold','FontSize',12);
% if valeg2 >= 0
%    text(2*xll(1),yll(1)*4,['c = ' num2str(cv)  ' +/- ' num2str(cstd)],'FontWeight','Bold','FontSize',12);
% else
%    text(2*xll(1),yll(1)*4,['c = ' num2str(cv)],'FontWeight','Bold','FontSize',12);
% end
% text(2*xll(1),yll(1)*2,['k = ' num2str(kv)  ' +/- ' num2str(kstd)],'FontWeight','Bold','FontSize',12);
%
%%%%end % end of plot fig
