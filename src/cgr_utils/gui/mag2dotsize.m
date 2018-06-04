function sz = mag2dotsize(maglist)
    % mag2dotsize - given array of magnitudes, return marker sizes
    if ~exist('maglist','var')
        sz=[];
        return
    end
    minmag = min(maglist);
    maxmag = max(maglist);
    %delta = maxmag - minmag
    if minmag <= 0
        maglist=maglist+abs(minmag)+1;
        maxmag=maxmag+abs(minmag)+1;
    end
    facm = 8 ./ maxmag;
    sz = maglist .* facm;
    sz = ceil(max(1,sz) .^ 2.5);
    %minsize=min(sz)
    %maxsize=max(sz)
end