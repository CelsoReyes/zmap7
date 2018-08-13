classdef ZmapDialog < handle
    % ZmapDialog Helper, used to generate dialog boxes while keeping code clean
    %
    % ZmapDialog properties:
    %
    %   hCaller          - handle to the caller. Values are written to hCaller.(tag) upon OK
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
    %     zdlg.AddEventSelector('evtparams', 100, 5)
    %     [myans,okpressed] = zdlg.Create('my example');
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
    %     zdlg.AddEventSelector('evtparams', 100, 5)
    %     zdlg.Create('my dialog title');
    %
    %   end
    %
    %  function doit(obj)
    %       obj.Calculate();
    %       obj.plot();
    %  end
    %  end % methods
    
    properties
        hCaller;                                   % handle to the caller. Values are written to hCaller.(tag) upon OK
        callerOKFunction            = @do_nothing; % to be run once values are copied back to caller and dialog disappears
        hDialog;                                   % handle to the dialog box
        okPressed       logical     = false;
    end
    
    properties(Constant)
        buttonSpace = 60;   % space left over for button placement
        rowH        = 35;   % height of each item in a row
        
        dlgW        = 330;  % width of entire dialog
        labelX      = 10;
        labelW      = 150;
        
        editX       = ZmapDialog.labelX + ZmapDialog.labelW + 20;
        editW       = ZmapDialog.dlgW   - ZmapDialog.editX  - 15;
    end
    
    properties(Hidden)
        % these one-off issues need to be reconsidered. t
        hasGrid         logical     = false;
        didGrid         logical     = false;
        gridHeight                  = GridParameterChoice.GROUPHEIGHT;
        
        hasEvSel        logical     = false;
        didEvSel        logical     = false;
        evSelHeight                 = EventSelectionChoice.GROUPHEIGHT;
        curfig                      % figure handle to figure prior to call
    end
    
    properties(SetAccess=private)
        parts                       = struct([]); % ui details go in fields CreatorFcn, Tag, Style, and Handle
        partIdx                     = 0;  % current part, used when creating the dialog box
    end
    
    properties(Dependent)
        dlgH
        labelY
    end
    
    methods
        
        function h = get.dlgH(obj)
             h = (numel(obj.parts)+1) * obj.rowH + obj.buttonSpace ...
                + obj.hasGrid *  obj.gridHeight...
                + obj.hasEvSel * obj.evSelHeight;
        end
        
        function y = get.labelY(obj) 
            % get y for current part
            y = obj.dlgH - obj.rowH * (obj.partIdx + 1) ...
                - obj.didGrid * obj.gridHeight ...
                - obj.didEvSel * obj.evSelHeight;
        end
        
        function obj=ZmapDialog(hCaller,okevent)
            % initialize a ZmapDialog
            % hCaller is the handle to the calling Function.
            % output values are returned to hCaller.(tag) for each uicontrol
            % once the OK button is pressed. if the OK button is not pressed, no changes are made
            % okevent (a function handle) will be executed if OK is pressed
            if ~exist('hCaller','var') || isempty(hCaller)
                obj.hCaller=struct();
            else
                obj.hCaller=hCaller;
            end
            %if isempty(hCaller)
            %    warning('values cannot be saved to the calling function. they''l be written to base');
            %end
            if exist('okevent','var')
                obj.callerOKFunction=okevent;
            else
                if ishandle(obj.hCaller)
                    obj.callerOKFunction=@(src,~) fprintf('ZmapFunctionDialog: no OK function was specified for the %s object, so it will not be notified\n',class(obj.hCaller));
                end
            end
        end
        
        function [results,okPressed]=Create(obj, dlgTitle)
            % Create creates a dialog box based on a cell description of types within.
            % [results,okPressed]=Create(obj, dlgTitle)
            obj.curfig = gcf;
            obj.okPressed=false;
            assert(~isempty(obj.parts),'An empty Dialog cannot be created');
            
            % reset these values
            obj.didGrid  = false;
            obj.didEvSel = false;
            
            setOnCompletion={}; % uicontrols that require further setting after all items created
            
            obj.hDialog=figure('Name',dlgTitle,...
                'MenuBar', 'none',...
                'InnerPosition', position_in_current_monitor(obj.dlgW , obj.dlgH),...
                'NumberTitle','off'...
                );
            
            for i = 1 : numel(obj.parts)
                obj.partIdx = i;
                details=obj.parts(obj.partIdx);
                switch lower(details.Style)
                    case 'checkbox'
                        obj.parts(obj.partIdx).Handle = details.CreatorFcn();
                        if ~isempty(obj.parts(obj.partIdx).Handle.Callback)
                            setOnCompletion=[setOnCompletion; {details.Tag}];
                        end
                    otherwise
                        obj.parts(obj.partIdx).Handle = details.CreatorFcn();
                end
            end
            
            obj.addCancelButton([obj.dlgW-80 10 70 obj.buttonSpace/2]);
            obj.addOKButton([obj.dlgW-160 10 70 obj.buttonSpace/2]);
            
            % checkboxes may have callbacks that affect other uicontrols' Enable status.
            % now that all uicontrols have been created, disable/enable as dictated by the
            % checkbox state
            
            for n=1:numel(setOnCompletion)
                src=obj.findDlgTag(setOnCompletion{n});
                src.Callback(src,[]);
            end
            
            results=[];
            
            % if we are expecting an answer, wait until dialog is finished.
            if nargout > 0
                uiwait(obj.hDialog)
                if isstruct(obj.hCaller)
                    results=obj.hCaller;
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
            elseif ischar(conversion_function) || isstring(conversion_function)
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
            obj.parts(idx).CreatorFcn   =  @createHeader;
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
            assert(defaultChoice <= numel(choices) && defaultChoice > 0,'%d out of %d choices',defaultChoice,choices)

            if iscell(conversion_function) && numel(conversion_function) == numel(choices)
                alternateValues = conversion_function;
                conversion_function = @(h) h.UserData{h.Value};
            else
                alternateValues = [];
            end
            
            if ~exist('conversion_function','var') || isempty(conversion_function)
                conversion_function = @(x)x;
                conversion_function = @(h)conversion_function(h.Value);
            elseif ischar(conversion_function)|| isstring(conversion_function)
                conversion_function = str2func(conversion_function);
                conversion_function = @(h)conversion_function(h.Value);
            end
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style            = 'popupmenu';
            obj.parts(idx).CreatorFcn       =  @createPopup;
            obj.parts(idx).ConversionFcn    =  conversion_function;
            obj.parts(idx).Tag              = tag;
            
            function h = createPopup()
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
            elseif ischar(conversion_function) || isstring(conversion_function)
                conversion_function = str2func(conversion_function);
            end
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'durationedit';
            obj.parts(idx).CreatorFcn   =  @createEdit;
            obj.parts(idx).ConversionFcn = @(h)conversion_function(double(string(h.String)));
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
                else
                    conversion_function = str2func(class(value));
                end
            elseif ischar(conversion_function)|| isstring(conversion_function)
                conversion_function = str2func(conversion_function);
            end
            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'edit';
            obj.parts(idx).CreatorFcn   =  @createEdit;
            obj.parts(idx).ConversionFcn = @(h)conversion_function(h.String);
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
                        mystr=string(value,'uuuu-MM-dd hh:mm:ss');
                        
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
            obj.parts(idx).CreatorFcn   =  @createCheckbox;
            obj.parts(idx).ConversionFcn = @(h)conversion_function(h.Value);
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
        end
        
        function AddGridSpacing(obj,tag,dx,dxunits, dy,dyunits, dz,dzunits) 
            % Add a grid parameter widget to the box.
            % AddGridSpacing(obj,tag,dx,dxunits, dy,dyunits, dz,dzunits)
            % retrieved values will be found in a structure defined by GridParameterChoice.toStruct
            %
            % see also GridParameterChoice.toStruct
            assert (~obj.hasGrid,'Dialog box already has an grid parameter section');
            obj.hasGrid = true;

            
            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'gridparameterbox';
            obj.parts(idx).CreatorFcn   =  @createGridParameters;
            obj.parts(idx).ConversionFcn    =  @toStruct;
            obj.parts(idx).Tag          = tag;
            
            function h = createGridParameters()
                        obj.didGrid = true;
                        pos = [obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10];
                        h = GridParameterChoice(...
                            obj.hDialog, tag, pos, {dx, dxunits}, {dy, dyunits}, {dz, dzunits});
            end
        end
        
        function AddEventSelector(obj, tag, ni, ra, minvalid)
            %AddEventSelector Choose between events in a radius, or closest N events
            % AddEventSelector(obj, tag, EventSelectionStruct)
            % AddEventSelector(obj, tag, ni, ra, minvalid)
            % used to define how each grid point will select events
            %
            % returns structure defined by EventSelectionChoice.toStruct
            %
            % see also EventSelectionChoice, EventSelectionChoice.toStruct
            assert (~obj.hasEvSel,'Dialog box already has an event selection section');
            obj.hasEvSel = true;
            if ~exist('minvalid','var')
                minvalid=0;
            end

            idx = numel(obj.parts)+1;
            obj.parts(idx).Style        = 'eventselectparameterbox';
            obj.parts(idx).CreatorFcn   =  @createEvSel;
            obj.parts(idx).ConversionFcn    =  @toStruct;
            obj.parts(idx).Tag          = tag;
            
            function h = createEvSel()
                obj.didEvSel=true;
                pos=[obj.labelX obj.labelY obj.dlgW-obj.labelX obj.rowH-10];
                if isa(ni,'struct')
                    h = EventSelectionChoice(obj.hDialog, tag, pos, ni);
                else
                    h = EventSelectionChoice(obj.hDialog, tag, pos, ni, ra, minvalid);
                end
            end
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
            uicontrol('style','pushbutton','String','OK',...
                'Position',position,...
                'Callback',@(src,~)obj.okDlg());
        end
        
        function addCancelButton(obj,position) %add it to Dialog
            % create "cancel" button -> leaves properties unchanged, closes figure
            
            uicontrol('style','pushbutton','String','Cancel',...
                'Position',position,...
                'Callback',@(src,~)obj.clearDlg());
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
            close(obj.hDialog);
            obj.hDialog=[];
            
            if isvalid(obj.curfig)
                set(groot,'CurrentFigure',obj.curfig);
            end
        end
        
                
        function okDlg(obj)
            % copy values back to caller hCaller, using tags as reference.
            obj.okPressed=true;
            for n=1:numel(obj.parts)
                me  = obj.parts(n);
                h   = me.Handle;
                tag = me.Tag;
                
                % disp([me.Style,  ' : ',  tag]);
                
                if ~isempty(tag) && (~isprop(obj.hCaller,tag) && ~isstruct(obj.hCaller))
                    warning('unable to assign value back to caller because the property %s does not exist',tag);
                end
                if isempty(tag) % not meant to be analyzed
                    continue
                end
                
                obj.hCaller.(tag) = me.ConversionFcn(h);
            end
            close(obj.hDialog);
            
            if ~isempty(obj.callerOKFunction)
                obj.callerOKFunction(); % call the caller's method before quitting
            end
            obj.curfig
            if ~isempty(obj.curfig) && isvalid(obj.curfig)
                set(groot,'CurrentFigure',obj.curfig);
            end
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
            zdlg.AddEventSelector('evtparams', 100, 5);
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
            [myans,okpressed] = zdlg.Create('my example');
            
           
        end 
    end
end



