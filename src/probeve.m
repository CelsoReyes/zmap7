% This script evaluates the percentage of space time coevered by
%alarms
%

% Stefan Wiemer    4/95


report_this_filefun(mfilename('fullpath'));

% space time volume covered by alarms
Va = sum(pi*abo(:,3).^2)*iala;

% All space time
r = reshape(cumuall(len,:),length(gy),length(gx));
l = r < tresh;
V = sum(pi*r(l).^2*(teb-t0b));
disp([' Total space-time volume (R<Rmin):  ' num2str(V)])
disp([' Space-time volume covered with alarms (R<Rmin):  ' num2str(Va)])
disp([' Percent of total covered with alarms (R<Rmin):  ' num2str(Va/V*100) ' Percent' ])

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
disp([' Percent of aceptabel alarm Volume Vs/ (R<Rmin):  ' num2str(Vs/V*100) ' Percent' ])

Vsu = 0;Vnsu = 0;
for k = 1:length(abo(:,1))
    d = sqrt(((abo(k,1) - fa(:,1))*cos(pi/180*34)*111).^2 + ((abo(k,2) - fa(:,2))*111).^2);
   if abo(k,3)  >= min(d)  && abo(k,5)+iala+iala > 92.48
        Vsu = Vsu + (pi*abo(k,3)^2)*iala;
    else
        Vnsu = Vnsu + (pi*abo(k,3)^2)*iala;
    end  % if
end %  for  k
disp([' succ Volume Vsu (R<Rmin): ' num2str(Vsu)  ])
disp([' not succ Volume Vnsu (R<Rmin):  ' num2str(Vnsu)  ])
disp([' succes ratio Vsu/Vnsu (R<Rmin):  ' num2str(Vsu/Vnsu)  ])



figure_w_normalized_uicontrolunits(gcf)
hold on

% if isempty(su2) == 0; plo  = plot3(su2(:,1),su2(:,2),su2(:,5)+iala,'gx');end;



nosu = [];
for i = 1:length(abo(:,1))
    di = sqrt((((maepi(:,1)-abo(i,1))*cos(pi/180*abo(i,2))*111).^2 + ((maepi(:,2)-abo(i,2))*111).^2)) ;
    if  min(di) >= 2*abo(i,3);
        nosu = [nosu ; abo(i,:)];
    end   % if min
end   % for i
%disp(['Number of alarms : ' num2str(length(su2(:,1))) ]);
%disp(['Number of false  alarms : ' num2str(length(nosu(:,1))) ]);
if isempty(sueq)  == 0
    disp(['Number of successes: ' num2str(length(sueq(:,1))) ]);
    disp(['Number of failures to predict: ' num2str(length(maepi(:,1))-length(sueq(:,1))) ]);
else
    disp(['Number of successes: 0 ' ]);
    disp(['Number of failures to predict: ' num2str(length(maepi(:,1))) ]);
end


