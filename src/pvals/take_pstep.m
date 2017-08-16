function [pstep, pp] = take_pstep(MIN_PSTEP, pp, pstep, preverr, nit, err2)
    %function to calculate the parameters of p-value
    if isempty(MIN_PSTEP); return; end
    STEP_REDUCTIONFACTOR = 0.9;
    
    if nit>1
        %if error has changed sign,reduce the step size
        if ~same_sign(preverr,err2) &&  pstep>= MIN_PSTEP
            pstep=pstep * STEP_REDUCTIONFACTOR;
        end
    end
    
    pp = pp - pstep * sign(err2); % move closer to zero
end
