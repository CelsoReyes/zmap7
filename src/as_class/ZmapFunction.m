classdef(Abstract) ZmapFunction < handle
    %ZmapFunction base class for functions in Zmap, providing a common interface
    %   expects that functions can be called from command prompt or menus
    %
    %  To use, first create a class that inherits from ZmapFunction and provides
    %  the following:
    %
    %
    %     define variables here that would be used in calculation
    %
    %   ZmapFunction Properties(Constant):
    %      PlotTag - string name used to access all items from the plot this creates.
    %
    %
    %   ZmapFunction Methods:
    %
    %       The following methods are RECOMMENDED, but do not need to be defined in your derrived
    %       class:
    %
    %       CheckPreconditions - do checks to ensure incoming data & parameters meet requirements of the Calculate() method.
    %       ModifyGlobals - change ZmapGlobal.Data items here. If possible: ONLY here.
    %
    %       The following methods MUST BE DEFINED.  They provide a
    %       coherent framework for this function's behaviors and to make it easy to
    %       control when this routine does things (IO, for example)
    %
    %       function obj=<name of this class/function>(varargin)
    %           % this is your function constructor that should behave so:
    %           % if varargin is empty, then do the interactive setup.
    %           % otherwise, check pronditions, calculate values, plot, and then modify globals.
    %
    %       InteractiveSetup - create a ZmapDialog that provides the user a way to manipulate parameters used by the Calculate() method.
    %
    %       Calculate - do the calculations, and put all important results into fields of the obj.Results variable.
    %         optionally return the Results so that the caller can directly manipulate them
    %
    %       plot - plot the results of this function
    %
    %  METHODS(Static)
    %       AddMenuItem - create a menu item that calls the constructor
    %
    %
    % TROUBLESHOOTING HELP.
    %    If not all methods have been created, then MATLAB will fail to create
    %    your function with a message "Abstract classes cannot be instantiated."
    %    that includes a clickable link.  Click it go get a list of methodes/properties
    %    that still need to be created.
    %
    %
    % see also ZmapDialog, sample_ZmapFunction, blank_ZmapFunction, ZmapQuickResultPcolor
    
    properties
        % THESE ARE ACCESSIBLE BY ALL DERRIVED CLASSES
        
         % holds complete catalog to be analyzed. defaults to the primary catalog
        RawCatalog ZmapCatalog {ZmapFunction.verify_catalog} = ZmapGlobal.Data.primeCatalog
        Result % results of the calculation, stored in a struct
        
        ZG = ZmapGlobal.Data; % provides access to the ZMAP globally used variables.
        hPlot % tracks the plot(s) for each function
        ax=[]; % axis where plotting will go
        FunctionCall char = '%unknown function call'; % text representation of the function call.
        
        % Grid, EventSelector, and Shape have been moved into the ZmapGridFunction
    end
    
    properties(Constant,Abstract)
        PlotTag % string used for tracking the plot for each function (assign in your function)
    end
    
    methods
        function obj=ZmapFunction(catalog)
            obj.RawCatalog=catalog;
        end
        function set.FunctionCall(obj, varargin)
            % FUNCTIONCALL provides probable function call for CURRENT STATE of object
            % obj.SETFUNCTIONCALL(varargin)
            if numel(varargin)==1 && iscell(varargin)
                varargin=varargin{:};
            end
            %try
            % provides probable function call for CURRENT STATE of object
            fcall=[class(obj),'('];
            for i=1:numel(varargin)
                fcall=[fcall char(string(obj.(varargin{i}))) ','];
            end
            if ~isempty(varargin)
                fcall(end)=''; % replaces comma
            end
            fcall(end+1)=')';
            %catch ME
            %warning(ME.message)
            %fcall=['% could not describe call. next comment is up to parse error, then generic call' newline...
            %    '% ' fcall, newline...
            %   class(obj),'()'];
            %end
            obj.FunctionCall=fcall;
        end
        
        function clearPlot(obj)
            % CLEARPLOT remove all plot items added by this function
            delete(obj.hPlot);
            obj.hPlot=[];
        end
        
        function doIt(obj)
            % DOIT called by the interactive dialog box once OK is pressed. 
            % Calls, in turn: CheckPreconditions, Calculate, plot, ModifyGlobals, saveToDesktop
            %
            % each of these functions is defined in the subclass.
            % change DOIT behavior by redefining DOIT in the sublcass.
            obj.CheckPreconditions();
            obj.Calculate();
            obj.plot();
            obj.ModifyGlobals();
            obj.saveToDesktop();
        end
        
        function CheckPreconditions(obj)
            % CHECKPRECONDITIONS ensure parameters meet pre-conditions (define in subclass)
            do_nothing(obj)
        end
        
        function  ModifyGlobals(obj)
            % MODIFYGLOBALS modify zmapglobals (define in subclass)
            % do any changing of zmap globals here
            do_nothing(obj)
        end
        
        function saveToDesktop(obj)
            % SAVETODESKTOP saves results to desktop
            vname=[class(obj),'_result'];
            assert(~isfield(obj.Result,'FunctionCall'), 'FunctionCall is a reserved field in the results');
            obj.Result.FunctionCall=obj.FunctionCall;
           
            obj.Result.InCatalogName=obj.RawCatalog.Name; %was OperatingCatalog
            assignin('base',vname,obj.Result);
            fprintf('%s  %% called by Zmap : %s\n',obj.FunctionCall, char(datetime));
            fprintf('%% results in: %s\n',vname);
        end
        
        function f=Figure(obj,option, menufun)
            % finds my figure, and will create if necessary
            % sets obj.ax to any/all axes in figure
            % option:
            %    'deleteaxes' : all axes for this figure be deleted
            %
            % if figure needs to be created, then menufun is called
            % menufun is a function handle
            if ~exist('option','var')
                option='';
            end
            
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
                if exist('menufun','var') && isa(menufun, 'function_handle')
                    menufun();
                end
            end
            
            figure(f);
            obj.ax=findobj(f,'Type','axes');
            switch option
                case 'deleteaxes'
                    delete(obj.ax);
                case ''
                otherwise
                    error('unknown');
            end
        end
    end % PUBLIC METHODS
    
    methods(Abstract)  % these functions MUST be defined in every class derived from ZmapFunction
        
        % INTERACTIVESETUP ask the user for additional parameters necessary for the calculation
        InteractiveSetup(obj);
        
        % CALCULATE perform calculations
        % obj.CALCULATE() store results in obj.Result  (obj.Result.values= results)
        % RESULTS = OBJ.CALCULATE() also, return results
        Results=Calculate(obj);
        
        % PLOT visually communicate results to the user
        %
        % obj.PLOT(varargin) plot results, passing along all parameters
        %
        % if plots can be generalized, such as xsection-plots, or map-view plots, then
        % sublcass ZmapFunction and define the plot in the subclass. Then, make your function
        % a subclass of THAT class. 
        %   For example: if this function computes values for a grid, and displays data as a 2D map
        %   then, create a class something like:
        % 
        %        classdef ZmapGridFunction < ZmapFunction
        %           %ZMAPGRIDFUNCTION calculates and plots functions that require a map grid.
        %           properties
        %              Grid % used to store the grid used in calculation
        %              ... % other useful properties
        %           end 
        %           methods
        %              function plot(obj, varargin)
        %                   % plot items on a grid
        %                   ...
        %              end
        %              
        %              ... % other required/useful methods
        %           end
        %        end
        %
        %   Then use THIS class to define your function
        %        classdef myawesomefunction < ZmapGridFunction
        %           %MYAWESOMEFUNCTION calculates dark-matter decoherence  at each point on the maps surface.
        %           properties
        %              ... % properties, specific to function
        %           end 
        %           methods
        %              function InteractiveSetup(obj)
        %                    ...
        %              end
        %              function Calculate(obj)
        %                   ...
        %              end
        %              ... % other required/useful methods
        %           end
        %           methods(Static)
        %              function AddMenuItem(obj, zapFcn)
        %                 ...
        %              end
        %        end
        %     
        plot(obj,varargin); % plot
        
    end %ABSTRACT METHODS
    
    methods(Static, Abstract)
        
        % create a menu item that will be used to call this function/class (Define this as a static member of your class)
        %    sample implementation here:
        %
        %    function h=AddMenuItem(parent,zapFcn)
        %        % ADDMENUITEM create a menu item that will be used to call this function/class
        %        % h = AddMenuItem(parent, zapFcn) creates a menu item under the container PARENT
        %        %     that will call this class/fuction.  ZAPFCN is a function_handle that, when
        %        %     called returns a ZmapAnalysisPkg containing all the state details used to
        %        %     process the data.
        %
        %       label = 'testmenuitem';                        % CHANGE THIS TO YOUR MENUNAME
        %       cb = @(~,~)sample_ZmapFunction(zapFcn());      % CHANGE THIS TO YOUR CALLBACK
        %       h=uimenu(parent,'Label',label,MenuSelectedFcnName(),cb);
        %    end
        %
        % you can copy/paste the above into your Static methods section
        AddMenuItem(parent, zapFcn)
        
    end % STATIC ABSTRACT METHODS
    
    methods(Static, Access=protected)
        function verify_catalog(c)
            % VERIFY_CATALOG makes sure the catalog is valid and has events
            % verify_catalog( CATALOG )
            assert(~isempty(c),'Catalog is empty');
            assert(isa(c,'ZmapCatalog'),'Please provide a ZmapCatalog, not a ',class(c));
        end
    end
end