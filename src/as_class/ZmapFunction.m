classdef(Abstract) ZmapFunction < handle
    %ZmapFunction base class for functions in Zmap, providing a common interface
    %   expects that functions can be called from command prompt or menus
    %
    %  To use, first create a class that inherits from ZmapFunction and provides
    %  the following:
    %   PROPERTIES:
    %     OperatingCatalog - this are the catalog(s) that contain the raw data needed by this function
    %         ex.    OperatingCatalog={'a'}; %must be cell
    %     ModifiedCatalog - this contains the catalogs (if any) that are modified by this routine.
    %
    %     define variables here that would be used in calculation
    %
    %   PROPERTIES(Constant)
    %      PlotTag - string name used to access all items from the plot this creates. 
    % 
    %
    %   METHODS
    %       The following methods MUST BE DEFINED.  however, they do not necessarily
    %       have to "do" anything.  But they should.  They are defined to provide a
    %       coherent framework for this function's behaviors and to make it easy to
    %       control when this routine does things (IO, for example) 
    %      
    %
    %       function obj=<name of this class/function>(varargin)
    %           % this is your function constructor that should behave so:
    %           % if varargin is empty, then do the interactive setup.
    %           % otherwise, check pronditions, calculate values, plot, and then modify globals.
    %
    %       function CheckPreconditions(obj)
    %           % do any checks to ensure that the incoming data & parameters meet 
    %           % requirements of the Calculate() method.  
    %
    %       function InteractiveSetup(obj)
    %           % create a ZmapFunctionDlg that provides the user a way to manipulate
    %           % parameters used by the Calculate() method.
    %
    %       function Results=Calculate(obj)
    %           % do the calculations, and put all important results into fields of
    %           % the obj.Results variable.
    %           % optionally return the Results so that the caller can directly manipulate them
    %
    %       function plot(obj,varargin)
    %           % plot the results of this function
    %
    %       function ModifyGlobals(obj)
    %           % change ZmapGlobal.Data items here. If possible: ONLY here.
    %    
    %  METHODS(Static)
    %       function AddMenuItem(parent)
    %           % car
    %
    %
    % TROUBLESHOOTING HELP.
    %    If not all methods have been created, then MATLAB will fail to create
    %    your function with a message "Abstract classes cannot be instantiated."
    %    that includes a clickable link.  Click it go get a list of methodes/properties
    %    that still need to be created.
    %
    %
    % see also ZmapFunctionDlg, sample_ZmapFunction, blank_ZmapFunction
    
    properties
        % THESE ARE ACCESSIBLE BY ALL DERRIVED CLASSES
        Result % results of the calculation, stored in a struct
        ZG=ZmapGlobal.Data; % provides access to the ZMAP globally used variables.
        hPlot % tracks the plot(s) for each function
        ax=[]; % axis where plotting will go
    end
    
    properties(Abstract)
        %THESE NEED TO BE DEFINED IN THE DERRIVED CLASSES' PROPERTEIS SECTION
        % these properties MUST be defined in every class derived from ZmapFunction
        OperatingCatalog % cell containing variable names of catalog(s) containing raw data. (from ZmapGlobal)
        ModifiedCatalog % variable name of catalog that is modified (if not empty). 
    end
    
    properties(Constant,Abstract)
        % THIS NEEDS TO BE ASSIGNED A STRING IN THE DERRIVED CLASSES' CONSTANT PROPERTIES SECTION
        PlotTag % used for tracking the plot for each function
    end
    
    methods
        function c=getCat(obj,n)
            % get (one of) the input "global" catalogs
            if ~exist('n','var') || isempty(n)
                n=1;
            end
            if ~isempty(obj.OperatingCatalog)
                 c=obj.ZG.(obj.OperatingCatalog{n});
            else
                error('No operating catalog specified');
            end
        end
        
        function setCat(obj,mycat)
            % modify a "global" catalog
            if ~isempty(obj.ModifiedCatalog)
                obj.ZG.(obj.ModifiedCatalog)=mycat;
            else
                % no ModifiedCatalog was specifed
            end
        end
        
        function clearPlot(obj)
            % remove all plot items added by this function
            delete(obj.hPlot);
            obj.hPlot=[];
        end
        
        function doIt(obj) 
            % called by the interactive dialog box once OK is pressed.
            % each of these functions is defined in the child class.
            obj.CheckPreconditions();
            obj.Calculate();
            obj.plot();
            obj.ModifyGlobals();
        end
            
    end
    
    methods(Abstract)
        % THESE NEED TO BE CREATED IN THE DERRIVED CLASSES' METHODS SECTION
        CheckPreconditions(obj); %ensure catalog(s) meets pre-conditions
        
        % these functions MUST be defined in every class derived from ZmapFunction
        InteractiveSetup(obj, autoCalculate, autoPlot);
        
        Results=Calculate(obj); % perform calculations, store results in obj.Result
        
        plot(obj,varargin); % plot 
        ModifyGlobals(obj); %modify zmapglobals, if desired
        
    end
    
    methods(Static, Abstract)
        % THIS NEEDS TO BE CREATED IN THE DERRIVED CLASSES' STATIC METHODS SECTION
        AddMenuItem(parent)
        % menu_callback(src,evt)
    end
end