% ZMAP script allhist.m.
% calculates a histogram of all z-value in space and time
% using the rubberband function with a window length of 1.5 years
%
% stefan wiemer 11/94
%


% Input Rubberband
%
report_this_filefun(mfilename('fullpath'));

tre2 = 4.00;

clear abo;
abo=[];

% initial parameter
iwl = floor(iwl2* 365/par1);
[len, ncu] = size(cumuall); len = len-2;
var1 = zeros(1,ncu);
var2 = zeros(1,ncu);
mean1 = zeros(1,ncu);
mean2 = zeros(1,ncu);
as = zeros(1,ncu);
n2 = [];


% loop over all grid points for percent
%
%

% loop over all point for rubber band
%
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Allhist - Percent done');;
pause(1)
think
drawnow

n2 = zeros(1,length(-15:0.1:15));
if sta == 'lta'

    for ti = iwl:step:len-iwl
        cu = [cumuall(1:ti-1,:) ; cumuall(ti+iwl+1:len,:)];
        mean1 = mean(cu);
        mean2 = mean(cumuall(ti:ti+iwl,:));
        for i = 1:ncu
            var1(i) = cov(cu(:,i));
            var2(i) = cov(cumuall(ti:ti+iwl,i));
        end     % for i
        as = (mean1 - mean2)./(sqrt(var1/(len-iwl)+var2/iwl));
        [m,n] = size(as);
        reall = reshape(as,1,m*n);

        % set values gretaer tresh = nan
        %
        %s = cumuall(len,:);
        %r = reshape(as,length(gy),length(gx));
        l = reall > tre2;
        s = [  loc(1,l) loc(2,l) loc(3,l)   reall(l) ];
        s = [reshape(s,length(s)/4,4) ones(length(s)/4,1)*ti];
        abo = [abo ;  s];
        [n,x] =histogram(reall,(-15:0.10:15));
        n2 = n2 + n;
        waitbar((ti-iwl)/(len-2*iwl))
    end   % for ti
end % if lta

if sta == 'rub'
    for ti = iwl:step:len-iwl
        for i = 1:ncu
            mean1(i) = mean(cumuall(1:ti,i));
            mean2(i) = mean(cumuall(ti+1:ti+iwl,i));
            var1(i) = cov(cumuall(1:ti,i));
            var2(i) = cov(cumuall(ti+1:ti+iwl,i));
        end %  for i ;
        as = (mean1 - mean2)./(sqrt(var1/ti+var2/iwl));


        [m,n] = size(as);
        reall = reshape(as,1,m*n);

        % set values gretaer tresh = nan
        %
        s = cumuall(len,:);
        %r = reshape(s,length(gy),length(gx));
        l = reall > tre2;
        s = [  loc(1,l) loc(2,l) loc(3,l)   reall(l) ];
        s = [reshape(s,length(s)/4,4) ones(length(s)/4,1)*ti];
        abo = [abo ;  s];

        [n,x] =histogram(reall,(-15:0.10:15));
        n2 = n2 + n;
        waitbar((ti-iwl)/(len-2*iwl))
    end   % for ti
end   % if riub

close(wai)
figure
bar(x,n2,'k');
grid
xlabel('z-value ','FontWeight','bold','FontSize',fontsz.m)
ylabel('Number ','FontWeight','bold','FontSize',fontsz.m)
watchoff

set(gca,'visible','on','FontSize',fontsz.l,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')

set(gca,'Color',[1 1 0.7])

uicontrol('Units','normal',...
    'Position',[.0 .93 .08 .06],'String','Print ',...
     'Callback','myprint')


uicontrol('Units','normal',...
    'Position',[.0 .75 .08 .06],'String','Close ',...
     'Callback','f1=gcf; f2=gpf; set(f1,''Visible'',''off'');if f1~=f2, welcome;done; end')
matdraw

abo2 = abo;
iala = iwl2
catSave3 =...
    [ 'zmap_message_center.set_info(''Save Alarm Cube?'',''  '');',...
    '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Save Alarm Cube Datafile?'',400,400);',...
    ' sapa2 = [''save '' path1 file1 '' cumuall abo loc abo2 iala iwl2''];',...
    ' if length(file1) > 1, eval(sapa2),end , done'];

eval(catSave3)

done
% plot the cube
plotala



