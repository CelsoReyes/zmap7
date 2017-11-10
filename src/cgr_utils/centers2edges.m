function val = centers2edges(bin_centers)
    % EDGES2CENTERS returns the edges of each bin, assuming bins are same size as diff(centers)
    %
    % see also EDGES2CENTERS, HISTCOUNTS, HISTOGRAM
    if isempty(bin_centers)
        val = [];
    else
        assert(numel(bin_centers) >= 2, 'need at least 2 centers to determine bin size')
        delta = mean(diff(bin_centers));
        val = (bin_centers - delta/2);
        val(end+1) = bin_centers(end)+delta/2;
    end
end
    