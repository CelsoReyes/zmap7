function [N,Mmax,catalog,IDAll,HistoryAll] = ETESProject2(cat,RateGrid,CX,P,A,Mmin,MminR,maxm,DMax,StartDateProj,EndDate,magb,FaultParam)
    
    %This program is like ETESProject.m except that background earthquakes are
    %taken from an input grid, in the same manner as in TotalAftSim.8, instead
    %of smoothed directly from the catalog.  See the companion MakeRateGrid.m
    %program also in this directory.
    %
    %This program starts with A real earthquake catalog and then
    %projects what seismicity will follow further in time.  This is A Monte
    %Carlo modeler -- ideally it should be run multiple times to get average
    %results and error.  It also has A background component.  The background
    %component is set by BckgrndR -- this gives the number of earthquakes that
    %you want each year as
    %background earthquakes.  The background earthquakes will have an r^1.37
    %distribution in one dimension distribution away from hypocenters in the
    %input catalog which are identified as being background earthquakes
    %themselves (e.g. not within one fault length and 10 years of A bigger
    %earthquake).
    %
    %Earthquakes that are smaller than magb are treated as point sources;
    %earthquakes that are larger than magb are modeled as planes.  Where the
    %middle of the fault plane is not well constrained we use the median of the
    %first two days of the aftershock sequence.  For simplicity, large
    %simulated aftershocks are assigned the same focal mechanisms as their
    %mainshocks.  Where the mainshocks are too small for their focal mechanism
    %to be listed we use 75% 332 degree strike aqnd 25% 242 degree strike,
    %based on approximate assesement of trends in the Southern California
    %catalog, with A 90 degree dip.
    %
    % Written by Karen Felzer, 2007.
    %Input:
    %
    % cat: Real eartquake catalog.  If the earthquake is classified as an
    %aftershock, there should be A non-zero value in column 12.  Otherwise this
    %column should contain all zeros.  Aftershock status can be calculated and
    %placed in Column 12 by the code GetAftFullParam.m
    %
    %RateGrid: Background rate, spatially varying.  minlon,maxlon, minlat,
    %maxlat, earthquake rate of M>=4.
    %
    %CX, P, A: Omori's law parameters, c, p, and A  They should be entered
    %as direct triggering parameters, with A recommended p = 1.37.  The value
    %of A should be appropriate for the rate of A mainshock of magnitude M
    %triggering aftershocks of magnitude >=M.  For Mmin = 2.5, we recommend CX = 0.095, P = 1.34, and
    %A = 0.008. (from Felzer and Kilb, in preparation, 2007).
    %
    % Mmin: Minimum earthquake magnitude to report and simulate
    % MminR: Minimum earthquake magnitude for reporting in the output catalog
    % maxm: Maximum earthquake magnitude
    % DMax: Maximum distance for aftershocks
    % EndDate: Last date for the simulated catalog, to be entered as A string
    %StartDate; First date for the projected catalog
    % (e.g. 'January 1, 2007').  The simulated catalog will begin immediately
    % after the last date in the input catalog cat.
    %
    %magb: Cutoff magnitude for the point source vs. plane source
    %representation of the mainshock
    %
    %FaultParam: Fault parameters for the M>magb earthquakes, listed in order
    %of their occurrence in the catalog.  Columns give fault length, width,
    %strike, dip, year, month, day.
    %
    %BckgrndR: Number of earthquakes/year above MinR that you want put in as
    %background.
    %
    %BckT: Earthquakes within BckT days of an M>=6.0 earthquake will be
    %not be used as base earthquakes for the placement of background activity.
    %In the future this should probably be replaced with something more
    %sophisticated.
    %
    %Output:
    %N: total number of earthquakes in the simulated catalog
    %MMax: Maximum magnitude in the simulated catalog
    %catalog: The simulated part of the catalog
    %
    %NOTE: At the present time no background rate is added into the catalog,
    %which means that the initial input cat should be as long as possible.
    %After testing forecast vs. real catalogs, A suitable background rate
    %option may be added in.  For now all of the background rate code from
    %TotalAftSim7.m is simply commented out.
    
    
    %Starting the program
    
    
    %set up
    
    N = zeros(1,1);
    Mmax = zeros(1,1);
    tdistAll = [];
    
    
    %Finding the time, in days, of the entire simulation
    
    StartDate = cat(1,1:6);
    
    %T = datenum(EndDate) - datenum(StartDate);
    
    T = datenum(EndDate) - datenum(StartDate);  %Gives longest time that aftershocks may be generated over; for simplicity all aftershocks will
    %be generated over this time and then be trimmed as needed.
    
    T3 = datenum(EndDate);   %Gives the end time of the simulation
    
    T2 = datenum(StartDateProj);  %The starting date of the projected catalog
    
    %And limiting the big earthquakes in FaultParam to before the beginning of
    %the simulation
    
    tp = datenum(FaultParam(:,5),FaultParam(:,6),FaultParam(:,7));
    xp = find(tp>T2 | tp<datenum(StartDate));
    FaultParam(xp,:) = [];
    
    
    %Finding the average number of aftershocks expected in time T for M - Maft
    %= 0.
    
    if(P ~= 0)
        
        NM = (A/(1-P))*((T+CX)^(1-P) - CX^(1-P));
        
    else
        
        NM = A*(log(T+CX) - log(CX));
    end
    
    
    %Eliminating earthquakes below the cutoff magnitude
    
    A = find(cat(:,10)<Mmin);
    
    cat(A,:) = [];
    
    %NM = (0.002/-0.37)*(T^-0.37 - 0.0033^-0.37);
    
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
    
    A = find(tdist>=T2);
    cat(A,:) = [];
    tdist(A) = [];
    m(A) = [];
    
    
    %And changing the lat, lon to xy
    
    catxy = cat;
    
    locCen(1) = mean(cat(:,7));
    locCen(2) = mean(cat(:,8));
    
    catxy(:,7:8) = latlon2xy2(catxy(:,7:8),locCen);
    
    
    Locs = [catxy(:,7) catxy(:,8) catxy(:,9)];
    
    %For earthquakes M>magb we also calculate the median location of the first
    %two days of earthquakes located within 20 km of the epicenter.  The output will be added as the first two colums
    %of the FaultParam vector.
    
    Mx = find(m>=magb);
    
    if(~isempty(Mx))
        
        for j=1:length(Mx)
            
            tdiff = tdist - tdist(Mx(j));
            
            diffLocsX = Locs(:,1) - Locs(Mx(j),1);
            diffLocsY = Locs(:,2) - Locs(Mx(j),2);
            
            
            aftx = find(tdiff>=0 & tdiff<2 & diffLocsX<=25 & diffLocsY<=25);
            
            %setting all of the depths at 10 km -- especially for the older
            %earthquakes the depths are unreliable.
            
            if(length(aftx)>20)  %We probably have A decent aftershock sequence and aren't being dominated by background
                LocsM(j,:) = [median(Locs(aftx,1)) median(Locs(aftx,2)) 10];
            else
                LocsM(j,:) = Locs(Mx(j),:);
                
            end
            
        end
        
        
        FaultParam = [LocsM FaultParam];
        
    end
    
    
    %And putting in some background earthquakes that are between T2 and T3
    %(past the start of the projection)
    
    %First making the part of the catalog that will be the base for the
    %background earthquake locations -
    
    %xx = find(tdist>=(T2 - 5*365.25));  %The last two years of data
    
    %if(BckgrndR>0)
    
    %LocsB = Locs;
    
    %am = find(m(xx)>=6.0);
    %tdistb = tdist(xx(am));
    %marker = zeros(size(tdist(xx)));
    
    %for j=1:length(tdistb)
    
    %    ll = find(tdist(xx)>tdistb(j) & tdist(xx)<=(tdistb(j)+BckT));
    %
    %    marker(ll) = 1;
    %end
    
    %ab = find(cat(:,12)>0);
    %LocsB(ab,:) = [];
    
    %NBack = ceil(BckgrndR*((T3-T2)/365.25));
    
    %NBack = poissrnd(NBack);  %putting in Poissonian randomness on the number
    
    %distB = GPowDistR(1.37,NBack,0.001,DMax);
    
    %ax = ceil(rand(NBack,1)*length(LocsB));  %chosing random catalog earthquakes to put at the center of the spatial distribution
    
    %theta = rand(length(distB),1).*2*pi;
    
    %   xnewB = distB.*cos(theta);
    %   ynewB = distB.*sin(theta);
    
    %locB = [LocsB(ax,1)+xnewB  LocsB(ax,2)+ynewB LocsB(ax,3)];
    
    
    B = sum(RateGrid(:,5))*((T3-T2)/364.25)*10^(4 - Mmin);  %Total number of background earthquakes
    
    NBack = poissinv(rand(1),B);  %putting in some Poissonian variability
    
    
    %Now getting the background earthquake locations
    
    latlon1 = [RateGrid(:,3) RateGrid(:,1)];
    latlon2 = [RateGrid(:,4) RateGrid(:,2)];
    
    xycoords1 = latlon2xy2(latlon1,locCen);
    xycoords2 = latlon2xy2(latlon2,locCen);
    
    RateGrid(:,1) = xycoords1(:,1);
    RateGrid(:,2) = xycoords2(:,1);
    RateGrid(:,3) = xycoords1(:,2);
    RateGrid(:,4) = xycoords2(:,2);
    
    %Then assigning earthquakes to each grid point based on relative rates.
    
    
    Px = RateGrid(:,5);
    
    Px = Px./sum(Px);  %Gives the probability of occurring in this location
    
    Px = cumsum(Px);
    
    r = rand(NBack,1);
    
    %tracker = ones(length(Px),1);
    
    
    %for i=1:length(Px)-1
    
    %   j = find(r>=Px(i) & r<Px(i+1));
    
    %  tracker(j) = i;
    
    
    %end
    
    for i=1:length(r)
        
        mxx = find(Px<=r(i));
        
        if(~isempty(mxx))
            tracker(i) = mxx(end);
        else
            tracker(i) = 1;
        end
    end
    
    %tracker = tracker(useC);
    
    %And doing some clean up
    A = find(r>=Px(end));
    tracker(A) = length(Px);
    A = find(r<Px(1));
    tracker(A) = 1;
    
    %And moving on
    
    xdiff = RateGrid(tracker,2) - RateGrid(tracker,1);
    ydiff = RateGrid(tracker,4) - RateGrid(tracker,3);
    
    
    R = rand(length(r),3);
    
    xd = R(:,1).*xdiff + RateGrid(tracker,1);
    yd = R(:,2).*ydiff + RateGrid(tracker,3);
    
    zd = R(:,3).*20;  %random depth between 0 and 20
    
    
    locB = [xd yd zd];
    
    
    tdistB = rand(NBack,1)*(T3-T2) + T2;
    
    tdistB = sort(tdistB);
    
    mB = GetMag(NBack,Mmin,maxm);
    
    ax = find(mB>=6.5);
    
    
    if(length(ax>0))
        
        FaultParamB = BuildFaultParam(mB(ax),locB(ax,:),lambda1,lambda2);
        
    else
        
        FaultParamB = [];
        
    end
    
    tdist = [tdist; tdistB];
    Locs = [Locs; locB];
    m = [m; mB];
    FaultParam = [FaultParam; FaultParamB];
    
    
    
    
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
    
    
    %And doing some final setting up for the ETAS run
    
    N = 0;
    Mmax = 0;
    
    %tdays = tdist(u);
    
    %tvect = datevec(tdays);
    
    %latlon = xy2latlon(Locs(u,1:2),locCen);
    
    lll = 'got here'
    
    ID = ID';
    History = History';
    FaultDist = FaultDist';
    
    %Now running the ETAS simulation***********%%%%%%%%%%%%
    
    %The loop gets all of the aftershocks of each earthquake occurring within
    %the specified duration of the catalog and over the minimum magnitude for
    %the simulation
    
    xm = find(m>=MminR);
    
    
    maxID = max(ID);
    
    %countAll = length(tdist(xm))+1;
    %tdistAll = tdist(xm);
    %IDAll = ID(xm);
    %HistoryAll = History(xm);
    %FaultDistAll = FaultDist(xm);
    %LocsAll = Locs(xm,:);
    %mAll = m(xm);
    
    countAll = length(tdistAll)+1;
    
    A = find(m>=Mmin & tdist<=T3);
    
    NIttr = 0;
    
    
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
        
        
        [tdist,m,Locs,ID,FaultDist] = GAft3(tdist(a2),maxID,ID(a2),m(a2),Mmin,maxm,NM,T,Locs(a2,:),DMax,P,CX);
        
        lll = 'got to point 2!'
        
        %And then doing the larger, plane source earthquakes
        
        a3 = find(mSave(A)>=magb);
        
        a3 = A(a3);
        
        if(~isempty(a3))
            
            if(NIttr>0)  %These are simulated large earthquakes which need FaultParam assigned.  Doing widths and lengths from Wells & Coppersmith
                
                FaultParam = BuildFaultParam(mSave(a3),LocsSave(a3,:),lambda1,lambda2);
            end
            
            %And getting the aftershocks for the big mainshocks
            
            [tdist2,m2,Locs2,ID2,History2,FaultDist2] = GAft4(tdistSave(a3),maxID,IDSave(a3),mSave(a3),Mmin,maxm,NM,T,LocsSave(a3,:),DMax,FaultParam,P,CX);
            
            
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
        History = [History; History2];
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
            
            %HistoryAll(countAll:countAll+length(aa2)-1,:) = History(aa2);
            
            FaultDistAll(countAll:countAll+length(aa2)-1,:) = FaultDist(aa2);
            
        end
        
        
        countAll = countAll+length(aa2);
        
        N = N + length(aa2);
        
        
        if(max(m(A))>Mmax)
            Mmax = max(m(A));
        end
        
        
        N
        Mmax
        
        NIttr = NIttr + 1;
        
    end
    
    
    %And translating the results into A traditional earthquake catalog
    
    tdays = datenum(StartDate) + tdistAll;
    
    tvect = datevec(tdistAll);
    
    latlon = xy2latlon(LocsAll(:,1:2),locCen);
    
    catalog = [tvect latlon LocsAll(:,3) mAll IDAll FaultDistAll];
    
    catalog = sortrows(catalog,[1 2 3 4 5 6]);
    
    %cat = gquakes(catalog,StartDate,EndDate);
    
    %At this point solving for the background rate, RateGrid, if it was
    %initially input as zero.
