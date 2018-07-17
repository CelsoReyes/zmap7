# Adding Functionality
Zmap 7.X has been rewritten with the goal of making it easy to edit and extend.
With minimal effort, you can write functions with rich functionality. 

By following some simple rules, your function can be more stable, flexible,
easier to edit, and _powerful_ . All, while allowing you
to write fewer lines of code.

## EXAMPLE: 
**Create a function that evaluates values for points on a 2D grid**

### What I want this function to do:
Choose a depth. For each point on a grid, I would like to know the average magnitude of events ABOVE and BELOW a chosen depth. Also, how many events occurred ABOVE and BELOW that level. The results should be interactive and plottable in map view.

Oh, and I want this function accessible from the main zmap map window.

#### In pseudocode, these core calculations would look something like
1. For depth `D`, XY grid `G`, area selection `A`, and sample radius `R`.
    * R can be a function of C and G.
1. for any catalog `C`:
    1. Crop `C` by `A`
    1. For each point `P` in `G`:
        1. Calculate `R` based on `C` and `P`
        1. Get subset of `Cr` based on `C`(`R`)  
        1. Split `Cr` into `Ctop` and `Cbot` along depth boundary `D`
        1. `Mtop` is average magnitude of `Ctop`
        1. `Mbot` is average magnitude of `Cbot`
        1. `Ntop` is number of events in `Ctop`
        1. `Nbot` is number of events in `Cbot`
        1. Add [`Mtop`,`Mbot`,`Ntop`,`Nbot`] to the return list
    1. Then, once all results are tallied, also calculate a ratio of `Mtop` : `Mbot`

### Define a "function" that knows how to work with a horizontal grid
```matlab
classdef simple_func < ZmapHGridFunction
   
end
```

when you try to "run" the function above, an error appears

`Abstract classes cannot be instantiated.  Class 'simple_func'
inherits abstract methods or properties but does not implement
them.  See the` **`list of methods and properties`** `that 'simple_func' must implement if you do not intend the class to be abstract.`

When you click on the emphasized portion of the message, you get a list
of the things you have to define (such as):

```
Abstract methods for class simple_func:
    Calculate       	% defined in ZmapFunction
    InteractiveSetup	% defined in ZmapFunction
    AddMenuItem     	% defined in ZmapFunction

Abstract properties for class simple_func:
    ReturnDetails	% defined in ZmapGridFunction
    CalcFields   	% defined in ZmapGridFunction
    PlotTag      	% defined in ZmapFunction
```

###  TL:DR Complete Function
This example shows the complete implementation for a function. 

```matlab
classdef simple_func < ZmapHGridFunction
    properties
        depth_km = 5 % default depth
    end
    
    properties(Constant)
        ReturnDetails= {... VariableNames, VariableDescriptions, VariableUnits
            'nEvents_top','number of events in top layer','';...
            'mean_mag_top','mean magnitude of events in top layer','mag';...
            'nEvents_bottom','number of events in bottom layer','';...
            'mean_mag_bottom','mean magnitude of events in bottom layer','mag';...
            'ratio','number of events in top to bottom',''...
            }
            
        % CalcFields is the label for each column coming out of the Calculate function
        % and should match items first column of ReturnDetails
        CalcFields = {'nEvents_top','mean_mag_top','nEvents_bottom','mean_mag_bottom'};
        
        PlotTag = 'my_simple_plot';
    end

    methods
        function obj=simple_func(zap, depth_in_km)
            obj@ZmapHGridFunction(zap, 'shallow_mag');
            if nargin < 2 
                obj.InteractiveSetup(); % ask for a depth interactively
            else
                obj.depth_km = depth_in_km;
                obj.do_It();
            end
        end
        
        function InteractiveSetup(obj)
            % ask your user for their details here
            % see also ZmapDialog
            
            % ZmapDialog allows you to create dialog boxes with minimal code
            zdlg = ZmapDialog();
            zdlg.AddBasicEdit('depth_km','Enter Depth [km]', depth, 'Enter depth for comparison');
            [res,okPressed] = zdlg.Create('b-Value Grid Parameters');
            
            if ~okPressed
                return
            end
            
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj,res)
            % all results are in a structure "res" that has fields matching the
            % first parameter of each item added to the ZmapDialog
            obj.depth_km = res.depth_km;
        end
        
        function results=Calculate(obj)
            % this is where the magic happens. The results of the calculation will be
            % stored in a obj.Result.values as a table.
            obj.gridCalculations(@calculation_function, @calc_additional_results);
            
            % stash values that are NOT grid dependent, but are good to know
            obj.Result.depth_km = obj.depth_km; 
            if nargout
                results=obj.Result.values;
            end
            
            function out=calculation_function(catalog)
                % this is called once per grid point.
                % The catalog has been determined based on this grid point and 
                % the event selection criteria.
                % because it is a sub-function of calculate, it has access to all 
                % of Calculate's variables.

                inTop=catalog.Depth >= obj.depth_km;
                meanTopMag = mean(catalog.Magnitude(inTop));
                meanBotMag = mean(catalog.Magnitude(~inTop));
                nTop = sum(inTop);
                nBot = sum(~inTop);
                out = [nTop meanTopMag nBot meanBotMag];
            end
            
            function rslt=calc_additional_results(rslt)
                % This is where you would add additional calculated values.
                % rslt will be a table with fields that match the first column
                % of ReturnDetails, plus some automatcally added fields
                rslt.ratio = rslt.nEvents_top / rslt.nEvents_bottom;
            end
        end
        
        
    end
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item that knows how to call this function
            % with all the required parameters such as grid, 
            % catalog, and event selection.

            label='Examine magnitudes above and below a level';
            h=uimenu(parent,'Label',label,'Callback', @(~,~)simple_func(zapFcn()));
        end
    end
end
```

### Yeah, but how do I "attach" this function to a menu?
For example, in the ZmapMainWindow.m, you might add this to its own menu like so:
```matlab
% ... somewhere that other menus are being created
submenu=uimenu('Label','MyCalculations');
simple_func.AddMenuItem(submenu, @()obj.map_zap);
```
done!

# Q&A
### **Q** : This seems like a lot of work to do to just get a few numbers...
**A** : The beauty in this approach is that the catalog used by your function is automatically shape (area) aware, the results are beautifully documented, and the values you calculate can be automatcially plotted interactively. 