% This script evaluates the percentage of space time coevered by
%alarms
%
report_this_filefun(mfilename('fullpath'));

re = [];

% Stefan Wiemer    4/95

messtext=...
    ['In order to estimate the succesful volume '
    'is is nessesary to define the rupture zone'
    'Please input the rupture fault or rupture '
    'areas as a sequence of point using the    '
    'left mouse button.                        '
    'Use the RIGHT mouse button for the final  '
    'point. Operates on the original catalogue '
    'producing a reduced  subset which in turn '
    'the other routines operate on.            '];

zmap_message_center.set_message('Input ruptured fault',messtext);
hold on
x = []; y = []; n = 0;
figure_w_normalized_uicontrolunits(map);

% Loop, picking up the points.
%
but = 1;
while but == 1 | but == 112
    [xi,yi,but] = ginput(1);
    mark1 =    plot(xi,yi,'o','era','normal'); % doesn't matter what erase mode is
    % used so long as its not NORMAL
    set(mark1,'MarkerSize',10,'LineWidth',2.0)
    n = n + 1;
    % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
    % set(mark2,'FontSize',15,'FontWeight','bold')
    x = [x; xi];
    y = [y; yi];
end
% define the fault
fa = [x   y ];
zmap_message_center.set_info('Message',' Thank you .... ')
think

abo = abo2;
for tre2 = min(abo(:,4)):0.1:max(abo(:,4)-0.1)
    abo = abo2;
    abo(:,5) = abo(:,5)* par1/365 + a(1,3);
    l = abo(:,4) > tre2;
    abo = abo(l,:);
    l = abo(:,3) < tresh;
    abo = abo(l,:);
    hold on

    % space time volume covered by alarms
    Va = sum(pi*abo(:,3).^2)*1;

    % All space time
    [len, ncu] = size(cumuall);
    r = reshape(cumuall(len,:),length(gy),length(gx));
    l = r < tresh;
    V = sum(pi*r(l).^2*(teb-t0b));
    disp([' Total space-time volume (R<Rmin):  ' num2str(V)])
    disp([' Space-time volume covered with alarms (R<Rmin):  ' num2str(Va)])
    disp([' Percent of total covered with alarms (R<Rmin):  ' num2str(Va/V*100) ' Percent' ])
    %re = [re ; tre2 Va/V*100];


    % total Volume that would have been a success
    %
    Vs = 0;
    for x = 1:length(gx)
        for y = 1:length(gy)
            d = sqrt(((gx(x) - fa(:,1))*cos(pi/180*34)*111).^2 + ((gy(y) - fa(:,2))*111).^2);

           if r(y,x) >= min(d)  && r(y,x) < tresh
                Vs = Vs + (pi*r(y,x)^2)*iala;
            end  % if
        end %  for  x
    end %  for  y



    % Number of successes
    su = []; su2 = []; sueq = [];
    for i = 1:length(maepi(:,1))
        di = sqrt((((abo(:,1)-maepi(i,1))*cos(pi/180*maepi(i,2))*111).^2 + ((abo(:,2)-maepi(i,2))*111).^2)) ;
        l = di <= 2.0*abo(:,3);
        su = abo(l,:);
        if ~isempty(su)
            dt = maepi(i,3) - (su(:,5)+iala);
            l = dt <= 1.5;
            su2 = [su2 ; su(l,:)];
            sueq = [sueq; maepi(i,:)];

        end   % if su
    end   % for

    nosu = [];
    for i = 1:length(abo(:,1))
        di = sqrt((((maepi(:,1)-abo(i,1))*cos(pi/180*abo(i,2))*111).^2 + ((maepi(:,2)-abo(i,2))*111).^2)) ;
        if  min(di) > 1.5*abo(i,3);
            nosu = [nosu ; abo(i,:)];
        end   % if min
    end   % for i
    if isempty(nosu) == 1 ; nosu = 0; end
    disp(['Number of false  alarms : ' num2str(length(nosu(:,1))) ]);
    if isempty(sueq)  == 0
        disp(['Number of successes: ' num2str(length(sueq(:,1))) ]);
        disp(['Number of failures to predict: ' num2str(length(maepi(:,1))-length(sueq(:,1))) ]);
    else
        disp(['Number of successes: 0 ' ]);
        disp(['Number of failures to predict: ' num2str(length(maepi(:,1))) ]);
    end

    re = [re ; tre2 Va/V*100 length(sueq(:,1)) length(nosu(:,1)) length(su2(:,1))];

end   % for tre2


figure

matdraw
rect = [0.20,  0.10, 0.70, 0.60];
axes('position',rect)
hold on
pl = plot(re(:,1),re(:,2),'r')
set(pl,'LineWidth',2.5)

set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')
grid

ylabel('Va/Vtotal in %')
xlabel('Zalarm ')
