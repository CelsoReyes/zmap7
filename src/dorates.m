function [rates] =  bvalcalc(bw,aw,x,dx)

    % compute the annual rate of events at magnitude x given an a- and b-value

    nc1 = 10.^(aw - bw*(x-dx/2)) ;
    nc2 = 10.^(aw - bw*(x+dx/2)) ;
    rates = nc1 - nc2;



