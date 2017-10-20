classdef(Abstract) ZmapFunction < handle
    %ZmapFunction base class for functions in Zmap, providing a common interface
    %   expects that functions can be called from command prompt or menus
    %
    %  To use, first create a class that inherits from ZmapFunction and provides
    %  the following:
    %
    %   ZmapFunction Properties:
    %     OperatingCatalog - this are the catalog(s) that contain the raw data needed by this function
    %         ex.    OperatingCatalog={'primeCatalog'}; %must be cell
    %     ModifiedCatalog - this contains the catalogs (if any) that are modified by this routine.
    %
    %     define variables here that would be used in calculation
    %
    %   ZmapFunction Properties(Constant):
    %      PlotTag - string name used to access all items from the plot this creates. 
    % 
    %
    %   ZmapFunction Methods:
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
    %       CheckPreconditions - do checks to ensure incoming data & parameters meet requirements of the Calculate() method. 
    %       InteractiveSetup - create a ZmapFunctionDlg that provides the user a way to manipulate parameters used by the Calculate() method.
    %       Calculate - do the calculations, and put all important results into fields of the obj.Results variable.
    %         optionally return the Results so that the caller can directly manipulate them
    %
    %       plot - plot the results of this function
    %       ModifyGlobals - change ZmapGlobal.Data items here. If possible: ONLY here.
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
    % see also ZmapFunctionDlg, sample_ZmapFunction, blank_ZmapFunction, ZmapQuickResultPcolor
    
    properties
        % THESE ARE ACCESSIBLE BY ALL DERRIVED CLASSES
        Result % results of the calculation, stored in a struct
        ZG=ZmapGlobal.Data; % provides access to the ZMAP globally used variables.
        hPlot % tracks the plot(s) for each function
        ax=[]; % axis where plotting will go
        FunctionCall='%unknown function call';% text representation of the function call.
    end
    
    properties(Abstract)
        %THESE NEED TO BE DEFINED IN THE DERRIVED CLASSES' PROPERTIES SECTION
        % these properties MUST be defined in every class derived from ZmapFunction
        OperatingCatalog % cell containing variable names of catalog(s) containing raw data. (from ZmapGlobal)
        ModifiedCatalog % variable name of catalog that is modified (if not empty). 
    end
    
    properties(Constant,Abstract)
        % THIS NEEDS TO BE ASSIGNED A STRING IN THE DERRIVED CLASSES' CONSTANT PROPERTIES SECTION
        PlotTag % used for tracking the plot for each function
    end
    
    methods
        function set.FunctionCall(obj, varargin)
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
            obj.saveToDesktop();
        end
        
        function saveToDesktop(obj)
            vname=[class(obj),'_result'];
            assert(~isfield(obj.Result,'FunctionCall'), 'FunctionCall is a reserved field in the results');
            obj.Result.FunctionCall=obj.FunctionCall;
            if isprop(obj,'Grid')
                obj.Result.Grid = obj.Grid;
            end
            if isprop(obj,'EventSelector')
                obj.Result.EventSelector = obj.EventSelector;
            end
            obj.Result.InCatalogName=obj.OperatingCatalog;
            obj.Result.OutCatalogName=obj.ModifiedCatalog;
            assignin('base',vname,obj.Result);
            fprintf('%s  %% called by Zmap : %s\n',obj.FunctionCall, char(datetime));
            fprintf('%% results in: %s\n',vname);
        end
        
        function SetFunctionCall(obj, varargin)
            try
                % provides probable function call for CURRENT STATE of object
                fcall=[class(obj),'('];
                for i=1:numel(varargin)
                    fcall=[fcall char(string(obj.(varargin{i}))) ','];
                end
                if ~isempty(varargin)
                    fcall(end)=''; % replaces comma
                end
                fcall(end+1)=')';
            catch ME
                warning(ME.message)
                fcall=['% could not describe call. next comment is up to parse error, then generic call' linebreak...
                    '% ' fcall linebreak...
                    class(obj),'()'];
            end
            obj.FunctionCall=fcall;
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
    end
    
    methods(Abstract)
        % THESE NEED TO BE CREATED IN THE DERRIVED CLASSES' METHODS SECTION
        CheckPreconditions(obj); %ensure catalog(s) meets pre-conditions
        
        % these functions MUST be defined in every class derived from ZmapFunction
        InteractiveSetup(obj, autoCalculate, autoPlot);
        
        Results=Calculate(obj); % perform calculations, store results in obj.Result
        
        plot(obj,varargin); % plot 
        ModifyGlobals(obj); % modify zmapglobals, if desired
        
    end
    
    methods(Static, Abstract)
        % THIS NEEDS TO BE CREATED IN THE DERRIVED CLASSES' STATIC METHODS SECTION
        AddMenuItem(parent)
        %{ 
        sample implementaion here:
        function h=AddMenuItem(parent)
            % create a menu item that will be used to call this function/class
            h=uimenu(parent,'Label','testmenuitem',...    CHANGE THIS TO YOUR MENUNAME
                'Callback', @(~,~)blank_ZmapFunction()... CHANGE THIS TO YOUR CALLBACK
                );
        end
        %}
    end
end