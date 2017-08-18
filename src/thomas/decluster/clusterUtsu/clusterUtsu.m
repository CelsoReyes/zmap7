function [mCatclus] =  clusterUtsu(mCatalog, Mainmag, Mc, t1, t2)

% Example [mCatclus] =  clusterGK(b, 1.95, 1.95, 1984, 1, 1);

%
% Input parameters:
%   mCatalog        Earthquake catalog
%   Mainmag         minimum mainmag magnitude
%   Mc              Completeness magnitude
%   startyear
%   t1              time before an earthquake in days
%   t2              time window following an earthquake in days
%
% Output parameters:
%   fBValue         mCatclus: The clustered catalog for further anaysis
%
% Annemarie Christophersen, 23. August 2007


% Clustering function, based on Annemarie's perl codes for finding
% aftershock sequences, 14 March 2007

% Code written for catalogue under zmap, thus the input
% catalogue is in the variable a, where
% column 1: longitude
% column 2: latitude
% column 3: year (decimal year, including seconds)
% column 4: month
% column 5: day
% column 6: magnitude
% column 7: depth
% column 8: hour
% column 9: minute
% column 10: seconds
% column 11-23 not important for clustering and cluster analysis
% column 24: SCSN flag for event type (l=local, r=regional, q=quarry)

% variables used
% mc completeness magnitude
% twindow duration in time in which to look for related events

Dtafter = days(t2); %30 days in decimal years
Dtbefore = days(t1); %2 days in decimal years
clusterno = 1;

% l = mCatalog.Magnitude >= Mc & mCatalog.Date>=startyear;
b = [mCatalog(:,1:10) mCatalog(:,1:4)*0 ];
le = b.Count;

for i = 1:le
    %write i to screen
    if rem(i,100) == 0;
        i
    end
    if (b(i,12) == 0 && b(i,6) > Mainmag)
        tref=b(i,3); %reference time
        magref=b(i,6); %reference mag
        b(i,12)=clusterno;
        latref = b(i,2);
        lonref = b(i,1);
        searchradius=10^(0.5*magref-1.5965); %search radius according to Uhrhammer
        eventsDtbefore=(b.Date > tref-Dtbefore & b.Date < tref);
        eventsbefore = length(b(eventsDtbefore,1));
        lino = i-eventsbefore;

        while b(lino,3) < (tref+Dtafter) && (lino+1 < le)
            if b(lino,12) ==0
                if b(lino,6) > magref
                    searchradius=10^(0.5*magref-1.5965);
                end
                edist = deg2km(distance(latref,lonref,b(lino,2),b(lino,1)));
                if (edist <= searchradius)
                    b(lino,12)=clusterno;
                    if (b(lino,6) > Mc && b(lino,3) >tref)
                        tref=b(lino,3);
                    end
                    if b(lino,6) > magref
                        latref = b(lino,2);
                        lonref = b(lino,1);
                        magref= b(lino,6);
                        eventsDtbefore=(b.Date > tref-Dtbefore &...
                            b.Date < tref);
                        eventsbefore = length(b(eventsDtbefore,1));
                        lino = lino-eventsbefore -1;
                    end
                end
                searchradius=10^(0.5*magref-1.5965);
            end
            lino=lino+1;
        end
    end


        clusterno=clusterno+1;

end

%Ouput clustered matrix
% column 1: longitude
% column 2: latitude
% column 3: year (decimal year, including seconds)
% column 4: month
% column 5: day
% column 6: magnitude
% column 7: depth
% column 8: hour
% column 9: minute
% column 10: seconds
% column 11: line number
% column 12: cluster number
% column 13: mainshock with its cluster number
% column 14: initiating event cluster number

b.Magnitude=round(b.Magnitude*10)/10;%  round magnitudes to 0.1
clusterno = 1;
b(:,11)= 1:length(b)'; %introduce column 13 with row number

for i = 1:b.Count
    vSel=find(b(:,12)==i);
    if ~isempty(vSel)
        nMin =min(find(b(vSel,6)== max(b(vSel,6))));
        b(vSel(nMin),13)=clusterno; %label first largest event with clusterno
        b(vSel,12)=clusterno; %label all events of the cluster with clusterno
        b(min(find(b(:,12)==clusterno)),14)=clusterno; %label first event in column 14
        clusterno=clusterno+1;
    end
end
mCatclus=b;
