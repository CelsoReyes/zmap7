function [dTmin,dTmed1,dTmed2,dTmax]=ftselect(mCatalog)
% function [dTmin,dTmed1,dTmed2,dTmax]=ftselect(mCatalog);
% --------------------------------------------------------------------------------------
% Function to define two time periods of an earthquake catalog
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 27.06.02
%
% Incoming variable:
% mCatalog: earthquake catalog
%
% Outgoing variables:
% dTmin  : Start time first period
% dTmed1 : End time first period
% dTmed2 : Start time second period
% dTmax  : End time second period

% Default values of time periods
dTmin=min(mCatalog(:,3));
dTmax=max(mCatalog(:,3));
dTmed1=dTmin+ (dTmax-dTmin)/2;
dTmed2=dTmin+ (dTmax-dTmin)/2;

prompt  = {'Time T1','Time T2','Time T3','Time T4'};
title   = 'Input times';
lines= 1;
def     = {num2str(dTmin),num2str(dTmed1),num2str(dTmed2),num2str(dTmax)};
mTimes  = inputdlg(prompt,title,lines,def);

if isempty(mTimes)
    disp('Time periods not changed!')
else
    dTmin=str2double(mTimes(1));
    dTmed1=str2double(mTimes(2));
    dTmed2=str2double(mTimes(3));
    dTmax=str2double(mTimes(4));
end

