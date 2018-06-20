function out=load_coastline(level)
    % load coast 
    % level: 'i'ntermediate, 'h'igh, 'f'ull
    tmp=load(fullfile('features',['continents_' level '.mat']), 'data', 'metadata');
    disp('Loading coast:');
    disp(tmp.metadata);
    out=tmp.data;
    for i=1:numel(tmp.data)
        out(i).Depth=zeros(size(tmp.data(i).Longitude));
    end
end