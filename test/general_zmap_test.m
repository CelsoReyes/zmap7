%% script to test zmap 
% by putting it through its paces

close all
clear all

ONLINE = false;
DOPROFILE = true;
% start zmap
zmap -initonly

% let ZMAP know nobody is driving
ZG.Interactive = false;

%load a catalog from an old file
tmp = load('resrc/sample/sample_data_sed.mat','a');
c0=ZmapCatalog(tmp.a);

% load a catalog via the fdsn importer
[~, mycat] = ZmapImportManager(@import_fdsn_event,{FilterOp.importCatalog, 'resrc/sample/example_fdsn_events.txt'});

% load a catalog via the ascii importer
[~, c1] = ZmapImportManager(@ascii_imp,{FilterOp.importCatalog, 'resrc/sample/example_fdsn_events.txt'});

% load a catalog via the NDK importer
[~, c3] = ZmapImportManager(@import_ndk,{FilterOp.importCatalog, '~/Desktop/jan76_dec13.ndk'});

if ONLINE
    % load a catalog via a live fdsn service
    [~, mycat] = ZmapImportManager(@import_fdsn_event, {FilterOp.importCatalog,'SED','starttime','2010-01-01T00:00'});
end
% cut the catalog
c4 = c3.subset(c3.Longitude > 0 & c3.Longitude < 15);
c4 = c4.subset(c4.Latitude > 30 & c4.Latitude < 50);

%%
% create the zmap interactive window

tmp=load('resrc/sample/SED_fdsn_2000_on.mat');
mycat = tmp.catalog;
mycat.Name = "mycat";

zmw = ZmapMainWindow(mycat);

% create the default grid
gopt = GridOptions(ZG.GridOpts.SeparationProps, ZG.GridOpts.AnchorPoint);
zmw.Grid = ZmapGrid(ZG.GridOpts.Name, gopt);

sh = load_shape(fullfile(ZG.Directories.data,'switzerland_shape.csv'));
% the ZAP is a way to shuffle a bunch of relevant analysis data together:
% it combines the catalog, method of sampling, grid points, and shape.
ZAP = ZmapAnalysisPkg([],mycat, EventSelectionParameters.fromStruct(ZG.SamplingOpts), zmw.Grid, sh);

import XYfun.*
import XZfun.*
import XYZfun.*

itemsToTry = {...
    @bvalgrid, ...
    @bpvalgrid, ...
    @bvalmapt, ...
    @bdepth_ratio, ...
    @findquar,...
    @comp2periodz,...
    @rcvalgrid_a2...
    };

if DOPROFILE
    profile on;
end
for j=1:numel(itemsToTry)
    try
        obj = itemsToTry{j}(ZAP, 'InteractiveMode', false,'DelayProcessing',true);
        
        % display the function call used to duplicate results
        disp(obj.FunctionCall)
        obj.doIt();
        
    catch ME
        for j = 1:numel(ME.stack)
            if endsWith(ME.stack(j).file,'.m')
                warning('ZMAP:stackReport',STACK %d: %s [%s] : line %d', j, ME.stack(j).name,ME.stack(j).file, ME.stack(j).line);
            end
        end
        warning(ME.message);
    end
end

msg.dbdisp('Now Testing B values (bdiff)');
try
[allpassed, failMethods] = bdiff2.test(ZG.primeCatalog)
catch ME
    warning(ME.identifier, ME.message);
end


disp("DONE. DONE. DONE")

if DOPROFILE
    profile viewer;
end

%{
% prototype behavior
zmw.clickMenuItem("mc, a- and b- value map");
zmw.clickMenuItem(["Catalog" "Export current catalog..." "to workspace (Table)"]); %double-quotes! 
zmw.chooseTabContextItem('FMD', "copy contents to new figure (static)");
%}