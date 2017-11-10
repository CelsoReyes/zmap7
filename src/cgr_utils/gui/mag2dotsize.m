function sz = mag2dotsize(maglist)
    % mag2dotsize - given array of magnitudes, return marker sizes
    facm = 8 ./ max(maglist);
    sz = maglist .* facm;
    sz = ceil(max(1,sz) .^ 2.5);
end