% This script evaluates the percentage of space time coevered by
%alarms
%
re = [];

% Stefan Wiemer    4/95


report_this_filefun(mfilename('fullpath'));

for tre2 = 6.0:0.1:max(abo(:,4)-0.1)
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

    % Number of successes
    su = []; su2 = []; sueq = [];
    for i = 1:length(la(:,1))
        di = sqrt((((abo(:,1)-la(i,1))*cos(pi/180*la(i,2))*111).^2 + ((abo(:,2)-la(i,2))*111).^2)) ;
        l = di <= 1.0*abo(:,3);
        su = abo(l,:);
        if ~isempty(su)
            dt = maepi(1,3) - (su(:,5)+iala);
            l = dt <= 1.5;
            su2 = [su2 ; su(l,:)];
            sueq = [sueq; la(i,:)];

        end   % if su
    end   % for

    nosu = [];
    for i = 1:length(abo(:,1))
        di = sqrt((((la(:,1)-abo(i,1))*cos(pi/180*abo(i,2))*111).^2 + ((la(:,2)-abo(i,2))*111).^2)) ;
        if  min(di) > 1.0*abo(i,3);
            nosu = [nosu ; abo(i,:)];
        end   % if min
    end   % for i
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

