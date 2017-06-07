function [tdist,m,Locs,ID,History,FaultDist] = calc_Aftershock(tdist,maxID,IDold,m,Mmin,maxm,NM,T,Locs,DMax,P,CX)
% example:
% [tdist,m,Locs,ID,History,FaultDist] = calc_Aftershock(datenum(1980,01,02,00,00,00.00),1,1,3,2.5,6,0.05,1000,[0 0 0],100,1.34,0.095)
%Getting aftershock times, locations, and mags for point source mainshocks
%
%
% Variables:
% Input
% tdist:    time of events
% maxID:    maximal ID of background catalog
% IDold:    ID assigned to mainshock
% m:        magnitude of events
% Mmin:     minimal earthquake magnitude to report and simulate
% maxm:     maximal earthquake magnitude
% NM:       average number of aftershocks expected in time T for M-Maft= 0.
% T:        Time period for that aftershocks have to be computed
% Locs:     location in x, y, z [km]
% Dmax:     max distance of aftershock
% P  :      1.34   (parameter of omori-type aftershock)
% CX :      0.095  (parameter of omori-type aftershock)


%First getting the number of aftershocks produced by each mainshock; stored
%in the vector A.

A = NM.*10.^(m - Mmin);


A = poissinv(rand(length(A),1),A);

counter = 1;

x = find(A>0);

tnew2 = [];


%Making a vector with all of the mainshock times and locations

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

    %Summing the total number of aftershocks

    AX = sum(A);

    %Now getting distances of all of the aftershocks from the faults
    %Allowing a closest approach of 1 m.

    dnew = GPowDistR(1.37,AX,0.001,DMax);

    FaultDist = dnew;

    %Converting the distances into x, y using a random theta.
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

    m = calc_GetMag(length(tnew2),Mmin,maxm);

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
