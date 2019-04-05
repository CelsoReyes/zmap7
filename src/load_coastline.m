function out=load_coastline(level)
    % load coast 
    % level: 'i'ntermediate, 'h'igh, 'f'ull
    filename=fullfile('features',['continents_' level '.mat']);
    tic
    tmp=load(filename, 'data', 'metadata');
    toc
    disp('Loading coast:');
    disp(tmp.metadata);
    out=tmp.data;
    tic
    for i=1:numel(out)%tmp.data
        out(i).Depth=zeros(size(tmp.data(i).Longitude));
    end
    toc
end