end

%--------------------------------------%%%

%Getting aftershock times, locations, and mags for point source mainshocks

function [tdist,m,Locs,ID,FaultDist] = GAft3(tdist,maxID,IDold,m,Mmin,maxm,NM,T,Locs,DMax,P,CX)
    
    
    %First getting the number of aftershocks produced by each mainshock; stored
    %in the vector A.
    
    A = NM.*10.^(m - Mmin);
    
    
    A = poissinv(rand(length(A),1),A);
    
    counter = 1;
    
    x = find(A>0);
    
    tnew2 = [];
    
    
    %Making A vector with all of the mainshock times and locations
    
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
        end
        
        
        AddDist = [lx' ly' lz'];
        
        
        %IN THIS VERSION: For each aftershock that will be produced, listing the
        %location of the mainshock that will produce it.
        
        %NOTE: COMMENTING THIS OUT RIGHT NOW TO SAVE TIME
        
        %for j = 1:length(tdist(x))
        
        
        %   idx = A(x(j));
        
        %   LocsT = [Locs(x(j),1)*ones(idx,1) Locs(x(j),2)*ones(idx,1) Locs(x(j),3)*ones(idx,1)];
        
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
        %History = [];
        FaultDist = [];
    end
    
    %And generating ID numbers for all of the aftershocks
    
    if(~isempty(x))
        
        ID = [maxID+1:1:maxID+AX+1];
    end
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
end
%--------------------------------------  %Getting fault parameters for
%simulated earthquakes

function FaultParam = BuildFaultParam(m,Loc,lambda1,lambda2);
    
    for(k=1:length(m));
        
        [FaultY,FaultZ] = WellsCopper(m(k),1);
        
        %Placing the hypocenter of each mainshock at A random point on the fault
        %plane, and then determining the y, z limits of the fault plane.
        
        posY = rand(length(FaultY),1).*FaultY;
        posZ = rand(length(FaultY),1).*FaultZ;
        
        YLow = Loc(k,2)-posY;
        ZLow = Loc(k,3)-posZ;
        
        if(ZLow<0)  %Don't want any faults in the air!
            ZLow = 0;
        end
        
        midpoint = [0 FaultY./2 FaultZ./2];
        
        %And determining fault strike
        
        rs = rand(1);
        if(rs<=0.75)
            rot = lambda1*[midpoint(:,1) midpoint(:,2)]';
            s = 332;
        else
            rot = lambda2*[midpoint(:,1) midpoint(:,2)]';
            s = 242;
        end
        rpx = rot(1,:)';
        rpy = rot(2,:)';
        
        midpoint(:,1:3) = [Loc(k,1)+rpx Loc(k,2)+rpy Loc(k,3)];
        
        
        FaultParam(k,1:10) = [midpoint FaultY FaultZ s 90 0 0 0];
        
    end
end





