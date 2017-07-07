function [ev_val,mags,ev_valsum,ev_valsum_rev,mags_rev]=calc_cumulsum(mCatalog)
% function [ev_val,mags,ev_valsum,ev_valsum_rev,mags_rev]=calc_cumulsum(mCatalog)
% -----------------------------------------------------------------------
% Function to determine cumulative sums of an earthquake catalog
% Incoming variables:
% mCatalog: Current catalog or vector of magnitudes
%
% Outgoing variables:
% ev_val        : number of events in each bin
% ev_valsum     : cumulative sum in each bin for events of magnitude >= M
% ev_valsum_rev : cumulative sum in each bin for events of magnitude <=M
% mags          : magnitude steps for the bins in 0.1 steps starting at minimum magnitude
% mags_rev      : magnitude steps for the bins in 0.1 steps starting at maximum magnitude
%
% Author: J. Woessner, woessner@@seismo.ifg.ethz.ch
% last update: 09.10.02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END Header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nXSize, nYSize] = size(mCatalog);
if nXSize > 1
  % Use magnitude column from ZMAP data catalog format
  vMagnitude = mCatalog(:,6);
else
  % Use one column magnitude vector
  vMagnitude = mCatalog;
end

% Define shortcut variables for fast usage
magstep = 0.1;                      % Magnitude steps
maxmag=10;%maxmag = max(mCatalog(:,6));      % Maximum magnitude
mima=0; %mima = min(mCatalog(:,6));        % Minimum magnitude
if mima > 0 ; mima = 0 ; end

% number of mag units
nmagu = (maxmag*10)+1;
ev_val = zeros(1,nmagu);          % ev_val contains the number of events in each bin
ev_valsum = zeros(1,nmagu);       % ev_valsum is the cum. sum in each bin
ev_valsum_rev = zeros(1,nmagu);   % ev_valsum_rev is reverse order cum. sum

[ev_val,mags] = hist(vMagnitude,(mima:magstep:maxmag)); % mags is the step in magnitude for the bins ==.1
ev_valsum = cumsum(ev_val);                            % N for M <= : cumulative sum
ev_valsum_rev = cumsum(ev_val(length(ev_val):-1:1));   % N for M >= : cumulative sum (counted backwards)
mags_rev = (maxmag:-magstep:mima);                     % mags_rev is the step in magnitude for the bins == .1 in reverse order
