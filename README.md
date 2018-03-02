# Zmap version 7.0 Readme

## About
Zmap version 7.0 represents a major rework of Zmap.

## Getting Started
When you start Zmap you are presented with a welcome screen...
![WelcomeScreen](resources/img/welcome_2018216.png)
From here, you will first load a catalog (`data` menu), and then explore it.  Once a catalog is loaded, a summary of its contents will appear, and the buttons for `Edit Ranges` and `Explore` will become active.

* `Edit Ranges` will bring up a screen that allows you to specify which part of the catalog will be analyzed [see Loading Data](#Loading)

### Work flow
1. import data
1. (OPTIONAL) select a subset of data to work with
1. Select a Grid and a Grid sampling method
1. 


### Loading data
From the welcome screen, choose the `data` menu, where you will be presented with several options including:
* `Load Catalog (*.mat file)` : retreive a catalog saved into a matlab data file.  Some sample data can be found in zmap/resources/sample

* `FDSN web fetch` : retrieve a catalog from an FDSN web service

* `Import Catalog from other formatted file` : this contains mostly unmaintained functions to import from other sources.

Catalogs can also be imported from the `Catalog` menu on the main map interface.

Upon importing data you may be presented with another dialog box that allows you to further constrain your data.

![Catalog Overview](resources/img/catalog_overview_20180216.png)

Clicking on the `see distributions` button will show a few histograms that may help you decide where to set your parameters
![Catalog Overview With Distributions](resources/img/catoverview_dist_20180216.png)



## The Main interfaces

### Main Map Screen
Once a catalog is loaded, you will be presented with the Main Window.
![MainMapScreen](resources/img/ZmapMainWindow_20180216.png)
This is where most of the work will happen.  The screen is divided into several sections.  When first presented, all events will be hilighted, and the main map will take up the entirety of the left side of the window.

The plots on the right side of the screen will reflect statistics for the entire catalog.

#### map features
Several features are plotted on the map along with the earthquakes. Which ones are shown can be controlled from the `Map Options` menu.  From here, you an also choose whether to view the map in 3D or toggle its aspect ratio to more-or-less match the geographic region.

### Selecting data of interest

#### Select a region
Regions can be selected in a few ways. Start by right-clicking in the map. Several options related to regions will be presented including :
* `Set Polygon: Box` : select a rectangular region by clicking on two corners to define a box.
* `Set Polygon: Irregular Shape`: select a region by creating a polygon with the mouse.  Anything other than a "normal" click will close the polygon.
* `Set Circle` : Click and drag from the center of the circle out to some radius of interest.
* `Clear Shape` : deletes the shape. all events are once again active.

When any of the above choices have been made, only the events within the region (or _shape_) will be colored. All other events become grey dots.  The plots to the right will also change to reflect your selection.

While defining a circle, you'll see the radius.  This circle is an oval because the map is distorted at this latitude.
![Define a Circle - in progress](resources/img/circle_inprogress.png)

Once a shape is defined, then all other events fade into the background.
![Define a Circle - done](resources/img/circleselected.png)


#### Working with a region
Regions can be modified : scaled, dragged, points added, etc. by right-clicking on the shape itself.  Here are a list of current options (as of Feb 2017):
* `info...` provide basic information about this region and the shape that defines it.

* `Analyze EQ inside Shape`,  `Analyze EQ outside Shape`, and 
`Compare Inside vs Outside` : all bring up a cumulative time plot window, from
where further analysis is possible.

* `edit shape` : activates the shape, allowing it to be dragged, resized (via scrollwheel), and, for some shapes, have individual points added, moved, or removed.
Once you are done with the shape manipulations, select `Finished` from the same context menu. The changes will then be reflected in all the accompanying plots.

* additional options may appear, depending upon the chosen shape. For example,
a *circle* has:
  * `Choose Radius` : allowing you to define a specific radius by typing.
  * `Snap to N Events` : resizes the circle to encompass a specified number of events.

### Cross Sections

#### Selecting cross sections

One or more cross sections can be created. Cross sections are defined along
great-circle arcs, and therefore may not appear as straight lines on the map.
To create a cross section, choose `Define X-section` from the map's context menu (that is, right click on the map). A dialog box will appear to allow the user to choose a width, specify cross-section labels, or override the color. Simple Labels are automatically generated.
![Map with Cross Sections](resources/img/map_with_2p5xsec.png)

The primary map will then shrink to accomodate a cross-section plot that will
appear beneath the map.  In the above image, two cross sections were already made, and the third `C-C'` is in progress. 

Notice, information about these cross sections appear on the plots to the right, with colors that match the cross section.

#### Interacting with cross sections
Both the tabs and the cross-section plots are fully interactive.
Clicking on the tab for a cross-section provides the opportunity to see information about the cross section, or to change its width and color. 
The option `Examine this area` will change the shape to encompass the cross section.  Deleting the cross section from this menu will also remove it from the map.

Right-Clicking on the axes labels will allow the axes to be changed to any of the available data fields associated with a catalog.  Additionally, Right-clicking on the data will allow you to change the coloring and size schemes.

### Histogram Plots
The binning for these plots can be changed through the axes' context menu.

* `FMD` : frequency magnitude distribution plot. This plot reflects only the data within the selected region, and does not include cross-section specific details. Information contained in here can be further analyzed via the context menu.

### Cummulative plots
* `Cumplot` : show cumulative event count through time
* `Moment` : show cumulative moment through time
* `Time-Mag` : plot of magnitudes through time. (does not reflect cross-sections)
* `Time-Depth` : plot of depths through time (does not reflect cross-sections)

These plots can all be opened in another window, available for further analysis. To do so, right click on the data line of interest.  Additionally, the axes scaling for many plots can be toggled between linear and logarithmic.


# Other stuff

## Concepts


### Object Oriented design
Internally, Zmap has changed from a collection of scripts to
functions and classes.  Here, super briefly, is what these changes mean:
* __functions__ vs __scripts__: 
  * _scripts_ work on variables in the main workspace.  Everything one does may
  affect (intentionally or not) values used by other scripts.  Once the script
  is run, then the workspace is left in an altered state.  _#very script behaves
  as though the user was typing at the MATLAB command prompt_
  * _functions_ are routines that are self contained. They may take a list of
  arguments (input variables), create and modify a bunch of variables internally, and then return one or more results.  The behavior is well defined at the top
  of each function
* __classes__ : a class is a package of interrelated _functions_ (called _methods_)and _variables_ (called _properties_).  A good class will either represent one
thing, or accomplish one major goal.

### major classes
One can get more information about each class through the matlab help
system.  Using one of the help functions, such as  `help`, `doc`, `methods`

For example: 
```matlab
>> doc ZmapCatalog
```

This brings up an interactive browser where you can look at the classes'
properties (variables) and methods (functions).

#### ZmapCatalog
#### ZmapData
#### ZmapGlobal
#### ZmapGrid
#### MapFeature
MapFeatures are stored in ZmapGlobal.Data.features and can be looked up by name
```matlab
feat = ZmagGlobal.Data.features('borders');
f
feat.plot(ax);
```
#### ZmapFunction
#### ZmapGridFunction < ZmapFunction
#### ZmapFunctionDialog


#### testing


# modification notes for ZmapInABox

## (Super abbreviated) Summary of major changes from earlier versions of Zmap

* __Scripts are now Functions__: Previously, all routines were scripts that 
worked by modifying variables in the general workspace. Some of these were 
global.
* __Catalogs are no longer arrays__: Catalogs are now of type `ZmapCatalog`.
  * Catalogs now have named fields, such as _Longitude_, _Latitude_, _Date_,
  _Depth_,and _Magnitude_. This makes working with catalogs more intuitive, so in the code, for example, all depths can be accessed as `catalog.depth` instead of `catalog(:,7)`
  * Catalogs can now hold other types of data, such as `datetime`, `string`, and `cell` arrays as needs dictate.
* __dates__: Zmap now uses `datetime` instead of its older decimalyear format.
  * _decimal year_ would mean that time would compress or extend depending upon
  leap years. The conversions were complicated, and repeated throughout the code.
  * _datetime_ allows the use of more sophisticated (and more importantly, 
  matlab-handled) time representations.  The difference between two `datetime` 
  values is a `duration` value. These are excellent because units are built-in.
  There is no need to guess whether a value is in years, seconds, etc.
* __workspace variables__: The results of calculations are specifically 
written to the workspace, whereas previously every value regardless of significance
was written to the workspace.
* __global variables__: Some values are accessed throughout the Zmap program.
These are all kept in an object (variable) named ZmapGlobals. This:
  * keeps them in a coherently named space, 
  * allows the values to be saved together
* __Data import__: imported values will now be of type `ZmapCatalog`.
  * Data can now be imported over the web via FDSN services
* Data export
* __user interface__: the user interfacer has been overhauled in countless
ways.

### UI Controls not showing up
For `uicontrol` items, the `units` must be set to `normalized` prior to setting the `Position`, otherwise they will not show.  ex. `working_dir_in`
My solution, to avoid fixing 1000's of individual callbacks: set the system's defaultuicontrolunits to 'normalized'.

`set(0,'defaultuicontrolunits','normalized')`

There is some fluff around it to warn users. However any other defaults are not kept.

### eval
eval is (no longer/not) a recommended way to do things. Providing strings to be evaluated is generally considered unsafe, and circumvents any checking that MATLAB could do

In some cases, it was used prior to "try/catch".  What exists:

```matlab
do = ['risky_outcome = risky_function(''parameter'',value);']
err = ['disp(''oops'')']
eval(do,err);
```

which should all be converted to
```matlab
try
  risky_outcome = risky_function('parameter', value);
catch ME
  error_handler(ME,'oops');
end
```

### CallBack functions
Most callback functions are implemented as strings. Ideally they would be function calls instead.  The complications of determining the context makes editing these somewhat less-than straightforward.

## deprecated functions
Some functions are deprecated, or specific options are deprecated.  These need to be changed.

Some (non-exhaustive) somewhat straight-forward replacements
* rand('seed',...) -> rng('shuffle')  
* TBD

### strategies
For some functions, an *adapter* function will be used. This makes for very simple code substitution, especially when the function is in widespread use.

Example:
```matlab
[figexists, fignum] = figflag('title');
% figflag is deprecated
```

now, I created a function named `figure_exists.m` with the same basic functionality.  A global search-replace allowed me to nearluy instantaneously change these (194 occurances, spread throughout 163 files) to 

```matlab
[figexists, fignum] = figure_exists('title');
```

## shadowed functions
Functions which have the same name as provided matlab functions and serve the same purpose are renamed QUARENTINE_ .  eg. `ginput()`
Often the newer functions have different signatures, and shadowning produces some confusing errors.

## Celso supplied functions
`do_nothing` provides a function call that works as advertised.

`error_handler` provides a unified location to send those pesky **case** issues.  This can make tracking issues easier.
  Depending on the paramters, it could show the error, do nothing, or show some alternate text.

`figure_exists` provides a replacement for `figflag`
*the above is severely outdated*

## catalog / catalog views
you load data into a `ZmapCatalog`.  This is kept in `ZmapData.primeCatalog` (used to be 'a')
You filter it via `catalog_overview` , which yields `ZmapData.Views.primary` containing a `ZmapCatalogView`.   The `ZmapCatalogView` is the go-between between the catalog and the maps.  Changing the view ranges will leave the primary catalog intact.

A `ZmapCatalogView` can be attached either to a globally accessible `ZmapCatalog` or `ZmapCatalogView`.  

Layers within the plotting map are actually an array of `ZmapCatalogViews`, located in 
`ZmapData.Views.Layers`.  Ranges in these views can be changed, and they will affect
the data being displayed.  I would have liked to use `linkdata` to automatically update
the maps, but it appears to get bogged down very quickly as it is used.

When a polygon is created (circle or other shape), it can be used to further filter the
`ZmapCatalogView`.  the working catalog (either newt2 or newcat, I don't remember which)
is the current polygon applied to `ZmapData.Views.primary`

To get a `ZmapCatalog` from a `ZmapCatalogView` using the `ZmapCatalogView.Catalog` function.

## selections and grids

# other general things to tackle project-wide
* `lasterr` not recommended (88 results, 64 files) since 2009b
* `fileparts`, remove 4th output (versn) (6 results) [done] since 2010a
* `isstr` not recommended, use `ischar` (150 results, 68 files) [done] since 2010a [mapseis, too]
* `str2mat` replace with `char` (4 results, 2 files) [done] zmap
* `strread` replace usage with textscan. (97 results, 40 files) [in AddOneFiles] since 2010a
  * ex. [a,b,c]=strread(...) => C= textscan(...); [a,b,c] = deal(C{:}) since 2010a
* `strvcat` replace with char  (4 results, 3 files) [done] since 2010a
* `textread` replace with textscan as above, and use fopen/fclose.  (31results, 3 files) since 2010a
* `sprintf` - not necessary for error text (74 results in 14 files)
* `eval` - replace in favor of actually doing the thing (1567 results, 364 files) 
  * `eval(do[,err])` - replace with a try/catch (174 results, 82 files)
* `evalin` - ensure use makes sense (44 results, 14 files)
* `NaN` - be consistent about capitalization, and do not create matrix with ones()*nan or zeros(*nan)
* `NaN` - cannot compare with ==, use isnan() instead.  only a couple places [done]
* `error(nargchk...)` - replace with narginchk or nargoutchk [done] since 2011b
* `hdf_funs.m` - probably outdated. matlab has built-in version hdfread, hdfinfo
* error and warning message identifiers have changed since 2012b.  info at: http://www.mathworks.com/support/solutions/en/data/1-ERAFNC/?solution=1-ERAFNC -- see pdf
* `num2str` - for large integers, use int2str(x) instead. (manymany, but probably affects very few)
since 2013a
* `addParamValue` - replace with `addParameter` for an input parser.  [done] r2013b
* `flipdim` - replace with `flip` (45 in 19) [done] r2014a
* `bitmax` - replace with `flintmax` [done]
* `layout` gone.  no replacemnt, in 1 file.
* HitTest, Selected, and SelectionHighlight properties for several ui components shouldn't be used r2014a

* remove DateStr2Num, is no longer used anywhere. cursory test shows this causes a long delay.
* remove DateConvert. also unused

* remove MacMarone - doesn't seem to be used, and is likely an unneeded layer of abstraction.  Also.. requires compilation for system and has large disclaimer on web page (dated 2014).

* consider new storage options where it makes sense:  DateTime, table, timetable, timeseries, tscollection, containers.Map,  duration, categorical arrays (especially DateTime and Catagorical Arrays)

* provide help tooltips for menu items.  Perhaps functions could provide their own tooltip text
* provide description (and a REFERENCE!) for each function. 
* identify and prioritize Zmap functions for incorporation into MapSeis
* clearly define how to convert a script from Zmap into MapSeis -->automation tool?
* clearly define how functionality can be added to MapSeis

* investigate required actions (documentation? coding? examples?) to facilitate use of MapSeis / Zmap. How do I add functionality? How do I make a script that leverages this?

* assocArray() is not needed [EXCEPT FOR BACKWARDS COMPATIBILITY?] use containers.Map instead. (introduced matlab 2008b)

* remove "backup" files.  Let versioning system (git) take care of remembering past versions of stuff.

* **remember to keep zmap compatible with mapSeis**

# previous authors/contributors
*Stefan Wiemer ~ca 1994-1999
*Danijel Schorlemmer* ~ca 2003
*Jochen Woessner*
*Matt McDonnell* mapseis
*David Eberhard* mapseis (after Matt?)
*Carlos Adrian Vargas Aguillera* - cm_and_cb_utilities
*Peter J. Acklam*
*Denis Gilbert*
*Morris Maynard*
*Anders Brun*
*Elmar Tarajan*
*Deidre Byrne*
*Michael W Mann*
*Thomas van Stiphout*
*Elvis Chen*
*cpouillo*
*Jiancang Zhuang*
*Joaquim Luis* - wrote Mirone?
*R. A. Baker* '98
*Jan Simon* [matlab]
*Joseph Kirk*
*R Pawlowicz*
*D. L. Hallman*
*Bob Hamans*
*R Cobb* 11/94
*Quan Quach* 12/12/07
*A Kim*
*W Strumpf*
*E Byrns*
*L Job*
*E Brown*
*Annemarie*
*M Hendrix* - calendar2.m see matlab central
*D. Kroon*
*Doug Harriman*
*Brandon Kuczenski*
*Colin Humphries*
*Dave Mellinger*
*Gerry Middleton* '95
*T Debole*
*Takeshi Ikuma*
*Karaen Felzer* 2007
*Ramon Zuniga*
*Alexander Allmann*
*Guiseppe Cardillo*
*Dahua Lin* 2008
*A. M. Zoubir* 1998
*D R Iskander* 1998

# Adding Focal mechanisms
look at:
Focal Mechanisms:
https://ch.mathworks.com/matlabcentral/fileexchange/61227-focalmech-fm--centerx--centery--diam--varargin-

Moment tensors can be retrieved from places like:
http://www.isc.ac.uk/cgi-bin/web-db-v4?event_id=610635717&out_format=IMS1.0&request=COMPREHENSIVE
http://www.isc.ac.uk/iscbulletin/search/webservices/
and IRIS's SPUD
http://www.isc.ac.uk/iscbulletin/search/webservices/

# uncertainties, EVENT data

# completeness maps precalculated on the web
completenessweb.org

## ADDING FUNCTIONALITY
[Adding Functionality](ADDING_FUNCTIONALITY.md)