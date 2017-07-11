function out=load_rivers(level)
    % load rivers 
    % level: 'i'ntermediate, 'h'igh, 'f'ull
    tmp=load(fullfile('features',['rivers_' level '.mat']), 'data', 'metadata');
    disp('Loading rivers:');
    disp(tmp.metadata);
    out=tmp.data;
    for i=1:numel(tmp.data)
        out(i).Depth=zeros(size(tmp.data(i).Longitude));
    end
end