function update_aa_bb_for_unknown_reasons(tt, ts, p, c)
    % this small section only updates the globals aa & bb... WITHOUT EXPLANATION!!
    % where p=pp, c=pc, dk=pk apparently
    % ripped out of ploop(3) by A.Allmann
    
    global tmp1 tmp2
    global aa bb dk
    
    f=(tt+c)^(1-p)-(ts+c)^(1-p);
    bb=(log10(f*dk/(1-p)))/(tmp1-tmp2);
    aa=bb*tmp1;
    end
