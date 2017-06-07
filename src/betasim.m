% needed input: sampsize and numpoint

rinc=1/(numpoint-1);

for simnum=1:100

    %  r=sort(rand(sampsize,1));
    r=sort(unifrnd(0,1,sampsize,1));

    r = 0:1/(sampsize-1):1;r = r';


    rmin=min(r);
    rmax=max(r);
    rdiff=(rmax-rmin);

    r_norm(:,1)=ceil((r(:,1)-rmin)/(rdiff*rinc));
    r_norm(1,1)=1;

    for ri=1:(numpoint-1)
        r_int(ri,1)= sum(r_norm(:,1)==ri);
    end
    r_int = r_int*0+345;
    %clear r ri r_norm;

    % r_norm consists of number of intervals eq's belong into
    % r_int consists of # eq's in each interval
    % 0-inc is interval 1, with upper included

    % variables r_int, rinc, rmin, rmax, rdiff and sampsize still active

    rcount=1;
    for ri=1:(numpoint-1)
        for rj=1:ri
            rdelta=rj*rinc;
            rZ(rcount,1)=(sum(r_int((ri-rj+1):ri,1))-sampsize*rdelta)/sqrt(sampsize*rdelta*(1-rdelta));
            rcount=rcount+1;
        end
    end

    clear ri rj r_int rdelta rdiff rmax rmin;

    % rZ carries all betas that are not NaNs

    simres(simnum,1)=mean(rZ((1:(rcount-2)),1));					% calculates mean of betas
    simres(simnum,2)=prctile(rZ((1:(rcount-2)),1),90);			% calculates upper boundary of betas
    simres(simnum,3)=prctile(rZ((1:(rcount-2)),1),10);			% calculates lower boundary of betas

    simnum=simnum+1;
    clear rZ rcount;

end

clear rinc;

simstat(1,1)=mean(simres(:,1));				% mean of means
simstat(1,2)=std(simres(:,1));				% standard deviation of means
simstat(2,1)=mean(simres(:,2));				% mean upper boundaries
simstat(2,2)=std(simres(:,2));				% standard deviation of upper boundaries
simstat(3,1)=mean(simres(:,3));				% mean of lower boundaries
simstat(3,2)=std(simres(:,3));				% standard deviation of lower boundaries

clear simres simnum;

simstat
