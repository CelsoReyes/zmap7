% betatriangle.m
% produces triangle plot of beta values in the way Matthews & Reasenberg 1988 have done it
%
% db, 05/25/01, denise@etha.net

report_this_filefun(mfilename('fullpath'));

Catalog=[];
Catalog=newcat;
NumberBins = length(xt);
BetaValues = zeros(NumberBins+1,NumberBins+1)*NaN;
TimeBegin = Catalog(1,3);
NumberEQs = length(Catalog(:,1));
TimeEnd = max(Catalog(:,3));
be_norm = [];
watchon;
% time normalisation
%
%betimin=min(be_a(:,3));							% time of first eq
%betimax=max(be_a(:,3));							% time of last eq
%betidiff=(betimax-betimin);					    % duration of catalogue
%inc=1/ceil(betidiff*365/30);					    % sets increment to about 30 days, 1/inc is integer
% inc is now 1/NumberBins
be_norm = ceil((Catalog(:,3)-TimeBegin)/((TimeEnd-TimeBegin)/NumberBins));	% be_norm consists of number of intervals eq's belong into
be_norm(1,1)=1;									% artificially put first value into first interval

for bei=1:NumberBins								% count # eqs in each interval
    be_int(bei,1)= sum(be_norm(:,1)==bei);
end


% calculation of betas
%
beZ(1:(NumberBins+1), 1:(NumberBins+1))=NaN;	    % shall give matrix for plotting, requires one additional column and line

for bei=1:NumberBins						    % over end times

    for bej=1:bei								% over durations
        bedelta=bej/NumberBins;					% length of time interval, normalized
        bem=sum(be_int((bei-bej+1):bei,1));	    % number of events in time interval in question
        beZ(bej, bei)=(bem-NumberEQs*bedelta)/sqrt(NumberEQs*bedelta*(1-bedelta)); % beZ consists of beta-values
    end % bej

end % bei

clear bei bej bel bem be_int bedelta;

%
% plotting of results
%
watchoff
figure_w_normalized_uicontrolunits('Name', 'Triangle Plot of beta-values',...
    'NumberTitle', 'off');
[beX,beY]=meshgrid(0:(1/NumberBins):1);
beX=beX*(TimeEnd-TimeBegin)+TimeBegin;
beY=beY*(TimeEnd-TimeBegin);
contour(beX, beY, beZ, [-4 -4], 'r:');
hold on;
contour(beX, beY, beZ, [-2 -2], 'r');
hold on;
contour(beX, beY, beZ, [0 0], 'k');
hold on;
contour(beX, beY, beZ, [2 2], 'b');
hold on;
contour(beX, beY, beZ, [4 4], 'b:');

axis equal;
axis([TimeBegin TimeEnd 0 TimeEnd-TimeBegin ]);
xlabel('end time', 'FontSize', 12);
ylabel('duration [years]', 'FontSize', 12);
set(gca, 'YTickLabel', get(gca, 'YTickLabel'), 'FontSize', 12);
title('Contour Plot of \beta-Values (Matthews&Reasenberg, 1988)', 'FontSize', 12);

xc=min(beX(1,:));
yc=0.95*(max(max(beY)));
explanation=['  Calculations done with a bin length of ', num2str(par1), ' days'];
text(xc, yc, {explanation}, 'FontSize', 10);
yc=0.85*(max(max(beY)));
text(xc, yc, '  -4 dotted, -2 solid (i.e. lower seismicity rates)',  'Color', 'red', 'FontSize', 10);
yc=0.8*(max(max(beY)));
text(xc, yc, '  0 solid', 'Color', 'black', 'FontSize', 10');
yc=0.75*(max(max(beY)));
text(xc, yc, '  2 solid, 4 dotted (i.e. higher seismicity rates)', 'Color', 'blue', 'FontSize', 10);
clear xc yc;


clear result beX beY beC beh inc betimin betimax betidiff;
clear be_a ben befig bedisp;
