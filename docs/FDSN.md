# Importing from [FDSN](https://www.fdsn.org "International Federation of Digital Seismograph Networks") web services


ZMAP is able to import catalog data from FDSN web services.  As of Sept 2018, ZMAP imports via text format, not [QuakeML](https://quake.ethz.ch/quakeml/).

![FDSN catalog menu](resrc/img/fdsn_catalog_menu.png)

You will be presented with a dialog window that allows you to further refine your query. 

![FDSN Import Dialog](resrc/img/fdsn_import_blank.png)

### Choose a provider from the drop-down

If a `catalog name` is not specified, then one will be automatically assigned, based on the provider name.  Once a catalog name is modified by the user, then it will not be updated unless the user types in something else.

When a provider is chosen, summary information about the provider will be displayed.

![SED provider](resrc/img/fdsn_provider.png)

> Providers are automatically retrieved from the [IRIS fedcatalog service](http://service.iris.edu/irisws/fedcatalog/1/datacenters).  However, not all datacenters are associated with the fedcatalog service, and may not appear in the list.  To manually add datacenters to the list, modify the [fdsnservices.json](resrc/fdsnservices.json) file using the existing services as a guide.
### Time constraints

All times are UTC. Valid formats are:

* `yyyy` assumes the start of the year (_i.e._ `2010` becomes `2010-01-01 00:00:00`)
* `yyyy-mm-dd` (_ex._ `2010-04-23` )
* `yyyy-mm-dd HH:MM:SS` (_ex._ `2010-04-23 12:59:59` )

### Magnitude Constraints

Not only can the magnitude range be specified, but you can specify the magnitude types as a comma-separated list.  For example, `M`,`ML`,`MS`.  However, be aware that this merely filters to the magnitude types provided by the service.. it does not attempt to convert existing magnitude types.

### Geographic Constraints

* #### None
  
  All events that meet Time, Magnitude, and Depth criteria will be retrieved

* #### Rectangular Seclection

  ![Rectangular Area selection](resrc/img/fdsn_rect.png)

  Technically, this is isn't rectangular... Specify the boundaries for events.

* #### Radial Selection

  ![Radial Area selection](resrc/img/fdsn_radial.png)

  Events can be requested within a specific radius of an origin point.
 
### Depth Constraints

Specify the event depth, in kilometers

## **Fetch**

There is no way to know how many events will be retrieved, nor how long the retrieval process will take, so _be patient_.

## Additional Links

[FDSN Web Services](https://www.fdsn.org/webservices) provides the specification for both the services and the data formats, as well as a list of data centers supporting FDSN Web services.  