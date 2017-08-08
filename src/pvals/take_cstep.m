function [cstep, pc, loop] = take_cstep(MIN_CSTEP, cstep, preverr, ts, pc, nit, err1, loop)
    if isempty(MIN_CSTEP); return; end
    
    STEP_REDUCTIONFACTOR = 0.9;
    
    if nit>1
        %if error has changed sign,reduce the step size
        if ~same_sign(preverr,err1)  &&  cstep >= MIN_CSTEP
            cstep=cstep * STEP_REDUCTIONFACTOR;
        end
    end
    
    pc = pc - cstep * sign(err1); % move closer to zero
    
    dt=ts+pc;
    if dt <= 0
        pc=ts+cstep;
    end
    if ~isempty(loop) && loop == 30
        cstep=cstep * STEP_REDUCTIONFACTOR;
        loop=0;
    end
    
end