function T = GPowDistRc(p,c,N,tmin,tmax)

%This function generates random points from the function (t+c)^-p, between
%tmin and tmax.  0 may be entered for tmin.

r = rand(N,1);


if(p~=1)

    a1 = (tmax + c)^(1-p);
    a2 = (tmin + c)^(1-p);
    a3 = r*a1 + (1-r)*a2;
    T = a3.^(1/(1-p)) - c;


else

    a1 = log(tmax+c);
    a2 = log(tmin + c);
    a3 = r*a1 + (1-r)*a2;
    T = exp(a3) - c;

end


