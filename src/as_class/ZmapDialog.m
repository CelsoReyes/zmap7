classdef ZmapDialog < handle
    % ZmapDialog Helper, used to generate dialog boxes while keeping code clean
    %
    % ZmapDialog properties:
    %
    %   WriteToObj          - handle to the caller. Values are written to WriteToObj.(tag) upon OK
    %   callerOKFunction - to be run once values are copied back to caller and dialog disappears
    %   hDialog          - handle to the dialog box
    %   okPressed        - true when the dialog box's OK button was pressed
    %
    % ZmapDialog methods:
    %
    %   ZmapDialog - initialize a ZmapDialog
    %   Create - creates a dialog box based on a cell description of types within.
    %
    %   AddCheckbox - add a checkbox (has ability to enable/disable other UI elements
    %   AddEdit - add an edit bow with text label
    %   AddHeader - add a simple header to the dialog box
    %   AddPopup - add a popup menu to the dialog box
    %   AddDurationEdit - add a duration editbox to dialog box.
    %   AddEventSelector - add widget to choose between events in a radius, or closest events
    %   AddGridSpacing - add a GridParameterChoice editgroup to edit box. 
    %  
    %   AddMcMethodDropdown       - 
    %   AddMcAutoEstimateCheckbox
    %
    %   addOKButton - (added automatically)
    %   addCancelButton - (added automatically)
    %
    %   cb_enableDependents - enables/disables fields based on checkbox
    %   clearDlg - callback for Cancel button
    %   okDlg - callback for OK button
    %   findDialogTag - returns handles for this object's dialog box that have a specific tag
    %
    %
    % can be called in 2 ways.
    % EXAMPLE USAGE IN A SCRIPT
    %
    %     zdlg = ZmapDialog();
    %     zdlg.AddHeader('Say something for each thing');
    %     zdlg.AddPopup('lifechoice','life choice',{'Eat','Drink','Be Merry'},2,...
    %         'Choose what is most important to you');
    %     zdlg.AddEdit('noiselevel','Noise level', 1,...
    %         'how much noise should?');
    %     zdlg.AddCheckbox('usenoise','use noise level', false,{'noiselevel','noiselevel_label'},...
    %         'Should noise be applied to the data?');
    %     zdlg.AddCheckbox('cleverness','be clever', false,[],...
    %         'if checked, then plot is cleverly drawn');
    %     esp = EventSelectionParameters('NumClosestEventsUpToRadius',100, 5)
    %      zdlg.AddEventSelector('evtparams', esp);
    %     [myans,okpressed] = zdlg.Create('Name', 'my example');
    %
    %         myans = 
    % 
    %       struct with fields:
    % 
    %         lifechoice: 2
    %               grid: [1×1 struct]
    %         noiselevel: 1
    %           usenoise: 0
    %         cleverness: 0
    %          evtparams: [1×1 struct]
    %
    %
    % EXAMPLE USAGE IN A CLASS
    % classdef myclass < ZmapFunction
    %   properties
    %     grid
    %     lifechoice
    %     noiselevel
    %     usenoise
    %     cleverness
    %   end
    %
    %   methods
    %     ...
    %   function interact(obj)
    %     zdlg = ZmapDialog(obj, @doit)
    %
    %     zdlg.AddHeader('Say something for each thing');
    %     zdlg.AddPopup('lifechoice','life choice',{'Eat','Drink','Be Merry'},2,...
    %                 'Choose what is most important to you');
    %     zdlg.AddGridSpacing('grid',0,'deg',3,'deg',5,'km');
    %     zdlg.AddEdit('noiselevel','Noise level', obj.noiselevel,...
    %                   'how much noise should?');
    %     zdlg.AddCheckbox('usenoise','use noise level', false,{'noiselevel','noiselevel_label'},...
    %                   'Should noise be applied to the data?');
    %     zdlg.AddCheckbox('cleverness','be clever', false,...
    %                   'if checked, then plot is cleverly drawn');
    %     esp = EventSelectionParameters('NumClosestEventsUpToRadius',100, 5)
    %     zdlg.AddEventSelector('evtparams', esp);
    %     zdlg.Create('Name', 'my dialog title');
    %
    %   end
    %
    %  function doit(obj)
    %       obj.Calculate();
    %       obj.plot();
    %  end
    %  end % methods
    
    properties
        % Values are written to WriteToObj.(tag) upon the user clicking 'OK'.  (prior to OkFcn).
        WriteToObj                                 
        
        % function to run when OK is pressed (no arguments). This is called AFTER dialog is deleted
        OkFcn               function_handle     = @do_nothing
        % function to run when Cancel is pressed (no arguments) called AFTER dialog is deleted
        CancelFcn           function_handle     = @do_nothing                
        callerOKFunction    function_handle     = @do_nothing  % to be run once values are copied back to caller and dialog disappears
        hDialog                                    % handle to the dialog box
        okPressed           logical             = false        % user pressed the OK button
        
        % control whether an old-style 'figure' will be created, or the newer 'uifigure'
        % TOFIX: 'uifigure' will trigger an error: "No method 'put' with matching signature found for class 'java.util.HashMap'."
        figureType      string  {mustBeMember(figureType,{'uifigure','figure'})}  = 'figure'
        
        OKbutton                                    % handle to the OK button
        CANCELbutton                                % handle to the CANCEL button
    end
    
    properties(Constant)
        %% placement of items within the dialog box
        
        buttonSpace     = 60    % space left at bottom of dialog for button placement
        rowH            = 35    % height of each control within a row
        
        dlgW            = 330   % width of entire dialog
        labelX          = 10    % start position of the label (for controls with labels)
        labelW          = 150   % width of label (for controls with labels)
        
        editX           = ZmapDialog.labelX + ZmapDialog.labelW + 20  % start position of edit boxes
        editW           = ZmapDialog.dlgW   - ZmapDialog.editX  - 15  % width of edit boxes
    end
    
    properties(Hidden)
        %% these one-off issues need to be reconsidered
        
        gridHeight                  = GridParameterChoice.GROUPHEIGHT 
        
        hasEvSel        logical     = false 
        didEvSel        logical     = false 
        evSelHeight                 = EventSelectionChoice.GROUPHEIGHT 
        curfig                      % figure handle to figure prior to call
        
    end
    
    properties(SetAccess=private)
        parts                       = struct([])    % ui details go in fields CreatorFcn, Tag, Style, Height, and Handle
        partIdx                     = 0             % current part, used when creating the dialog box
        
    end
    
    properties(Dependent)
        dlgH
        labelY
    end
   
    methods
        
        function h = get.dlgH(obj)
            % get overall dialog height
            if isempty(obj.parts)
                h = obj.buttonSpace;
            else
                h = sum([obj.parts.Height]) + obj.buttonSpace + obj.rowH;
            end
        end
        
        function y = get.labelY(obj) 
            % get y for current part
            y = obj.dlgH - obj.rowH - sum([obj.parts(1:obj.partIdx).Height]);
        end
        
        function h=PartHandle(obj, tag)
            % get the graphics handle for one of the controls
            h = obj.parts( {obj.parts.Tag} == string(tag)).Handle;
        end
        
        function obj=ZmapDialog(WriteToObj,okevent)
            % initialize a ZmapDialog
            % zdlg = ZmapDialog()
            % zdlg = ZmapDialog(NAME, VALUE [,...]) accepts pairs of inputs specifying additional
            % behavior
            %    Where NAME can be:
            %        'WriteHandle'
            %        'OkFcn' 
            %        'CancelFcn'
            %        'OkEvent'
            %        'CancelEvent'
            % zdlg = ZmapDialog('OkFcn', hOk)
            % zdlg = ZmapDialog('CancelFcn', hCancel)
            %
            % WriteToObj is the handle to the calling Function.
            % output values are returned to WriteToObj.(tag) for each uicontrol
            % once the OK button is pressed. if the OK button is not pressed, no changes are made
            % okevent (a function handle) will be executed if OK is pressed
            
            if ~exist('WriteToObj','var') || isempty(WriteToObj)
                obj.WriteToObj=struct();
            else
                obj.WriteToObj=WriteToObj;
            end
            
            if exist('okevent','var')
                obj.callerOKFunction=okevent;
            else
                if ishandle(obj.WriteToObj)
                    obj.callerOKFunction=@(src,~) fprintf('ZmapFunctionDialog: no OK function was specified for the %s object, so it will not be notified\n',class(obj.WriteToObj));
                end
            end
        end
        
        function [results,okPressed]=Create(obj, varargin)
            % Create creates a dialog box based on a cell description of types within.
            % [results,okPressed]=Create(obj, 'Name', dlgTitle)
            % ... Create(obj, ...,'Style','figure') % or uifigure
            % ... Create(obj, ...,'CreatedFcn', fnHandle) where DialogCreatedFcn is a function to execute
            %        'OkFcn' 
            %        'CancelFcn'
            %    after figure has been created
            %
            %        'WriteHandle'
            %        'OkFcn' 
            %        'CancelFcn'
            
            mustBeFunctionHandle = @(x) isa(x,'function_handle');
            p = inputParser();
            p.addParameter('Name',              'Parameter Dialog');
            p.addParameter('Style',             obj.figureType) 
            p.addParameter('DialogCreatedFcn',  @do_nothing, mustBeFunctionHandle);
            p.addParameter('OkFcn',             @do_nothing, mustBeFunctionHandle);
            p.addParameter('CancelFcn',         @do_nothing, mustBeFunctionHandle);
            p.addParameter('WriteToObj',        struct());
            p.parse(varargin{:});
           
            obj.figureType          = p.Results.Style;
            obj.OkFcn               = p.Results.OkFcn;
            obj.CancelFcn           = p.Results.CancelFcn;
            obj.WriteToObj          = p.Results.WriteToObj;
            dialogCreatedFcn        = p.Results.DialogCreatedFcn;
            dlgName                 = p.Results.Name;
            
            
            obj.curfig              = get(groot,'CurrentFigure');
            obj.okPressed           = false;
            assert(~isempty(obj.parts),'An empty Dialog cannot be created');
            
            if obj.figureType == "uifigure"
                myStyle = 'NewStyle';
            else
                myStyle = 'OldStyle';
            end
            
            setOnCompletion={}; % uicontrols that require further setting after all items created
            
            switch myStyle
                case 'OldStyle'
                    obj.hDialog=figure('Name',dlgName,...
                        'MenuBar', 'none',...
                        'InnerPosition', position_in_current_monitor(obj.dlgW , obj.dlgH),...
                        'NumberTitle','off'...
                        );
                case 'NewStyle'
                    obj.hDialog=uifigure('Name',dlgName,...
                        'MenuBar', 'none',...
                        'InnerPosition', position_in_current_monitor(obj.dlgW , obj.dlgH)...
                        );
            end
            drawnow nocallbacks;
            for i = 1 : numel(obj.parts)
                obj.partIdx = i;
                details=obj.parts(obj.partIdx);
                switch lower(details.Style)
                    case 'checkbox'
                        obj.parts(obj.partIdx).Handle = details.CreatorFcn.(myStyle)();
                        
                        if obj.figureType == "uifigure"
                            if ~isempty(obj.parts(obj.partIdx).Handle.ValueChangedFcn)
                                setOnCompletion=[setOnCompletion; {details.Tag}];
                            end
                        else
                            if ~isempty(obj.parts(obj.partIdx).Handle.Callback)
                                setOnCompletion=[setOnCompletion; {details.Tag}];
                            end
                        end
                    otherwise
                        try
                            obj.parts(obj.partIdx).Handle = details.CreatorFcn.(myStyle)();
                        catch ME
                            msg.dbdisp(obj.parts(obj.partIdx),'Error instantiating dialog box part:');
                            rethrow(ME);
                        end
                end
            end
            obj.addCancelButton([obj.dlgW-80 10 70 obj.buttonSpace/2]);
            obj.addOKButton([obj.dlgW-160 10 70 obj.buttonSpace/2]);
            drawnow nocallbacks
            
            % checkboxes may have callbacks that affect other uicontrols' Enable status.
            % now that all uicontrols have been created, disable/enable as dictated by the
            % checkbox state
            
            for n=1:numel(setOnCompletion)
                src=obj.findDlgTag(setOnCompletion{n});
                
                if obj.figureType == "uifigure"
                    src.ValueChangedFcn(src, []);
                else
                    src.Callback(src,[]);
                end
            end
            
            results=[];
            
            % call a provided function, now that the dialog has been created
            dialogCreatedFcn();
            
            % if we are expecting an answer, wait until dialog is finished.
            if nargout > 0
                uiwait(obj.hDialog)
                if isstruct(obj.WriteToObj)
                    results=obj.WriteToObj;
                end
                
                if isvalid(obj.curfig)
                    set(groot,'CurrentFigure',obj.curfig);
                end
                
            end
            okPressed = obj.okPressed;
        end
        
        %% methods to declare uicontrols
        
        %{
        function AddRadioGroup(obj, tag, grouplabel, radiolabels, default, tooltips, conversion_function)
            % AddRadioGroup returns Tag of selected radio buttion in the group
            % ADDRADIOGROUP(obj, tag, grouplabel, radiolabels, default tooltips)
            % ADDRADIOGROUP(..., conversionFcn)
            % 
            % FIXME: implementing this would require that heights be reconsidered.
            
            if ~exist('conversion_function','var') || isempty(conversion_function)
                conversion_function = @(x)x;
            elseif ischarlike(conversion_function)
                conversion_function = str2func(conversion_function);
            end
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style            = 'radiogroup';
            obj.parts(idx).CreatorFcn       =  @createRadioGroup;
            obj.parts(idx).ConversionFcn    =  @(h)conversion_function(h.SelectedObject.Tag);
            obj.parts(idx).Tag              = tag;
            
            function h = createRadioGroup()
                n=numel(radiolabels);
                h = uibuttongroup('Title',grouplabel, 'Tag', tag,...
                    ...'Visible','off',...
                    'Units','pixels','Position',...
                    [obj.labelX obj.labelY obj.dlgW - 2*obj.labelX (obj.rowH-10) .* (n+1)]);
                vspace = 1/n;
                for k=1:numel(radiolabels)
                    ip = vspace * k - (vspace/3);
                    hh(k)=uicontrol('Style','Radio',...
                        'String',radiolabels{k},...
                        'Parent',h,...
                        'ToolTipString',tooltips{k});
                    hh(k).Units='normalized';
                    hh(k).Position(2) = 1-ip;
                    hh(k).Position(3) = .9;
                end
                h.SelectedObject = hh(default);
                h.Visible = 'on';
            end
        end
        %} 
        
        function AddHeader(obj, String, varargin)
            % add a simple header to the dialog box
            % ADDHEADER(text)
            % ADDHEADER(text, [Name, value]...) sets additional text parameters.
            %  Name can be something like 'FontSize', 'FontWeight', etc.
            
            if ~ischar(String)
                String = char(String);
            end

            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'header';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createHeader;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createUIheader;
            obj.parts(idx).Height       = obj.rowH;
            obj.parts(idx).Tag          = '';
            
            function h = createHeader()
                h = uicontrol('Style','text',...
                    'String', [String, ' : '],...
                    'FontWeight', 'bold',...
                    'Position', [obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10]);
                if ~isempty(varargin)
                    set(h,varargin{:});
                end
            end
            
            function h = createUIheader()
                h = uilabel('Parent',obj.hDialog,...
                    'Text',String,...
                    'FontWeight', 'bold', ...
                    'Position', [obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10]);
                if ~isempty(varargin)
                    set(h, varargin{:});
                end
            end
        end
        
        function AddDivider(obj, varargin)
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'divider';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createDivider;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createDivider;
            obj.parts(idx).Height       = obj.rowH;
            obj.parts(idx).Tag          = '';
            
            function h = createDivider()
                h = uipanel('Units','pixels',...
                    'Position', [obj.labelX obj.labelY obj.dlgW-obj.labelX - 10 3]);
                if ~isempty(varargin)
                    set(h,varargin{:});
                end
            end
        end
            
        function AddPopup(obj,tag, label, choices, defaultChoice, tooltip, conversion_function)
            %AddPopup represents a pop-up menu
            % AddPopup(obj,tag, label, choices, defaultChoice,tooltip)
            %
            % after the tooltip you can add (only) ONE of the following optional parameters:
            %
            % AddPopup(..., conversionFcn) where CONVERSIONFCN is a function that takes the 
            %      value (a number from 1 to the number of choices), representing the chosen value, 
            %      and returns something else.
            %
            % AddPopup(..., alternateValues)  where ALTERNATEVALUES is a CELL of values.
            %      ALTERNATEVALUES{chosenvalue} will be returned
            
            if islogical(defaultChoice)
                assert(numel(defaultChoice)==numel(choices))
                assert(sum(defaultChoice)==1)
                defaultChoice = find(defaultChoice);
            end

            if exist('conversion_function','var') && (iscell(conversion_function) && numel(conversion_function) == numel(choices))
                alternateValues = conversion_function;
                conversion_function = @(h) h.UserData{h.Value};
            else
                alternateValues = [];
            end
            
            if ~exist('conversion_function','var') || isempty(conversion_function)
                conversion_function = @(x)x;
                conversion_function = @(h)conversion_function(h.Value);
            elseif ischarlike(conversion_function)
                conversion_function = str2func(conversion_function);
                conversion_function = @(h)conversion_function(h.Value);
            end
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style            = 'popupmenu';
            obj.parts(idx).CreatorFcn.OldStyle      = @createPopup;
            obj.parts(idx).CreatorFcn.NewStyle      = @createUIdropdown;
            obj.parts(idx).ConversionFcn.figure     = conversion_function;
            obj.parts(idx).ConversionFcn.uifigure   = @(x)x.Value;
            obj.parts(idx).Height                   = obj.rowH;
            obj.parts(idx).Tag                      = tag;
            
            function h = createPopup()
                % expectes an index into the choices
                if ~isnumeric(defaultChoice)
                    defaultChoice = find(string(defaultChoice) == choices);
                end
                assert(defaultChoice <= numel(choices) && defaultChoice > 0,'%d out of %d choices',defaultChoice,choices)
                % label for popup
                uicontrol('Style','text',...
                    'String',[label, ' : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW-50 obj.rowH-10],...
                    'Tag',[tag '_label']);
                % popup box
                h = uicontrol('Style','popupmenu',...
                    'Value',defaultChoice,...
                    'String',choices,...
                    'Callback',[],...
                    'Tag',tag,...
                    'ToolTipString',tooltip,...
                    'UserData', alternateValues,...
                    'Position',[obj.editX-50 obj.labelY obj.editW+50 obj.rowH-10]);
            end
            
            function h = createUIdropdown()
                % expects a member of Items
                if isnumeric(defaultChoice)
                    assert(defaultChoice <= numel(choices) && defaultChoice > 0,'%d out of %d choices',defaultChoice,choices)
                    defaultChoice = choices{defaultChoice};
                end
                
                % label for dropdown
                uilabel('Parent',obj.hDialog,...
                    'Text',[label,' : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW-50 obj.rowH-10],...
                    'Tag',[tag '_label']);
                
                % dropdown
                h = uidropdown('Parent',obj.hDialog,...
                    'Items',choices,...
                    'Value', defaultChoice,...
                    'ValueChangedFcn', [],...
                    'Position',[obj.editX-50 obj.labelY obj.editW+50 obj.rowH-10]);
                if ~isempty(alternateValues)
                    h.ItemsData = alternateValues;
                end
            end
                    
                    
                
        end
        
        function AddDurationEdit(obj,tag, label, value, tooltip, conversion_function)
            % AddDurationEdit adds an edit-box & text label combo
            % AddDurationEdit(obj,tag, label, value,tooltip, conversion_function)
            % where conversion_function is usually one of @years, @days, @hours, @minutes, @seconds
            
            if isduration(value)
                value = conversion_function(value);
            end
            assert(isnumeric(value));
            
            if ~exist('conversion_function','var') || isempty(conversion_function)
                % conversion_function = callback;
                conversion_function = str2func(class(value));
            elseif ischarlike(conversion_function)
                conversion_function = str2func(conversion_function);
            end
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'durationedit';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createEdit;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createUIedit;
            obj.parts(idx).ConversionFcn.figure = @(h)conversion_function(double(string(h.String)));
            obj.parts(idx).ConversionFcn.uifigure = @(h)conversion_function(double(string(h.Value)));
            obj.parts(idx).Height       = obj.rowH;
            obj.parts(idx).Tag          = tag;
            
            function h = createEdit()
                uicontrol('Style','text',...
                    'String',[label, ' [',func2str(conversion_function), '] : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW obj.rowH-10],...
                    'ToolTipString',tooltip,...
                    'Tag',[tag '_label']);
                
                h = uicontrol('Style','edit',...
                    'String',string(value),...
                    'Tag',tag,...
                    'ToolTipString',tooltip,...
                    'Position',[obj.editX obj.labelY obj.editW obj.rowH-10]);
            end
            
            function h = createUIedit
                uilabel('Parent',obj.hDialog,...
                    'Text', [label, ' [',func2str(conversion_function), '] : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW obj.rowH-10],...
                    'Tag',[tag '_label']);
                
                h = uieditfield('Parent',obj.hDialog,...
                    'Value',string(value),...
                    'Tag',tag,...
                    'Position',[obj.editX obj.labelY obj.editW obj.rowH-10]);
                
            end
         end
        
        function AddEdit(obj,tag, label, value, tooltip, conversion_function)
            % AddEdit adds an edit-box & text label combo
            % AddEdit(obj,tag, label, value,tooltip)
            % AddEdit(..., conversion_function)
            
            assert(~isduration(value),'Use AddDurationEdit for durations');
            if ~exist('conversion_function','var') || isempty(conversion_function)
                % conversion_function = callback;
                if isnumeric(value)
                    conversion_function = @(v)double(string(v));
                elseif isdatetime(value)
                    conversion_function = @(v)datetime(v); % could be: 'InputFormat','uuuu-MM-dd HH:mm:ss'
                else
                    conversion_function = str2func(class(value));
                end
            elseif ischarlike(conversion_function)
                conversion_function = str2func(conversion_function);
            end
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'edit';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createEdit;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createUIedit;
            obj.parts(idx).ConversionFcn.figure = @(h)conversion_function(h.String);
            obj.parts(idx).ConversionFcn.uifigure = @(h)conversion_function(h.Value);
            obj.parts(idx).Height       = obj.rowH;
            obj.parts(idx).Tag          = tag;
            
            function h = createEdit()
                uicontrol('Style','text',...
                    'String',[label, ' : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW obj.rowH-10],...
                    'ToolTipString',tooltip,...
                    'Tag',[tag '_label']);
                
                switch class(value)
                    case 'datetime'
                        mystr=string(value,'uuuu-MM-dd HH:mm:ss');
                        
                    otherwise
                        mystr=string(value);
                        if ismissing(mystr)
                            mystr='';
                        end
                end
                
                h = uicontrol('Style','edit',...
                    'String',mystr,...
                    'Tag',tag,...
                    'ToolTipString',tooltip,...
                    'Position',[obj.editX obj.labelY obj.editW obj.rowH-10]);
            end
            function h = createUIedit()
                uilabel('Parent',obj.hDialog,...
                    'Text',[label, ' : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW obj.rowH-10],...
                    'Tag',[tag '_label']);
                
                switch class(value)
                    case 'datetime'
                        mystr=string(value,'uuuu-MM-dd HH:mm:ss');
                        
                    otherwise
                        mystr=string(value);
                        if ismissing(mystr)
                            mystr='';
                        end
                end
                
                h = uieditfield('Parent',obj.hDialog,...
                    'Value',mystr,...
                    'Tag',tag,...
                    'Position',[obj.editX obj.labelY obj.editW obj.rowH-10]);
            end
        end
        
        function AddCheckbox(obj,tag, String, isOn,dependentTags,tooltip, conversion_function)
            % AddCheckbox adds a checkbox to the dialog box, returns checked state, converted to same class as isOn
            % AddCheckbox(obj,tag, String, isOn,dependentTags,tooltip)
            % AddCheckbox(..., conversion_function)
            %
            % dependentTags will be enabled/disabled based on the value of this checkbox
            %convert to type, tag, label, defaultString, defaultValue, callback
            
            if exist('dependentTags','var') && iscell(dependentTags)
                cb=@(src,~)obj.cb_enableDependents(src,dependentTags);
            else
                cb=[];
            end
            
            if ~exist('conversion_function','var') || isempty(conversion_function)
                conversion_function = str2func(class(isOn));
            elseif ischar(conversion_function)
                conversion_function = str2func(conversion_function);
            end
                
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'checkbox';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createCheckbox;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createUIcheckbox;
            obj.parts(idx).ConversionFcn.figure = @(h)conversion_function(h.Value);
            obj.parts(idx).ConversionFcn.uifigure = @(h)conversion_function(h.Value);
            obj.parts(idx).Height       = obj.rowH;
            obj.parts(idx).Tag          = tag;
            
            function h = createCheckbox()
                h = uicontrol('Style','checkbox',...
                    'Value', logical(isOn),...
                    'String', String,...
                    'Callback', cb,...
                    'Tag', tag,...
                    'ToolTipString', tooltip,...
                    'Position',[obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10]);
            end
            function h = createUIcheckbox()
                h = uicheckbox('Parent',obj.hDialog,...
                    'Value', isOn,...
                    'Text', String,...
                    'ValueChangedFcn', cb,...
                    'Tag', tag,...
                    'Position',[obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10]);
            end
        end
        
        function AddNumericRange(obj, tag, label, values, minmax_values, boundaries, tooltip)
            bIdx = boundaries==["[]", "(]", "()", "[)"]; % where [,] means inclusive and (,) means exclusive
            assert(any(bIdx))  
            opfns = {{@ge,@le}, {@gt, @le}, {@gt, @lt}, {@ge, @lt}};
            descs = {{'>=','<='},{'>','<='},{'>','<'},{'>=','<'}};
            myMinFcn = opfns{bIdx}{1};
            myMaxFcn = opfns{bIdx}{2};
            assert(minmax_values(2) > minmax_values(1));
            assert(values(2)>= values(1))
            assert(myMinFcn(values(1), minmax_values(1)), 'minimum value out of range');
            assert(myMaxFcn(values(2), minmax_values(2)), 'maximum value out of range');
            conversion_function = @(v)double(string(v));
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'numericrange';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createNumericRange;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createUINumericRange;
            obj.parts(idx).ConversionFcn.figure = @(h)conversion_function(h.String);
            obj.parts(idx).ConversionFcn.uifigure = @(h)conversion_function(h.Value);
            obj.parts(idx).Height       = obj.rowH;
            obj.parts(idx).Tag          = tag;
            
            
            function h = createNumericRange()
                mintooltip = sprintf('%s (value %s %g)',tooltip, descs{bIdx}{1}, minmax_values(1));
                maxtooltip = sprintf('%s (value %s %g)',tooltip, descs{bIdx}{2}, minmax_values(2));
                uicontrol('Style','text',...
                    'String',[label, ' : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW obj.rowH-10],...
                    'ToolTipString',tooltip,...
                    'Tag',[tag '_label']);
                
                mystr=string(values);
                if ismissing(mystr)
                    mystr='';
                end
                
                h(1) = uicontrol('Style','edit',...
                    'String',mystr(1),...
                    'Tag',[tag '_min'],...
                    'ToolTipString', mintooltip,...
                    'Position',[obj.editX, obj.labelY, obj.editW/2, obj.rowH-10]);
                
                h(2) = uicontrol('Style','edit',...
                    'String',mystr(2),...
                    'Tag',[tag '_max'],...
                    'ToolTipString', maxtooltip,...
                    'Position',[obj.editX+obj.editW/2, obj.labelY, obj.editW/2, obj.rowH-10]);
                
            end
            
            function h = createUINumericRange()
                uilabel('Parent',obj.hDialog,...
                    'Text',[label, ' : '],...
                    'HorizontalAlignment','right',...
                    'Position',[obj.labelX obj.labelY obj.labelW obj.rowH-10],...
                    'Tag',[tag '_label']);
                
                mystr=string(value);
                if ismissing(mystr)
                    mystr='';
                end
                
                h(1) = uieditfield('Parent',obj.hDialog,...
                    'Value',mystr,...
                    'Tag',[tag '_min'],...
                    'Position',[obj.editX obj.labelY obj.editW obj.rowH-10]);
                
                h(2) = uieditfield('Parent',obj.hDialog,...
                    'Value',mystr,...
                    'Tag',[tag '_max'],...
                    'Position',[obj.editX obj.labelY obj.editW obj.rowH-10]);
            end
        end
        
        function AddGridSpacing(obj,tag,dx,dxunits, dy,dyunits, dz,dzunits) 
            % Add a grid parameter widget to the box.
            % AddGridSpacing(obj,tag,dx,dxunits, dy,dyunits, dz,dzunits)
            % retrieved values will be found in a structure defined by GridParameterChoice.toStruct
            %
            % see also GridParameterChoice.toStruct
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'gridparameterbox';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createGridParameters;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createGridParameters;
            obj.parts(idx).ConversionFcn    =  @toStruct;
            obj.parts(idx).Height       = GridParameterChoice.GROUPHEIGHT;
            obj.parts(idx).Tag          = tag;
            
            function h = createGridParameters()
                        % obj.didGrid = true;
                        pos = [obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10];
                        h = GridParameterChoice(...
                            obj.hDialog, tag, pos, {dx, dxunits}, {dy, dyunits}, {dz, dzunits});
            end
        end
        
        function AddEventSelector(obj, tag, esp)
            %AddEventSelector Choose between events in a radius, or closest N events
            % AddEventSelector(obj, tag, EventSelectionParameter)
            % used to define how each grid point will select events
            %
            % returns structure defined by EventSelectionChoice.toStruct
            %
            % see also EventSelectionChoice, EventSelectionChoice.toStruct, EventSelectionParameter
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'eventselectparameterbox';
            obj.parts(idx).CreatorFcn.OldStyle   =  @createEvSel;
            obj.parts(idx).CreatorFcn.NewStyle   =  @createEvSel;
            obj.parts(idx).ConversionFcn.figure    =  @EventSelectionParameters;
            obj.parts(idx).ConversionFcn.uifigure    =  @EventSelectionParameters;
            obj.parts(idx).Height       = EventSelectionChoice.GROUPHEIGHT;
            obj.parts(idx).Tag          = tag;
            
            function h = createEvSel()
                obj.didEvSel=true;
                pos=[obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10];
                h = EventSelectionChoice(obj.hDialog, tag, pos, esp);
            end
            %{
            function h = createUIEvSel()
                obj.didEvSel=true;
                pos=[obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10];
                h = UIEventSelectionChoice(obj.hDialog, tag, pos, esp);
            end
            %}
        end
        
        %% special control
        function StartPane(obj, tag, name)
            % indicate the beginning of a pane connecting items
            unimplemented_error();
        end
        
        function EndPane(obj)
            % indicate the end of a pane connecting items
            unimplemented_error();
        end
            
        %% uicontrol parts
        
        % Magnitude of completion parts
        function AddMcMethodDropdown(obj, tag, mc_method)
            % AddMcMethodDropdown choose the McMethod from the dropdown
            % AddMcMethodDropdown(obj) % creates dropdown with tag 'mc_method' using the default method
            % AddMcMethodDropdown(obj, tag, method) % specifies the tag and method. Either can be empty
            if ~exist('tag','var') || isempty(tag)
                tag = 'mc_method';
            end
            
            if ~exist('mc_method','var') || isempty(mc_method)
                mc_method = ZmapGlobal.Data.McCalcMethod;
            else
                assert(isa(mc_method,'McMethods'),'method must be either empty or an McMethods enum');
            end
            
            % this adds a popup to the end of obj.parts
            obj.AddPopup(tag, 'Choose the calculation method for Mc',...
                McMethods.dropdownList(), double(mc_method),...
                'Choose Magnitude of completion calculation method', @(h)McMethods(h.Value));
        end
        
        function AddMcAutoEstimateCheckbox(obj, tag, default)
            % ADDMCAUTOESTIMATECHECKBOX
            % AddMcAutoEstimateCheckbox(obj, tag, default), default should be a McAutoEstimate enum
            % if tag is empty, it defaults to 'use_auto_mcomp'
            % if default is empty, it defaults to the zmap global UseAutoEstimate
            if ~exist('tag','var') || isempty(tag)
                tag = 'use_auto_mcomp';
            end
            if ~exist('default','var') || isempty(default)
                default =  ZmapGlobal.Data.UseAutoEstimate;
            end
            obj.AddCheckbox(tag, 'Automatically estimate magn. of completeness',...
                default, [],'Maximum likelihood - automatic magnitude of completeness', @McAutoEstimate);
        end
            
        % if there are other COMMONLY used button behaviors, perhaps they
        %would go here.
        
        function addOKButton(obj,position) % add it to Dialog
            % create "go" button -> modifies properties, closes figure, does calculation
            switch obj.figureType
                case 'figure'
                    obj.OKbutton = uicontrol('style','pushbutton','String','OK',...
                        'Position',position,...
                        'Callback',@(src,~)obj.okDlg());
                case 'uifigure'
                    obj.OKbutton = uibutton('Parent',obj.hDialog,'Text','OK',...
                        'Position',position,...
                        'ButtonPushedFcn',@(src,~)obj.okDlg());
            end
        end
        
        function addCancelButton(obj,position) %add it to Dialog
            % create "cancel" button -> leaves properties unchanged, closes figure
            switch obj.figureType
                case 'figure'
                    obj.CANCELbutton = uicontrol('style','pushbutton','String','Cancel',...
                        'Position',position,...
                        'Callback',@(src,~)obj.clearDlg());
                case 'uifigure'
                    obj.CANCELbutton = uibutton('Parent',obj.hDialog, 'Text','Cancel',...
                        'Position',position,...
                        'ButtonPushedFcn',@(src,~)obj.clearDlg());
            end
        end
        
        
        %% object dependent callbacks
        function cb_enableDependents(obj,src,tags)
            % enables/disables fields with listed tags based on the value of this checkbox
            % tags must be a cell of strings, but can be empty cell
            setting=tf2onoff(src.Value);
            for n=1:numel(tags)
                set(findDlgTag(obj,tags{n}),'Enable',setting);
            end
            
        end
        
        function clearDlg(obj)
            % close the dialog box (without making any changes)
            % this should be the callback for the cancel/clear buttons for
            % the interactive dialog boxes
            obj.okPressed=false;
            obj.CancelFcn(); % call the function provided by the user upon dialog creation
            delete(obj.hDialog);
            obj.hDialog=[];
            
            if isvalid(obj.curfig)
                set(groot,'CurrentFigure',obj.curfig);
            end
        end
        
        function okDlg(obj)
            % copy values back to caller WriteToObj, using tags as reference.
            obj.okPressed=true;
            for n=1:numel(obj.parts)
                me  = obj.parts(n);
                h   = me.Handle;
                tag = me.Tag;
                
                % disp([me.Style,  ' : ',  tag]);
                
                if ~isempty(tag) && (~isprop(obj.WriteToObj,tag) && ~isstruct(obj.WriteToObj))
                    warning('ZMAP:dialog:missingExpectedProperty','unable to assign value back to caller because the property %s does not exist',tag);
                end
                if isempty(tag) % not meant to be analyzed
                    continue
                end
                if numel(h) == 1
                    valueToWrite =  me.ConversionFcn.(obj.figureType)(h);
                else
                    clear valueToWrite;
                    for j = numel(h) : -1 : 1
                        valueToWrite(j) =  me.ConversionFcn.(obj.figureType)(h(j));
                    end
                end
                obj.WriteToObj.(tag) = valueToWrite;
            end
            
            delete(obj.hDialog);
            
            
            if ~isempty(obj.curfig) && isvalid(obj.curfig)
                set(groot,'CurrentFigure',obj.curfig);
            end
            
            obj.OkFcn(); % call the function provided by the user upon dialog creation
        end
        
        %% helper functions
        function h=findDlgTag(obj,tag)
            % findDlgTag returns handles for this object's dialog box that have a specific tag
            h=findobj(obj.hDialog,'Tag',tag);
        end
    end
    
    methods(Static)
        function [myans, okpressed] = simpletest()
            % simple test of each type of item
            
            zdlg = ZmapDialog();
            % simple header
            zdlg.AddHeader('I am a header');
            
            % popup that provides three choices, and returns an alternate value based on your choice
            listValues = {'Eat','Drink','Be Merry'};
            altValues = {'Yum', 'glug glug', 'horray!'};
            zdlg.AddPopup('lifechoice',   'life choice',     listValues, 2, 'Which is most important?',  altValues);
            
            % edit box that gets a number, and returns a number
            zdlg.AddEdit( 'noiselevel',   'Noise level',      1.5,          'how much noise should there be?');
            
            % checkbox that reuturns a logical value
            zdlg.AddCheckbox('usenoise',  'use noise level',  false,        {'noiselevel','noiselevel_label'},...
                'Should noise be applied to the data?');
            
            % special-case  items
            esp = EventSelectionParameters('NumClosestEventsUpToRadius',100, 5)
            zdlg.AddEventSelector('evtparams', esp);
            zdlg.AddGridSpacing('gridparams', 5 ,'km', 5,'km', 10,'km');
            
            zdlg.AddMcMethodDropdown();  % reutrns a McMethod enumerator
            zdlg.AddMcAutoEstimateCheckbox(); %returns a McAutoEstimate enumerator
            
            % return an LSWeightingAutoEstimate enumerator from a checkbox
            zdlg.AddCheckbox('weighting',  'use weighting', LSWeightingAutoEstimate.auto, [],'usewttooltip',   @LSWeightingAutoEstimate)
 
            % ask for a duration. number interpretation is controlled by the provided function
            some_duration = days(.5);
            zdlg.AddDurationEdit('howlong',     'How long',      some_duration,                      'how long is it?', @hours)
            
            % ask for a datetime
            zdlg.AddEdit('when',           'when',          datetime,                        'when is it');
            [myans,okpressed] = zdlg.Create('Name', 'my example');
            
           
        end 
    end
end



