% Script: call_llforecast.m
% -----------------------
% Script to input parameters for an Omori law fit
% Calculation is done in function plot_fitloglike_a2
% The function works on the catalog newt2!!!
% J.Woessner
% last update: 10.07.03

report_this_filefun(mfilename('fullpath'));
% Get input parameters
prompt  = {,'Enter length of learning period (days)','Enter forecast period (days):','Enter number of bootstraps:'};
title   = 'Parameters ';
lines= 1;
def     = {'50','50','100'};
answer  = inputdlg(prompt,title,lines,def);
time = str2double(answer{1});
timef = str2double(answer{2});
bootloops = str2double(answer{3});

% maepi is the mainshock of sequence
plot_fitloglike_a2(newt2,time,timef,bootloops,maepi);
