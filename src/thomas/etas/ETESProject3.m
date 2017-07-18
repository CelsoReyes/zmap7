function [N,Mmax,catalog,IDAll,HistoryAll] = ETESProject3(cat,vEtas,vAfter,StartDateProj,EndDate,FaultParam)

%Written by Karen Felzer, 2007.
%This program is like ETESProject.m except that background earthquakes are
%taken from an input grid, in the same manner as in TotalAftSim.8, instead
%of smoothed directly from the catalog.  See the companion MakeRateGrid.m
%program also in this directory.

%This program starts with A real earthquake catalog and then
%projects what seismicity will follow further in time.  This is A Monte
%Carlo modeler -- ideally it should be run multiple times to get average
%results and error.  It also has A background component.  The background
%component is set by BckgrndR -- this gives the number of earthquakes that
%you want each year as
%background earthquakes.  The background earthquakes will have an r^1.37
%distribution in one dimension distribution away from hypocenters in the
%input catalog which are identified as being background earthquakes
%themselves (e.g. not wihtin one fault length and 10 years of A bigger
%earthquake).

%Earthquakes that are smaller than magb are treated as point sources;
%earthquakes that are larger than magb are modeled as planes.  Where the
%middle of the fault plane is not well constrained we use the median of the
%first two days of the aftershock sequence.  For simplicity, large
%simulated aftershocks are assigned the same focal mechanisms as their
%mainshocks.  Where the mainshocks are too small for their focal mechanism
%to be listed we use 75% 332 degree strike aqnd 25% 242 degree strike,
%based on approximate assesement of trends in the Southern California
%catalog, with A 90 degree dip.

%Input:

% cat: Real eartquake catalog.  Ten column format: year, month, day, hour,
% minute, second, lat, lon, depth, magnitude.

%RateGrid: Background rate, spatially varying.  minlon,maxlon, minlat,
%maxlat, earthquake rate of M>=4.

%CX, P, A: Omori's law parameters, c, p, and A.  They should be entered
%as direct triggering parameters, with A recommended p = 1.37.  The value
%of A should be appropriate for the rate of A mainshock of magnitude M
%triggering aftershocks of magnitude >=M.  For Mmin = 2.5, we recommend CX = 0.095, P = 1.34, and
%A = 0.008. (from Felzer and Kilb, in preparation, 2007).

% Mmin: Minimum earthquake magnitude to report and simulate
% MminR: Minimum earthquake magnitude for reporting in the output catalog
% maxm: Maximum earthquake magnitude
% DMax: Maximum distance for aftershocks
% EndDate: Last date for the simulated catalog, to be entered as float
%StartDate; First date for the projected catalog
% (e.g. 1975.54  'January 1, 2007').  The simulated catalog will begin immediately
% after the last date in the input catalog cat.

%magb: Cutoff magnitude for the point source vs. plane source
%representation of the mainshock

%FaultParam: Fault parameters for the M>magb earthquakes, listed in order
%of their occurrence in the catalog.  Columns give fault length, width,
%strike, dip, year, month, day.


%OUTPUT:

%N: total number of aftershocks in the simulated catalog.  Comparing N with
%the total length of the catalog produced gives the percentage of the total
%that is aftershocks.

%MMax: Maximum magnitude in the simulated catalog

%catalog: The simulated catalog
%columns 1-10: years, month, day, hour, minute, second, lat, lon, depth,
%magnitude.  Column 11: ID number for this earthquake.  Column12: If this
%earthquake is an aftershock, column 12 gives the ID number of its
%mainshock.  Column 13: If the earthquake is an aftershock, the distance
%between its epicenter and the nearest point on the fault plane of the
%mainshock that triggered it.

%IDAll: The ID numbers for each earthquake; same output as is listed in
%Column 11 of the catalog

%HistoryAll: Mainshock of each earthquake; same output as is listed in
%Column 13 of the catalog.

%%%%Starting the program
%set up
CX=vEtas(1);
P=vEtas(2);
A=vEtas(3);

Mmin=vAfter(1);
MminR=vAfter(2);
maxm=vAfter(3);
DMax=vAfter(4);
magb=vAfter(5);


N = zeros(1,1);
Mmax = zeros(1,1);
tdistAll = [];

