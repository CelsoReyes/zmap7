function out=load_lakes(level)
    % load lakes 
    % level: 'i'ntermediate, 'h'igh, 'f'ull
    tmp=load(fullfile('features',['lakes_' level '.mat']), 'data', 'metadata');
    disp('Loading Lakes:');
    disp(tmp.metadata);
    out=tmp.data;
    for i=1:numel(tmp.data)
        out(i).Depth=zeros(size(tmp.data(i).Longitude));
    end
end