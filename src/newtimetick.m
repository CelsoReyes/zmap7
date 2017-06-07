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


T = datenum( floor(newt2(:,3)), newt2(:,4), newt2(:,5) , newt2(:,8), newt2(:,9), newt2(:,9)*0);
plot(T,(1:length(T)),'Linewidth',2);


datetick('x',nuT);
xlabel('Time  ','FontSize',fontsz.m)
ylabel('Cumult. Number','FontSize',fontsz.m)

set(gca,'visible','on','FontSize',fontsz.s,...
    'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
    'Box','on')

hold on
if par1>=1
    if ~isempty(big)

        l = newt2(:,6) > minmag;
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
