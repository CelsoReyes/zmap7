function val = edges2centers(bin_edges)
    % EDGES2CENTERS returns the centers of each bin
    % assumes a constant steps, returns a vector of length(bin_edges)-1
    %
    % see also CENTERS2EDGES, HISTCOUNTS, HISTOGRAM
    if isempty(bin_edges)
        val = [];
    else
        assert(numel(bin_edges) >= 2, 'expected edges')
        val = bin_edges(1:end-1) + (diff(bin_edges) ./ 2);
    end
end
    