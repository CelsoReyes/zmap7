# How do I...

Examples of quick activities you might do often in Zmap

## Subset the catalog?

There are many ways to subset the catalog. Here are a few common ones:
* Subset by DATE:
    * __From the `catalog` menu__, choose `Edit Ranges...`. Then make modifications in the dialog box.
    * __From a plot__, where time is the X axis, right click on the data line, and choose `start here` or `end here` or possibly other options.

* Subset by MAGNITUDE
    * __From the `catalog` menu__, choose `Edit Ranges...`. Then make modifications in the dialog box.
    * __From the `FMD` plot__, right-click in the axes and choose `Cut catalog at Mc`

* Subset by DEPTH:
    * __From the `catalog` menu__, choose `Edit Ranges...`. Then make modifications in the dialog box.

* Subset by Position (eg. Lat/Lon):
    * __From the Main Map__, right click and choose one of the `Select events in...` options. If you wish the change to be permanent, you may then right click and `Crop to shape`.
    *__From the Main Map__, right click and choose `Crop to axes limits` to keep only events that are within the current axes limits.

* Subset by Anything:

    * __From the `catalog` menu__, choose export current catalog. 
        * As a `ZmapCatalog`, you can now make arbitrary modifications at the command prompt using `subset`.  Eg:
        ```matlab
        % catalog was exported as c
        c = c.subset(MagnitudeType == "ML")
        ```
        * then, reimport the catalog (under the catalog , choose `get/load catalog`->`From current MATLAB Workspace`), or open a new zmap window `ZmapMainWindow(c)`

