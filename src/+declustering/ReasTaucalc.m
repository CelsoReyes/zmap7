function [tau] = ReasTaucalc(xk,EqMag,xmeff,bgdiff,P)
	% routine to claculate the look ahead time for clustered events gives tau back
    %
    %   xk:    factor used in xmeff
    %   xmeff: "effective" lower magnitude cutoff for the catalog.
    %   bgdiff:  difference in time
    %   P :    confidence that you are observing the next event in  the sequence (default is 0.95)
    %
    
	%ORIGINAL FROM ZMAP: NEEDS WORK FOR MAPSEIS
	%SUBFUNCTION: ReasenbergDeclus.m MIGHT NOT BE NEEDED
	%---------------------------------------------------
	
	%Adopted for MapSeis (small changes)
	
	
	%tauclac.m                                         A.Allmann 
	
	
	deltam = (1-xk)*EqMag-xmeff;        %delta in magnitude
    if deltam<0
        deltam=0;
    end
	
	
	denom  = 10^((deltam-1)*2/3);              %expected rate of aftershocks
	top    = -log(1-P)*bgdiff;
	tau    = top/denom;                        %equation out of Raesenberg paper
 
end 