[fYr1, nMn1, nDay1, nHr1, nMin1, nSec1]=decyear2mat(StartDateProj);
StartDateProj=datenum(floor(fYr1),nMn1,nDay1,nHr1, nMin1,nSec1);
[fYr2, nMn2, nDay2, nHr2, nMin2, nSec2]=decyear2mat(EndDate);
EndDate=datenum(floor(fYr2),nMn2,nDay2,nHr2, nMin2,nSec2);

T = EndDate - StartDateProj;  %Gives longest time that aftershocks may be generated over; for simplicity all aftershocks will
%be generated over this time and then be trimmed as needed.

T3 = EndDate;   %Gives the end time of the simulation

T2 = StartDateProj;  %The starting date of the projected catalog

%And limiting the big earthquakes in FaultParam to before the beginning of
%the simulation

% tp = datenum(FaultParam(:,5),FaultParam(:,6),FaultParam(:,7));
% xp = find(tp>T2 | tp<datenum(StartDate));
% changes vst
FaultParam = [NaN NaN NaN NaN NaN NaN NaN];
% FaultParam(xp,:) = [];


%Finding the average number of aftershocks expected in time T for M - Maft
%= 0.

if(P ~= 0)
    NM = (A/(1-P))*((T+CX)^(1-P) - CX^(1-P));
else
    NM = A*(log(T+CX) - log(CX));
end

%Setting up rotation matrices for later so that simulated M>magb mainshocks will have
%either 332 degree strike or 242 degree strike.  Based on A quick eye
%assessment of the So Cal fault map, 75% of mainshocks will be assigned the
%332 strike and 25% the 242 strike.

z1 = deg2rad(303);
lambda1 = [cos(z1) sin(z1); -sin(z1) cos(z1)];

z2 = deg2rad(213);
lambda2 = [cos(z2) sin(z2); -sin(z2) cos(z2)];

%And converting catalog times to Julian days

tdist = datenum(cat(:,1),cat(:,2),cat(:,3),cat(:,4),cat(:,5),cat(:,6));

m = cat(:,10);

%eliminating catalog earthquakes that are past the start of the projection

A=[];
cat(A,:) = [];
tdist(A) = [];
m(A) = [];

%And changing the lat, lon to xy
catxy = cat;
locCen(1) = mean(cat(:,7));
locCen(2) = mean(cat(:,8));
catxy(:,7:8) = latlon2xy2(catxy(:,7:8),locCen);
Locs = [catxy(:,7) catxy(:,8) catxy(:,9)];
NBack=size(Locs,1);

%And initiating ID, history, and fault distance tracking matrices, and
%putting magnitudes in A vector
ID = [1:1:length(tdist)];
History = zeros(size(ID));
FaultDist = -1*ones(size(ID));

aa2 = find(m>=MminR & tdist>=T2 & tdist<T3);  %we only report earthquakes in the final catalog for m>=MminR

if(~isempty(aa2))
    tdistAll(1:length(aa2)) = tdist(aa2)';
    LocsAll(1:length(aa2),:) = Locs(aa2,:);
    mAll(1:length(aa2),:) = m(aa2);
    IDAll(1:+length(aa2),:) = ID(aa2)';
    HistoryAll(1:length(aa2),:) = 0;
    FaultDistAll(1:+length(aa2),:) = -1;
end

% And doing some final setting up for the ETAS run
N = 0;
Mmax = 0;
ID = ID';
History = History';
FaultDist = FaultDist';

%Now running the ETAS simulation***********%%%%%%%%%%%%

%The loop gets all of the aftershocks of each earthquake occurring within
%the specified duration of the catalog and over the minimum magnitude for
%the simulation

xm = find(m>=MminR);
maxID = max(ID);

countAll = length(tdistAll)+1;

A = find(m>=Mmin & tdist<=T3);

NIttr = 1;


