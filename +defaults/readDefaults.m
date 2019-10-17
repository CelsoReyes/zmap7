function s=readDefaults(fn)
    w=which('defaults.writeDefaults'); % should reference ME
    infile=strrep(w,'writeDefaults.m',[fn,'.json']);
    st=fileread(infile);  % if it doesn't exist, just let it error normally
    try
        s=jsondecode(st);
    catch ME
        msg = sprintf(['Error decoding the file [%s]. ' ...
            'Contents are as follows:\n start-->%s<--end'],fn,st);
        causeException = MException('MATLAB:jsondecode:decoderror',msg);
        ME = addCause(ME, causeException);
        rethrow(ME)
    end
        
end