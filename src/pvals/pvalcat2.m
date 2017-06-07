%Last modification: May, 2001 Bogdan Enescu

%This file is called from timeplot.m and helps for the computation of p-value from Omori formula. for different values of Mcut
%and Minimum time. The value of p is then displayed as a isoline map.

global valeg newt2 valeg2 CO

report_this_filefun(mfilename('fullpath'));

prompt = {'If you wish a fixed c, please enter a negative value'};
title = 'Input parameter';
lines = 1;
valeg2 = 2;
def = {num2str(valeg2)};
answer = inputdlg(prompt,title,lines,def);
valeg2=str2double(answer{1});

if valeg2 <= 0
    prompt = {'Enter c'};
    title = 'Input parameter';
    lines = 1;
    CO = 0;
    def = {num2str(CO)};
    answer = inputdlg(prompt,title,lines,def);
    CO=str2double(answer{1});
end


%The parameter valeg is used for choosing some options in mypval2m.m.
valeg = 3;

pvmat = [];
prompt = {'Min. threshold. magnitude','Max. threshold magnitude','Magnit. step','Min. threshold time', 'Max. threshold time','Time step'};
title = 'Input parameters';
lines = 1;
valm1 = min(newt2(:,6));
valm2 = valm1 + 2;
valm3 = 0.1;
valtm1 = 0;
valtm2 = 0.5;
valtm3 = 0.01;
def = {num2str(valm1), num2str(valm2), num2str(valm3), num2str(valtm1), num2str(valtm2), num2str(valtm3)};
answer = inputdlg(prompt,title,lines,def);
valm1=str2double(answer{1}); valm2 = str2num(answer{2}); valm3=str2num(answer{3});
valtm1 = str2double(answer{4}); valtm2 = str2num(answer{5}); valtm3 = str2num(answer{6});

% cut catalog at mainshock time:
l = newt2(:,3) > maepi(1,3);
newt2 = newt2(l,:);

% cat at selecte magnitude threshold
l = newt2(:,6) < valm1;
newt2(l,:) = [];

ho2 = 'hold';
timeplot; drawnow
ho2 = 'noho';

allcount = 0;
itotal = length(valm1:valm3:valm2) * length(valtm1:valtm3:valtm2);
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name',' 3D gridding - percent done');;
drawnow

for valm = valm1:valm3:valm2
    paramc1 = (newt2(:,6) >= valm);
    pcat = newt2(paramc1,:);
    [timpa] = timabs(pcat);
    [timpar] = timabs(maepi);
    tmpar = timpar(1);
    pcat = (timpa-tmpar)/1440;
    for valtm = valtm1:valtm3:valtm2
        allcount = allcount + 1;

        paramc2 = (pcat >= valtm);
        pcat = pcat(paramc2,:);
        %try
        [pv, pstd, cv, cstd, kv, kstd] = mypval2m(pcat);
        %catch
        %pv = NaN; pstd = NaN ; cv = NaN ; cstd = NaN ; kv = NaN; kstd = NaN;
        %disp('set to NaN');
        %end


        if isnan(pv)
            disp('Not a value');
        end
        pvmat = [pvmat; valm valtm pv pstd cv cstd kv kstd];
        waitbar(allcount/itotal)

    end
end

close(wai)
[existFlag,figNumber]=figure_exists('p-value map',1);
newpmapWindowFlag=~existFlag;

if newpmapWindowFlag
    pmap = figure_w_normalized_uicontrolunits( ...
        'Name','p-value-map',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
end

hold on
figure_w_normalized_uicontrolunits(pmap)
hold on
delete(gca)
delete(gca)
axis off


X1 = [valm1:valm3:valm2]; m = length(X1);
Y1= [valtm1:valtm3:valtm2]; n=length(Y1);

[X,Y] = meshgrid(valm1:valm3:valm2,valtm1:valtm3:valtm2);
%The following line can be modified to display other maps: c, k or b - for b other few lines have to be added.
Z = reshape(pvmat(:,3), n, m);
clear X1; clear Y1;
pcolor(X,Y,Z);
shading flat
ylabel(['c in days'])
xlabel(['Min. Magnitude'])
shading interp
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'normal','FontSize',fontsz.m,'Linewidth',1.,'Ticklength',[ 0.02 0.02])


% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.08 0.4 0.02],...
    'FontWeight','normal','FontSize',fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.33 0.09 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',fontsz.m,....
    'FontWeight','normal',...
    'String','p-value');

% reset newt2
newt2 = nn2;


