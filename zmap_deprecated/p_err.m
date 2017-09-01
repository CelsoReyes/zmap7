function perr = p_err(t, pc, pk, qp, tt, ts)
    %p_err calculate p error
    sumln=sum(log(t+pc));
    qsumln=pk/qp^2;
    qsumln=qsumln*(((tt+pc)^qp)*(1-qp*log(tt+pc))-((ts+pc)^qp)*(1-qp*log(ts+pc)));
    esumln=qsumln+sumln;
    perr=esumln;
end
