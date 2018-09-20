Features are used for the map overlays
Each file contains at least the following two variables:
- data - structure (or table) containing at least the fields 'Latitude' and 'Longitude', for plotting.
         There will likely be additional fields, too.
         Often, data will be a vector, with Latitude and Longitude being
         vectors, too. This means to plot all, use square brackets:
         eg.  [data.Latitude] and [data.Longitude]
- metadata : describes the data contents and provides attribution.

C Reyes, 2017
