classdef EventSelectionChoice < handle
    % EventSelectionChoice widget allowing user to determine how samples are selected
    %
    % options this can control:
    %   1. Select all events within Radius R of a point?
    %       UseEventsInRadius = true
    %       RadiusKm = [some value]
    %
    %   2. Select the closest N events to a point, up to a max radius?
    %       UseNumNearbyEvents =  true
    %       NumClosestEvents = [some value]
    %       maxRadiusKm = [some value] 
    %       
    %   5. Minumum number of points for meaningful measurement?
    %        requiredNumEvents = [some value] (0 if unused)
    %
    %   6. Include only events within shape?
    %        limitCatalogToShape = logical
    %
    %
    properties
        ni (1,1) double % number of nearby events to consider
        ra (1,1) double % radius in km for sampling
        ubg1 matlab.ui.container.ButtonGroup
    end
    properties(Dependent)
        UseNumNearbyEvents
        UseEventsInRadius
        MaxRadiusKm
        max_ra      % maximum radius when sampling
    end
    
    properties(Access=private)
        % add handles
        hUseNevents
        hUseRadius
        hNi
        hRa
        hMin
        hMaxRa
        hUseMaxRa
        
    end
    
    properties(Constant)
        GROUPWIDTH=315
        GROUPHEIGHT=120;
    end
    
    methods
        function out=get.max_ra(obj) % compatibility
            out = obj.ra;
        end
        function obj=set.max_ra(obj,val) %compatibility
            obj.ra = val;
        end
        function out=get.UseNumNearbyEvents(obj)
            out = obj.ubg1.SelectedObject==obj.hUseNevents;
        end
        function out=get.UseEventsInRadius(obj)
            out = obj.ubg1.SelectedObject==obj.hUseRadius;
        end
        
        function out=get.MaxRadiusKm(obj)
            if obj.UseNumNearbyEvents && logical(obj.hUseMaxRa.Value)
                out = obj.max_ra;
            else
                out = inf;
            end
        end
        function esp = EventSelectionParameters(obj)
            esp = EventSelectionParameters.fromStruct(obj.toStruct);
        end
        
        function out=toStruct(obj)
            % creates a structure with fields
            %  NumClosestEvents, RadiusKm, UseNumNearbyEvents, UseEventsInRadius
            out.NumClosestEvents     = obj.ni;
            out.RadiusKm            = obj.ra;
            out.UseNumNearbyEvents  = obj.UseNumNearbyEvents;
            out.UseEventsInRadius   = obj.UseEventsInRadius || ~isinf(obj.MaxRadiusKm);
            out.maxRadiusKm         = obj.MaxRadiusKm;
            
            % out.requiredNumEvents   = obj.minValid;
        end
        function obj=EventSelectionChoice(fig, tag, lowerCornerPosition, ev)
            % choose_grid adds controls to describe how to choose a grid.
            % obj=EventSelectionChoice(fig,tag, lowerCornerPosition, evsel)
            % Grid options
            if nargin==4 && isa(ev,'EventSelectionParameters')
                % use the evsel fields
                     % Create, Load, or use Previous grid choice
                obj.ni          = ev.NumClosestEvents;
                obj.ra          = ev.RadiusKm;
                obj.max_ra      = ev.RadiusKm;
                % obj.minValid    = ev.requiredNumEvents;
                
                if isempty(lowerCornerPosition)
                    X0 = 5;
                    Y0 = 50;
                else
                    X0 = lowerCornerPosition(1);
                    Y0 = lowerCornerPosition(2);
                end
                enable_ra   = true;
                enable_ni   = true;
                default_is_ni = isprop(ev,'UseEventsInRadius') && ev.UseEventsInRadius;
                checkbox_active = ev.UseEventsInRadius;
            end
            
            
            useMaxRadius_cb = [];
            switch figtype(fig)
                case 'uifigure'
                    setupUIfigure
                    
                case 'figure'
                    setupFigure;
            end
            
            % deactivate one or the other input fields depending on what is allowed
            if ~default_is_ni
                obj.hRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.hNi.Enable='off';
                obj.hMaxRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            obj.ubg1.SelectionChangedFcn=@cb_selectioncontrol;
            
            if ev.UseNumClosestEvents
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            
            obj.ubg1.SelectionChangedFcn(obj.ubg1); % ensure correct radiobutton is selected
                
            obj.hUseMaxRa.Value = checkbox_active;
            obj.hMaxRa.Enable = char(matlab.lang.OnOffSwitchState(checkbox_active && ev.UseNumClosestEvents));
                
            do_nothing();
            function setupFigure()
                obj.ubg1=uibuttongroup(fig,'Title','Event Selection',...
                    'Units','pixels','Position',[X0 Y0 obj.GROUPWIDTH obj.GROUPHEIGHT], 'Tag',tag);
                
                %% N EVENTS
                obj.hUseNevents = uicontrol(obj.ubg1,'Style','radiobutton',...
                    'Units','pixels',...
                    'Position',[17 obj.GROUPHEIGHT-40 280 22],...
                    'String','Number of Nearest Events',...
                    'Enable',tf2onoff(enable_ni));
                
                obj.hNi=uicontrol(obj.ubg1,'Style','edit',...
                    'Units','pixels',...
                    'Position',[234 obj.GROUPHEIGHT-40 72 22],...
                    'String',num2str(obj.ni),...
                    'callback',@cb_numberevents,...
                    'ToolTipString','# closest events to include');
                
                
                %% SAMPLE DISTANCE
                obj.hUseMaxRa = uicontrol(obj.ubg1, 'Style','checkbox',...
                    'Units', 'pixels', 'Position', [50 obj.GROUPHEIGHT-70 170 22],...
                    'String', 'up to max radius (km)...',...
                    'Tag','useMaxRadius','callback', @cb_useMaxRadius);
                
                obj.hMaxRa=uicontrol(obj.ubg1,'Style','edit',...
                    'Units','pixels','Position',[230 obj.GROUPHEIGHT-70 72 22],...
                    'String',num2str(obj.ra),...
                    'callback',@cb_radius, ...
                    'ToolTipString','Limit sample distance for events');
                
                
                %% CONSTANT RADIUS
                obj.hUseRadius =  uicontrol(obj.ubg1,'Style','radiobutton',...
                    'Units','pixels',...
                    'Position',[17 obj.GROUPHEIGHT-105 280 22],...
                    'String','Events within Constant Radius (km)',...
                    'Enable',tf2onoff(enable_ra));
                
                obj.hRa=uicontrol(obj.ubg1,'Style','edit',...
                    'Units','pixels',...
                    'Position',[234 obj.GROUPHEIGHT-105 72 22],...
                    'String',num2str(obj.ra),...
                    'callback',@cb_radius,...
                    'ToolTipString','event selection radius');
                
                useMaxRadius_cb = @cb_useMaxRadius; %required out of scope
                %% callbacks
                
                function cb_useMaxRadius(~,~)
                    % enables the max radius edit box when the max radius checkbox is checked & active
                    if obj.hUseMaxRa.Value && obj.hUseMaxRa.Enable=="on"
                        set(obj.hMaxRa,'Enable','on');
                    else
                        set(obj.hMaxRa,'Enable','off');
                    end
                end
                
                function cb_numberevents(mysrc,~)
                    obj.ni=str2double(mysrc.String);
                end
                
                function cb_radius(mysrc,~)
                    obj.ra=str2double(mysrc.String);
                    if mysrc == obj.hMaxRa
                        obj.hRa.String = mysrc.String;
                    else
                        obj.hMaxRa.String = mysrc.String;
                    end
                end
            end
            
            function setupUIfigure()
                obj.ubg1=uibuttongroup(fig,'Title','Event Selection',...
                'Units','pixels','Position',[X0 Y0 obj.GROUPWIDTH obj.GROUPHEIGHT], 'Tag',tag);
            
            %% N EVENTS
            obj.hUseNevents = uiradiobutton(obj.ubg1,...
                'Position',[17 obj.GROUPHEIGHT-40 280 22],...
                'Text','Number of Nearest Events',...
                'Enable',tf2onoff(enable_ni));
            
            obj.hNi=uieditfield(obj.ubg1,...
                'Position',[234 obj.GROUPHEIGHT-40 72 22],...
                'Value',num2str(obj.ni),...
                'ValueChangedFcn',@cb_numberevents);
            
            
            %% SAMPLE DISTANCE
            obj.hUseMaxRa = uicheckbox(obj.ubg1);
            obj.hUseMaxRa.Position = [50 obj.GROUPHEIGHT-70 170 22];
            obj.hUseMaxRa.Text ='up to max radius (km)...';
            obj.hUseMaxRa.Tag='useMaxRadius';
            obj.hUseMaxRa.ValueChangedFcn = @cb_useMaxRadius;
            
            obj.hMaxRa=uieditfield(obj.ubg1,...
                'Position',[230 obj.GROUPHEIGHT-70 72 22],...
                'Value',num2str(obj.max_ra),...
                'ValueChangedFcn',@cb_radius);
                
            
            %% CONSTANT RADIUS
            obj.hUseRadius =  uiradiobutton(obj.ubg1,...
                'Position',[17 obj.GROUPHEIGHT-105 280 22],...
                'Text','Events within Constant Radius (km)',...
                'Enable',tf2onoff(enable_ra));
            
            obj.hRa=uieditfield(obj.ubg1,...
                'Position',[234 obj.GROUPHEIGHT-105 72 22],...
                'Value',num2str(obj.ra),...
                'ValueChangedFcn',@cb_radius);
                
            %% callbacks
            
            useMaxRadius_cb = @cb_useMaxRadius; %required out of scope
                
            function cb_useMaxRadius(~,~)
                % enables the max radius edit box when the max radius checkbox is checked & active
                if obj.hUseMaxRa.Value && obj.hUseMaxRa.Enable=="on"
                    set(obj.hMaxRa,'Enable','on');
                else
                    set(obj.hMaxRa,'Enable','off');
                end
            end
            
            function cb_numberevents(mysrc,~)
                obj.ni=str2double(mysrc.Value);
            end
            
            function cb_radius(mysrc,~)
                obj.ra=str2double(mysrc.String);
                if mysrc == obj.hMaxRa
                    obj.hRa.String = mysrc.String;
                else
                    obj.hMaxRa.String = mysrc.String;
                end
            end
            end
            
            function cb_selectioncontrol(mysrc,~)
                if mysrc.SelectedObject == obj.hUseNevents
                    set([obj.hRa],'Enable','off');
                    set([obj.hNi, obj.hUseMaxRa],'Enable','on');
                else
                    set([obj.hNi, obj.hUseMaxRa],'Enable','off');
                    set([obj.hRa],'Enable','on');
                end
                useMaxRadius_cb();
            end
        end

      %{  
        function obj=UIEventSelectionChoice(fig, tag, lowerCornerPosition, ni,ra)
            % choose_grid adds controls to describe how to choose a grid.
            % obj=EventSelectionChoice(fig,tag, lowerCornerPosition, ni,ra, min_valid)
            % obj=EventSelectionChoice(fig,tag, lowerCornerPosition, evsel)
            % Grid options
            if nargin==4 && isstruct(ni)
                ev=ni; % name correctly for readability below
                % use the evsel fields
                     % Create, Load, or use Previous grid choice
                obj.ni          = ev.NumClosestEvents;
                obj.ra          = ev.RadiusKm;
                obj.max_ra      = ev.maxRadiusKm;
                % obj.minValid    = ev.requiredNumEvents;
                
                if isempty(lowerCornerPosition)
                    X0 = 5;
                    Y0 = 50;
                else
                    X0 = lowerCornerPosition(1);
                    Y0 = lowerCornerPosition(2);
                end
                enable_ra   = true;
                enable_ni   = true;
                default_is_ni = isfield(ev,'UseEventsInRadius') && ev.UseEventsInRadius;
            else
                % Create, Load, or use Previous grid choice
                obj.ni      = ni;
                obj.ra      = ra;
                obj.max_ra  = ra;
                
                if isempty(lowerCornerPosition)
                    X0 = 5;
                    Y0 = 50;
                else
                    X0 = lowerCornerPosition(1);
                    Y0 = lowerCornerPosition(2);
                end
                
                enable_ra       = ~isempty(ra);
                enable_ni       = ~isempty(ni);
                default_is_ni   = enable_ni;
            end
            
            
            obj.ubg1=uibuttongroup(fig,'Title','Event Selection',...
                'Units','pixels','Position',[X0 Y0 obj.GROUPWIDTH obj.GROUPHEIGHT], 'Tag',tag);
            
            %% N EVENTS
            obj.hUseNevents = uiradiobutton(obj.ubg1,...
                'Position',[17 obj.GROUPHEIGHT-40 280 22],...
                'Text','Number of Nearest Events',...
                'Enable',tf2onoff(enable_ni));
            
            obj.hNi=uieditfield(obj.ubg1,...
                'Position',[234 obj.GROUPHEIGHT-40 72 22],...
                'Value',num2str(obj.ni),...
                'callback',@cb_numberevents);
            
            
            %% SAMPLE DISTANCE
            obj.hUseMaxRa = uicheckbox(obj.ubg1,...
                'Position', [50 obj.GROUPHEIGHT-70 170 22],...
                'Text', 'up to max radius (km)...',...
                'Tag','useMaxRadius','callback', @cb_useMaxRadius);
            
            obj.hMaxRa=uieditfield(obj.ubg1,...
                'Position',[230 obj.GROUPHEIGHT-70 72 22],...
                'Value',num2str(obj.max_ra),...
                'callback',@cb_radius);
                
            
            %% CONSTANT RADIUS
            obj.hUseRadius =  uiradiobutton(obj.ubg1,...
                'Position',[17 obj.GROUPHEIGHT-105 280 22],...
                'Text','Events within Constant Radius (km)',...
                'Enable',tf2onoff(enable_ra));
            
            obj.hRa=uieditfield(obj.ubg1,...
                'Position',[234 obj.GROUPHEIGHT-105 72 22],...
                'Value',num2str(obj.ra),...
                'callback',@cb_radius);
                
            
            % deactivate one or the other input fields depending on what is allowed
            if ~default_is_ni
                obj.hRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.hNi.Enable='off';
                obj.hMaxRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            obj.ubg1.SelectionChangedFcn=@cb_selectioncontrol;
            
            if ev.UseNumClosestEvents
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            
            obj.ubg1.SelectionChangedFcn(obj.ubg1); % ensure correct radiobutton is selected
            
            function cb_selectioncontrol(mysrc,~)
                if mysrc.SelectedObject == obj.hUseNevents
                    set([obj.hRa],'Enable','off');
                    set([obj.hNi, obj.hUseMaxRa],'Enable','on');
                else
                    set([obj.hNi, obj.hUseMaxRa],'Enable','off');
                    set([obj.hRa],'Enable','on');
                end
                cb_useMaxRadius();
            end
            
            function cb_useMaxRadius(~,~)
                % enables the max radius edit box when the max radius checkbox is checked & active
                if obj.hUseMaxRa.Value && obj.hUseMaxRa.Enable=="on"
                    set(obj.hMaxRa,'Enable','on');
                else
                    set(obj.hMaxRa,'Enable','off');
                end
            end
            
            function cb_numberevents(mysrc,~)
                obj.ni=str2double(mysrc.Value);
            end
            
            function cb_radius(mysrc,~)
                obj.ra=str2double(mysrc.String);
                if mysrc == obj.hMaxRa
                    obj.hRa.String = mysrc.String;
                else
                    obj.hMaxRa.String = mysrc.String;
                end
            end
        end
       %}
    end
    
    methods(Static)
        function [evsel, okPressed]=quickshow(writeToGlobal,esp) % ni,ra,min_valid)
            %QUICKSHOW will produce a simple ZmapDialog, writing
            % selcrit = evsel.quickshow() get parameters into the output
            % evsel.QUICKSHOW(true) writes results back to ZmapGlobal
            % QUICKSHOW(writeToGlobal,eventSelectionParametersObject)
            % QUICKSHOW(writeToGlobal,eventSelectionStruct)
            
            f=figure('Name','EventSelectionChoice',...
                'Menubar','none',...
                'InnerPosition',position_in_current_monitor( EventSelectionChoice.GROUPWIDTH+5, EventSelectionChoice.GROUPHEIGHT+50),...
                'Numbertitle','off'...
                );
            t='esc'; lcp=[5 50]; 
            ZG=ZmapGlobal.Data;
            if nargin == 2 && (isstruct(esp) || isa(esp,'EventSelectionParameters'))
                
                % ni is actually an eventselection-style struct
                esc=EventSelectionChoice(f,t,lcp,esp);
            elseif nargin<2
                
                % no struct or other options provided, but default exists, so use that
                esc=EventSelectionChoice(f,t,lcp, ZG.GridSelector);
            else
                help('EventSelectionChoice.quickshow');
                error('unanticipated inputs to quickshow');
            end
            
            evsel=esc.toStruct;
            inwidth=f.Position(3);
            writeToGlobal = exist('writeToGlobal','var') && writeToGlobal;
            
            uicontrol('style','checkbox','string','Keep as default',...
                'callback',@keep_cb,... %modifies writeToGlobal
                'Value',writeToGlobal,'Position',[15 15 100 25]);
            
            uicontrol('style','pushbutton','string','OK','Callback',@ok_cb,'Position',[inwidth-140 10 60 25]);
            
            uicontrol('style','pushbutton','string','Cancel','callback',@cancel_cb,'Position',[inwidth-70 10 60 25]);
            uiwait(f);
            if writeToGlobal && okPressed
                assert(~isempty(evsel.NumClosestEvents));
                ZG.ni=evsel.NumClosestEvents;
                assert(~isempty(evsel.RadiusKm));
                ZG.ra=evsel.RadiusKm;
                ZG.GridSelector = EventSelectionParameters.fromStruct(evsel);
            end
            % TODO set another global saying which method to use?
            
            function ok_cb(~,~)
                evsel=esc.toStruct;
                okPressed=true;
                close(f)
            end
            function cancel_cb(~,~)
                okPressed=false;
                close(f);
            end
            function keep_cb(src,~)
                writeToGlobal=src.Value;
            end
        end
        
        function tf=isValidSelector(ev)
            tf = true;
            % if  using nearby events, make sure the number is specified
            if ev.UseNumNearbyEvents
                tf = tf && ev.NumClosestEvents > 0;
            end
            
            % if using events in radius, make sure the radius is specified
            if ev.UseEventsInRadius
                tf = tf && ev.MaxSampleRadius >= 0;
            end
            tf = tf && (ev.UseEventsInRadius || ev.MaxSampleRadius);
        end
        
        function mustBeEventSelector(ev)
            assert(EventSelectionChoice.isValidSelector(ev),'Value does not look like a valid Event Selector');
        end
    end

end