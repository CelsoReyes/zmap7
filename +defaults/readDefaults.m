function s=readDefaults(fn)
    w=which('defaults.writeDefaults'); % should reference ME
    infile=strrep(w,'writeDefaults.m',[fn,'.json']);
    st=fileread(infile);
    s=jsondecode(st);
end