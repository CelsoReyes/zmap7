function [tau] = funTaucalc(xk,mbg,k1,xmeff,bgdiff,P)
% FUNTAUCALC calculate look ahead time for clustered events
%
% [tau] = FUNTAUCALC( xk,mbg,k1,xmeff,bgdiff,P)
%   xk  : factor used for xmeff
%   mbg : biggest magnitude in each cluster
%   k1  :
%   xmeff :
%   bgdiff
%   P : 
%
% A.Allmann


% global xk mbg xmeff k1 P
% global top denom deltam bgdiff


deltam = (1-xk)*mbg(k1)-xmeff;        %delta in magnitude
if deltam<0
 deltam=0;
end
denom  = 10^((deltam-1)*2/3);              %expected rate of aftershocks
top    = -log(1-P)*bgdiff;
tau    = top/denom;                        %equation out of Raesenberg paper

