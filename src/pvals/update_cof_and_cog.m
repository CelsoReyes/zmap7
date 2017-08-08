function update_cof_and_cog(pk, qp, ts, pc)
    % calculates the global variables cof and cog
    global cof cog
    cof=pk/qp;
    cog=cof*((ts+pc)^qp);
end
    