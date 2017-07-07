% Script: call_Omorifit.m
% -----------------------
% Script to input parameters for a modified Omori law fit and calculate fit to data
% Calculation is done in function plot_llkstest
% The function works on the catalog newt2!!!
% J.Woessner
% last update: 19.08.03

report_this_filefun(mfilename('fullpath'));
% Get input parameters
prompt  = {,'Enter length of learning period (days)','Enter number of bootstraps:'};
title   = 'Parameters ';
lines= 1;
if exist('time') &&  exist('bootloops')
    time = num2str(time);
    bootloops = num2str(bootloops);
    def     = {time,bootloops};
    answer  = inputdlg(prompt,title,lines,def);
    time = str2double(answer{1});
    timef = 1;
    bootloops = str2double(answer{2});

else
    def     = {'50','50'};
    answer  = inputdlg(prompt,title,lines,def);
    time = str2double(answer{1});
    timef = 1;
    bootloops = str2double(answer{2});
end

% maepi is the mainshock of sequence
plot_llkstest(newt2,time,timef,bootloops,maepi);
