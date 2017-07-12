function out=load_borders(level)
    % load borders 
    % level: 'i'ntermediate, 'h'igh, 'f'ull
    tmp=load(fullfile('features',['borders_' level '.mat']), 'data', 'metadata');
    disp('Loading borders:');
    disp(tmp.metadata);
    out=tmp.data;
    for i=1:numel(tmp.data)
        out(i).Depth=zeros(size(tmp.data(i).Longitude));
    end
end