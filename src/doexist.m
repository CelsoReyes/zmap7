% this file test if main mainfault etc exist
% if they don't, they are created and set to [];

report_this_filefun(mfilename('fullpath'));

if ~exist('main','var'); main = []; end
if ~exist('mainfault','var'); mainfaults = []; end
if ~exist('faults','var'); faults = []; end
if ~exist('coastline','var'); coastline = []; end
if ~exist('maex','var'); maex =[];maey = []; end
if ~exist('maix','var'); maix =[];maey = []; end
if ~exist('vo','var'); vo =[]; end

