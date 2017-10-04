function out=load_faults()
    % load coast 
    % level: 'i'ntermediate, 'h'igh, 'f'ull
    tmp=load(fullfile('features','eurofaults.mat'), 'data', 'metadata');
    disp('Loading European faults:');
    disp(tmp.metadata);
    out=tmp.data;
    for i=1:numel(tmp.data)
        out(i).Depth=zeros(size(tmp.data(i).Longitude));
        % out(i).Name=out(i).SOURCENAME; %needs to be adjusted to match
    end
end