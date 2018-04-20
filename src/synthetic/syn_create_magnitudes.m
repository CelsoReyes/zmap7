function [newCat] = syn_create_magnitudes(mCatalog, B, startMag, magStep)

    report_this_filefun();

    if isnumeric(mCatalog)
        %% do the old thing
    newCat = mCatalog;

    nEvents = length(mCatalog);

    % Gutenberg-Richter: log10(N)=A-B*M
    mags = [startMag:magStep:10];
    N = 10.^(log10(nEvents) - B*(mags-startMag));
    N = round(N);

    new = nan(nEvents,1)

    ct1=1;
    while N(ct1+1)~=0;
        ct1=ct1+1;
    end
    ctM=mags(ct1);
    count=0;
    ct=0;
    for I=startMag:magStep:ctM;
        ct=ct+1;
        if I~=ctM
            for sc=1:(N(ct)-N(ct+1));
                count=count+1;
                new(count)=I;
            end
        else
            count=count+1;
            new(count)=I;
        end
    end

    % Randomize
    rng('shuffle');
    l=rand(length(new),1);
    [ii, is] =sort(l);
    tmpo=new(is);

    newCat(:,6) = tmpo(1:nEvents);
    else
        %% do the new thing
        newCat = mCatalog;
        
        nEvents = newCat.Count; 
        
        % Gutenberg-Richter: log10(N)=A-B*M
    mags= startMag : magStep : 15;
    N = 10 .^ (log10(nEvents) - B*(mags - startMag)); %expected events per mag step
    % N=round(N);
    N=round(N / sum(N) * nEvents); % get distribution at this number
    
    N(1) = N(1) + (nEvents - sum(N)); % we might be off by an event or two due to rounding
    mags(N<1)=[];
    N(N<1) = [];
    
    newMags=zeros(nEvents,1);
    next=1;
    for i=1:numel(N)
        howmany=N(i);
        whichmag=mags(i);
        last= next + howmany -1;
        newMags(next:last) = whichmag;
        next=last+1;
    end
        
    newCat.Magnitude=newMags(randperm(nEvents));
        %{
        mags = startMag:magStep:10 ;
        N = 10.^(log10(nEvents) - B*(mags-startMag));
        N = round(N);
        
        new = nan(nEvents,1);
        
        ct1=1;
        while N(ct1+1)~=0
            ct1=ct1+1;
        end
        ctM=mags(ct1);
        count=0;
        ct=0;
        for I=startMag:magStep:ctM
            ct=ct+1;
            if I~=ctM
                for sc=1:(N(ct)-N(ct+1))
                    count=count+1;
                    new(count)=I;
                end
            else
                count=count+1;
                new(count)=I;
            end
        end
        
        % Randomize
        rng('shuffle');
        l=rand(length(new),1);
        [~, is] =sort(l);
        tmpo=new(is);
        
        newCat.Magnitude = tmpo(1:nEvents);
        %}
    end
end
