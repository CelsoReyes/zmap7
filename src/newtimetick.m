% build nice tickmarks


help datetick

prompt={'Enter the datetick format number, choosen from the datetick help table:'};
def={'0'};
dlgTitle='Input ';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
l = answer{:};
nuT = str2double(l);

figure_w_normalized_uicontrolunits(cum)
xlim = get(gca,'Xlim');

delete(gca)
delete(gca)

rect = [0.25,  0.18, 0.60, 0.70];
axes('position',rect);


T = datenum( ZG.newt2.Date.Year, ZG.newt2.Date.Month, ZG.newt2.Date.Day , ZG.newt2.Date.Hour, ZG.newt2.Date.Minute, zeros(size(ZG.newt2.Date)));
plot(T,(1:length(T)),'Linewidth',2);


datetick('x',nuT);
xlabel('Time  ','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Cumult. Number','FontSize',ZmapGlobal.Data.fontsz.m)

set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
    'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
    'Box','on')

hold on
if ZG.bin_days>=1
    if ~isempty(big)

        l = ZG.newt2.Magnitude > ZG.big_eq_minmag;
        f = find( l  == 1);
        bigplo = plot(T(f),f,'hm');
        set(bigplo,'LineWidth',1.0,'MarkerSize',10,...
            'MarkerFaceColor','y','MarkerEdgeColor','k')
        stri4 = [];
        [le1,le2] = size(big);
        for i = 1:le1;
            s = sprintf('  M=%3.1f',big(i,6));
            stri4 = [stri4 ; s];
        end   % for

    end
end %if big
