function writeDefaults(fn, st)
    s=jsonencode(st);
    s=jsonprettify(s);
    w=which('defaults.writeDefaults'); % should reference ME
    outf=strrep(w,'writeDefaults.m',[fn,'.json']);
    fid=fopen(outf,'w');
    fprintf(fid,'%s',s);
    fclose(fid);
end