while(~isempty(A))

    IDold = ID(A);

    %Running the small point source and larger extended source earthquakes
    %separtely, through different versions of the aftershock program.
    %First, the small point source earthquakes

    a2 = find(m(A)<magb);

    a2 = A(a2);

    tdistSave = tdist;
    IDSave = ID;
    mSave = m;
    LocsSave = Locs;



    try
        [tdist,m,Locs,ID,History,FaultDist] = GAft3(tdist(a2),maxID,ID(a2),m(a2),Mmin,maxm,NM,T,Locs(a2,:),DMax,P,CX);
    catch
        disp('No point source events');
    end
    %And then doing the larger, plane source earthquakes

    a3 = find(mSave(A)>=magb);

    a3 = A(a3);

    if(~isempty(a3))

        if(NIttr>0)  %These are simulated large earthquakes which need FaultParam assigned.  Doing widths and lengths from Wells & Coppersmith

            FaultParam = BuildFaultParam(mSave(a3),LocsSave(a3,:),lambda1,lambda2);
        end

        %And getting the aftershocks for the big mainshocks

        try
            [tdist2,m2,Locs2,ID2,History2,FaultDist2] = GAft4(tdistSave(a3),maxID,IDSave(a3),mSave(a3),Mmin,maxm,NM,T,LocsSave(a3,:),DMax,FaultParam,P,CX);
        catch
            disp('No plane source events');
        end

    else
        tdist2 = [];
        m2 = [];
        Locs2 = [];
        ID2 = [];
        History2 = [];
        FaultDist2 = [];
    end

    %And putting the results from the two runs together

    tdist = [tdist; tdist2];




    m = [m; m2];
    Locs = [Locs; Locs2];
    ID = [ID ID2];
    History = [History'; History2];
    FaultDist = [FaultDist; FaultDist2];


    maxID = max([maxID max(ID)]);


    A = find(tdist>T2 & tdist<=T3);


    aa2 = find(m(A)>=MminR);  %we only report earthquakes in the final catalog for m>=MminR

    aa2 = A(aa2);


    if(~isempty(aa2))

        tdistAll(countAll:countAll+length(aa2)-1) = tdist(aa2)';

        LocsAll(countAll:countAll+length(aa2)-1,:) = Locs(aa2,:);

        mAll(countAll:countAll+length(aa2)-1,:) = m(aa2);

        IDAll(countAll:countAll+length(aa2)-1,:) = ID(aa2)';

        HistoryAll(countAll:countAll+length(aa2)-1,:) = History(aa2);

        FaultDistAll(countAll:countAll+length(aa2)-1,:) = FaultDist(aa2);

    end


    countAll = countAll+length(aa2);

    N = N + length(aa2);


    if(max(m(A))>Mmax)
        Mmax = max(m(A));
    end


    N;
    Mmax;

    NIttr = NIttr + 1;

end


%And translating the results into A traditional earthquake catalog

% tdays = datenum(StartDate) + tdistAll;

tvect = datevec(tdistAll);

latlon = xy2latlon(LocsAll(:,1:2),locCen);

catalog = [tvect latlon LocsAll(:,3) mAll IDAll HistoryAll FaultDistAll];

catalog = sortrows(catalog,[1 2 3 4 5 6]);

%cat = gquakes(catalog,StartDate,EndDate);

%At this point solving for the background rate, RateGrid, if it was
%initially input as zero.



%--------------------------------------%%%

%Getting aftershock times, locations, and mags for point source mainshocks

function [tdist,m,Locs,ID,History,FaultDist] = GAft3(tdist,maxID,IDold,m,Mmin,maxm,NM,T,Locs,DMax,P,CX)


    %First getting the number of aftershocks produced by each mainshock; stored
    %in the vector A.

    A = NM.*10.^(m - Mmin);

try
    A = poissinv(rand(size(A,1),1),A);
catch
    poisstest.NM=NM;
    poisstest.A=A;
    poisstest.m=m;
    save poisstest.mat poisstest -mat
    A = poissinv(rand(size(A,1),1),A);
end

    counter = 1;

    x = find(A>0);

    tnew2 = [];


    %Making A vector with all of the mainshock times and locations

    %counter = 1;

    %for j = 1:length(tdist(x))
    %   AddOn(counter:counter+A(x(j))-1) = tdist(x(j));
    %  nn = A(x(j));
    % LocsT = [Locs(x(j),1)*ones(nn,1) Locs(x(j),2)*ones(nn,1) Locs(x(j),3)*ones(nn,1)];
    %AddDist(counter:counter+A(x(j))-1,1:3) = LocsT;
    %counter = counter + A(x(j));
    %end

    %TRYING TO DO THE ABOVE FASTER

    if(~isempty(x))

        Axx = A(x);
        Axx = cumsum(Axx);
        Sp = [1; Axx(1:end-1)+1];
        Ep = Axx;
        tdist = tdist(x);
        Locs = Locs(x,:);
        xl = Locs(:,1);
        yl = Locs(:,2);
        zl = Locs(:,3);


        %The loop below is the time limiting factor for the whole calculation in
        %matlab

        AddOn = zeros(Axx(end),1);

        for j=1:length(x)

            AddOn(Sp(j):Ep(j)) = tdist(j);
            lx(Sp(j):Ep(j)) = xl(j);
            ly(Sp(j):Ep(j)) = yl(j);
            lz(Sp(j):Ep(j)) = zl(j);
            History(Sp(j):Ep(j)) = IDold(x(j));

        end


        AddDist = [lx' ly' lz'];


        %IN THIS VERSION: For each aftershock that will be produced, listing the
        %location of the mainshock that will produce it.

        %NOTE: COMMENTING THIS OUT RIGHT NOW TO SAVE TIME

        %for j = 1:length(tdist(x))


        %   nn = A(x(j));

        %   LocsT = [Locs(x(j),1)*ones(nn,1) Locs(x(j),2)*ones(nn,1) Locs(x(j),3)*ones(nn,1)];

        %  AddDist(counter:counter+A(x(j))-1,1:3) = LocsT;
        %  History(counter:counter+A(x(j))-1,1) = IDold(x(j));
        %  counter = counter + A(x(j));


        %end


        %Summing the total number of aftershocks

        AX = sum(A);

        %Now getting distances of all of the aftershocks from the faults
        %Allowing A closest approach of 1 m.

        dnew = GPowDistR(1.37,AX,0.001,DMax);

        FaultDist = dnew;

        %Converting the distances into x, y using A random theta.
        %Although not completely accutate, to save computation time
        %just keeping z the same as the generating point on the fault
        %so that we don't need to worry about staying within seismogenic
        %depth.  NOTE: there is code in the program for Joan that can be used
        %to fix this!  GET IT FIXED!!

        theta = rand(length(dnew),1).*2*pi;


        xnew = dnew.*cos(theta);
        ynew = dnew.*sin(theta);
        znew = zeros(length(ynew),1);

        LocsNew = AddDist + [xnew ynew znew];


    end


    %Now generating the aftershock times


    if(~isempty(x))


        %Then calculating times for all of the aftershocks, in terms of time since
        %the mainshock

        %tnew = GPowDistR(1.37,AX,0.0104,T);

        tnew = GPowDistRc(P,CX,AX,0,T);

        %And finally adding each aftershock time to the time of its mainshock to
        %get the absolute time of the aftershock in the catalog

        tnew2 = tnew + AddOn;

    end

    %And assigning the aftershock magnitudes

    if(~isempty(tnew2))

        m = GetMag(length(tnew2),Mmin,maxm);

        tdist = tnew2;
        Locs = LocsNew;

    else
        tdist = [];
        m = [];
        Locs = [];
        ID = [];
        History = [];
        FaultDist = [];
    end

    %And generating ID numbers for all of the aftershocks

    if(~isempty(x))

        ID = [maxID+1:1:maxID+AX+1];
    end

%---------------------------------------

%Getting aftershock times, locations, and mags for fault plane mainshocks

function [tdist,m,Locs,ID,History,FaultDist] = GAft4(tdist,maxID,IDold,m,Mmin,maxm,NM,T,Locs,DMax,FaultParam,P,CX)


    %First getting the number of aftershocks produced by each mainshock; stored
    %in the vector A.

    A = NM.*10.^(m - Mmin);


    A = poissinv(rand(length(A),1),A);

    counter = 1;

    x = find(A>0);

    tnew2 = [];

    %And setting up the fault plane

    %And for each aftershock that will be produced, picking A random reference
    %point on the mainshock fault that the distance of the aftershock from the
    %fault will be measured from.

    %IN THIS VERSION: For each aftershock that will be produced, listing the
    %location of the mainshock that will produce it.

    for j = 1:length(tdist(x))

        FaultY = FaultParam(j,4);
        FaultZ = FaultParam(j,5);

        YLow = FaultParam(j,2) - FaultY/2;
        ZLow = FaultParam(j,3) - FaultZ/2;

        %And getting points on the fault that will generate the earthquakes

        rpy = rand(A(x(j)),1).*FaultY;
        rpz = rand(A(x(j)),1)*FaultZ;
        rpx = zeros(size(rpy,1),1);

        rpy = rpy - FaultY/2;


        %Then rotating to the proper strike and dip

        %matrix for rotation around strike

        z1 = deg2rad(FaultParam(x(j),6));
        lambda1 = [cos(z1) sin(z1); -sin(z1) cos(z1)];

        z2 = deg2rad(FaultParam(x(j),7) - 90);  %rotation around dip

        if(FaultParam(x(j),6)>180)
            z2 = deg2rad(90-FaultParam(x(j),7));
        end

        lambda2 = [cos(z2) sin(z2); -sin(z2) cos(z2)];

        %And rotating.  Fist going to A 0 degree strike, and then to A 90 degree
        %dip.
        rot = lambda1*[rpx rpy]';

        rpx = rot(1,:)';
        rpy = rot(2,:)';


        rot = lambda2*[rpz rpy]';

        rpz = rot(1,:)';
        rpy = rot(2,:)';

        Lx = rpx + FaultParam(x(j),1);
        Ly = rpy + FaultParam(x(j),2);
        Lz = rpz + FaultParam(x(j),3);




        %And assigning the points on the fault from which aftershocks will be generated
        %And placing ID values in the history matrix

        AddDist(counter:counter+A(x(j))-1,1:3) = [Lx Ly Lz];
        History(counter:counter+A(x(j))-1,1) = IDold(x(j));
        counter = counter + A(x(j));


    end


    if(~isempty(x))

        %Summing the total number of aftershocks

        AX = sum(A);

        %Now getting distances of all of the aftershocks from the faults
        %Allowing A closest approach of 1 m.

        dnew = GPowDistR(1.37,AX,0.001,DMax);

        FaultDist = dnew;

        %Converting the distances into x, y using A random theta.
        %Although not completely accurate, to save computation time
        %just keeping z the same as the generating point on the fault
        %so that we don't need to worry about staying within seismogenic
        %depth.  NOTE: there is code in the program for Joan that can be used
        %to fix this!  GET IT FIXED!!

        theta = rand(length(dnew),1).*2*pi;


        xnew = dnew.*cos(theta);
        ynew = dnew.*sin(theta);
        znew = zeros(length(ynew),1);



        LocsNew = AddDist + [xnew ynew znew];



    end


    %Now generating the aftershock times


    %Making A vector with all of the mainshock times

    counter = 1;

    for j = 1:length(tdist(x))
        AddOn(counter:counter+A(x(j))-1) = tdist(x(j));
        counter = counter + A(x(j));
    end

    if(~isempty(x))


        %Then calculating times for all of the aftershocks, in terms of time since
        %the mainshock

        %tnew = GPowDistR(1.37,AX,0.0104,T);

        tnew = GPowDistRc(P,CX,AX,0,T);

        %And finally adding each aftershock time to the time of its mainshock to
        %get the absolute time of the aftershock in the catalog

        tnew2 = tnew + AddOn';

    end

    %And getting aftershock magnitudes

    if(~isempty(tnew2))

        m = GetMag(length(tnew2),Mmin,maxm);

        tdist = tnew2;
        Locs = LocsNew;

    else
        tdist = [];
        m = [];
        Locs = [];
        ID = [];
        History = [];
        FaultDist = [];
    end

    %And generating ID numbers for all of the aftershocks

    if(~isempty(x))

        ID = [maxID+1:1:maxID+AX+1];
    end




%------------------------------------

%Getting aftershock magnitudes


function m = GetMag(L,Mmin,maxm)


    m = Mmin - log10(rand(L,1));

    x = find(m>maxm);


    for i=1:length(x)

        while(m(x(i))>maxm)
            m(x(i)) = Mmin - log10(rand(1));

        end
    end
