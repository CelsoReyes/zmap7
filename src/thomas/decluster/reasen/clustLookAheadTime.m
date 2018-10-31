function [tau] = clustLookAheadTime(xk,biggest_mag,xmeff,bgdiff,P)
% CLUSTLOOKAHEAD calculate look ahead time for clustered events
%
% [tau] = CLUSTLOOKAHEAD( xk,biggest_mag,xmeff,bgdiff,P)
%   xk  : factor used for xmeff
%   mbg : biggest magnitude in ths cluster
%   xmeff :
%   bgdiff
%   P : 
%
% A.Allmann

deltam = (1-xk) * biggest_mag - xmeff;        %delta in magnitude

if deltam<0
    deltam=0;
end

denom  = 10^((deltam-1)*2/3);              %expected rate of aftershocks
top    = -log(1-P)*bgdiff;
tau    = top/denom;                        %equation out of Raesenberg paper

