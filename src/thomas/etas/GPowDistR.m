function r = GPowDistR(m,N,dmin,dmax)
    
    %Generate a distance distribution with N points following an inverse powerlaw
    % with exponent m, contained with the boundaries dmin and dmax.
    
    p = rand(N,1);
    
    %p = log(p);
    
    a1 = p.*(dmax^(1-m) - dmin^(1-m));
    
    r = (a1 + dmin^(1-m)).^(1/(1-m));
    
end

