function s=readDefaults(fn)
    w=which('defaults.writeDefaults'); % should reference ME
    inf=strrep(w,'writeDefaults.m',[fn,'.json']);
    st=fileread(inf);
    s=jsondecode(st);
end