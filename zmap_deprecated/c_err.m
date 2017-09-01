function cerr = c_err(pk, pc, t, ts, tt, pp)
    %c_err calculate c error
    qsum=pk*((1/(tt+pc)^pp)-(1/(ts+pc)^pp));
    psum=sum(1./(t+pc));
    cerr=qsum+pp*psum;
end
