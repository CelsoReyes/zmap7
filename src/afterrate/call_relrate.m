% Script: call_relrate.m
% Script to call functions for determining rate changes in overall aftershock sequences
% Calculation is done in function calc_relrate
% The function works on the catalog newt2!!!
% J.Woessner
% last update: 03.07.03

% Get input parameters
prompt  = {'Enter forecast period (number of events):','Enter start time of learning period',...
    'Enter maximum time of learning period (days):','Enter timesteps (days):','Enter number of boostrap samples'};
title   = 'Parameters ';
lines= 1;
def     = {'50','1','100','5','50'};
answer  = inputdlg(prompt,title,lines,def);
step = str2double(answer{1});
mintime = str2double(answer{2});
maxtime = str2double(answer{3});
timestep = str2double(answer{4});
bootloops = str2double(answer{5});

[mRateChange] = calc_relrate(newt2,step,mintime,maxtime,timestep,bootloops);
