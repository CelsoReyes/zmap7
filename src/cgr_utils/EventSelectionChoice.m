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
    %       NumNearbyEvents = [some value]
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
        max_ra (1,1) double % maximum radius when sampling specific number of events
        ra (1,1) double % radius in km for RADIUS sampling
        minValid (1,1) double % minimum number of selected events to consider point measureable
        ubg1 matlab.ui.container.ButtonGroup
    end
    properties(Dependent)
        UseNumNearbyEvents
        UseEventsInRadius
    end
    properties(Access=private)
        % add handles
        hUseNevents
        hUseRadius
        hNi
        hRa
        hMin
        hMaxRa
        
    end
    
    properties(Constant)
        GROUPWIDTH=315
        GROUPHEIGHT=170;
    end
    
    methods
        function out=get.UseNumNearbyEvents(obj)
            out = obj.ubg1.SelectedObject==obj.hUseNevents;
        end
        function out=get.UseEventsInRadius(obj)
            out = obj.ubg1.SelectedObject==obj.hUseRadius;
        end
        
        function out=toStruct(obj)
            % creates a structure with fields
            %  NumNearbyEvents, RadiusKm, UseNumNearbyEvents, UseEventsInRadius
            out.NumNearbyEvents=obj.ni;
            out.RadiusKm=obj.ra;
            out.UseNumNearbyEvents=obj.UseNumNearbyEvents;
            out.UseEventsInRadius=obj.UseEventsInRadius;
            if obj.UseNumNearbyEvents
                out.maxRadiusKm = obj.max_ra;
            else
                out.maxRadiusKm = obj.ra;
            end
            out.requiredNumEvents = obj.minValid;
        end
        
        function obj=EventSelectionChoice(fig, tag, lowerCornerPosition, ni,ra, min_valid)
            % choose_grid adds controls to describe how to choose a grid.
            % obj=EventSelectionChoice(fig,tag, lowerCornerPosition, ni,ra, min_valid)
            % obj=EventSelectionChoice(fig,tag, lowerCornerPosition, evsel)
            % Grid options
            if nargin==4 && isstruct(ni)
                ev=ni; % name correctly for readability below
                % use the evsel fields
                     % Create, Load, or use Previous grid choice
                obj.ni=ev.NumNearbyEvents;
                obj.ra=ev.RadiusKm;
                obj.max_ra = ev.maxRadiusKm;
                obj.minValid = ev.requiredNumEvents;
                
                if isempty(lowerCornerPosition)
                    X0 = 5;
                    Y0 = 50;
                else
                    X0 = lowerCornerPosition(1);
                    Y0 = lowerCornerPosition(2);
                end
                enable_ra = true;
                enable_ni = true;
                default_is_ni = isfield(ev,'UseEventsInRadius') && ev.UseEventsInRadius;
            else
                % Create, Load, or use Previous grid choice
                obj.ni=ni;
                obj.ra=ra;
                obj.max_ra = ra;
                if ~exist('min_valid','var')
                    min_valid=0;
                    ZmapMessageCenter.set_warning('unset MIN events','no minimum valid # events are set. assuming 0');
                end
                obj.minValid=min_valid;
                
                if isempty(lowerCornerPosition)
                    X0 = 5;
                    Y0 = 50;
                else
                    X0 = lowerCornerPosition(1);
                    Y0 = lowerCornerPosition(2);
                end
                
                enable_ra = ~isempty(ra);
                enable_ni = ~isempty(ni);
                default_is_ni = enable_ni;
            end
            
            
            obj.ubg1=uibuttongroup(fig,'Title','Event Selection',...
                'Units','pixels','Position',[X0 Y0 obj.GROUPWIDTH obj.GROUPHEIGHT], 'Tag',tag);
            
            % N EVENTS
            obj.hUseNevents = uicontrol(obj.ubg1,'Style','radiobutton',...
                'Units','pixels',...
                'Position',[17 obj.GROUPHEIGHT-40 280 22],...
                'String','Number of Nearest Events',...
                'Enable',tf2onoff(enable_ni));
            
            obj.hNi=uicontrol(obj.ubg1,'Style','edit',...
                'Units','pixels',...
                'Position',[234 obj.GROUPHEIGHT-40 72 22],...
                'String',num2str(obj.ni),...
                'callback',@callbackfun_ni,...
                'ToolTipString','# closest events to include');
            
            
            % SAMPLE DISTANCE
            uicontrol(obj.ubg1,'Style','text',...
                'Units','pixels','Position',[17 obj.GROUPHEIGHT-70 160 22],...
                'String','...up to max radius (km)',...
                'HorizontalAlignment','right');
            
            obj.hMaxRa=uicontrol(obj.ubg1,'Style','edit',...
                'Units','pixels','Position',[190 obj.GROUPHEIGHT-70 72 22],...
                'String',num2str(obj.max_ra),...
                'callback',@callbackfun_maxra, ...
                'ToolTipString','Limit sample distance for events');
                
            % CONSTANT RADIUS
            obj.hUseRadius =  uicontrol(obj.ubg1,'Style','radiobutton',...
                'Units','pixels',...
                'Position',[17 obj.GROUPHEIGHT-105 280 22],...
                'String','Events within Constant Radius (km)',...
                'Enable',tf2onoff(enable_ra));
            
            obj.hRa=uicontrol(obj.ubg1,'Style','edit',...
                'Units','pixels',...
                'Position',[234 obj.GROUPHEIGHT-105 72 22],...
                'String',num2str(obj.ra),...
                'callback',@callbackfun_ra,...
                'ToolTipString','event selection radius');
                
            
            %
             uibuttongroup(obj.ubg1,...
                'Units','pixels','Position',[10 50 obj.GROUPWIDTH-20 2], 'Tag',tag);
            
            
            %
            uicontrol(obj.ubg1,'Style','text',...
                'Units','pixels','Position',[17 10 200 22],...
                'String','Minimum valid sample size',...
                'HorizontalAlignment','right');
            
            obj.hMin=uicontrol(obj.ubg1,'Style','edit',...
                'Units','pixels','Position',[234 10 72 22],...
                'String',num2str(obj.minValid),...
                'callback',@callbackfun_minval, ...
                'ToolTipString','Number of events that must be selected for this to be a valid measurement');
                
            
            % deactivate one or the other input fields depending on what is allowed
            if ~default_is_ni
                obj.hRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.hNi.Enable='off';
                obj.hMaxRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            obj.ubg1.SelectionChangedFcn=@callback_selectioncontrol;
            
            if exist('ev','var') 
                if isfield(ev,'UseNumNearbyEvents') && ev.UseNumNearbyEvents
                    obj.ubg1.SelectedObject=obj.hUseNevents;
                else
                    obj.ubg1.SelectedObject=obj.hUseRadius;
                end
            end
            
            function callback_selectioncontrol(mysrc,~)
                if mysrc.SelectedObject == obj.hUseNevents
                    set([obj.hRa],'Enable','off');
                    set([obj.hNi, obj.hMaxRa],'Enable','on');
                else
                    set([obj.hNi, obj.hMaxRa],'Enable','off');
                    set([obj.hRa],'Enable','on');
                end
            end
            
            function callbackfun_ni(mysrc,~)
                obj.ni=str2double(mysrc.String);
            end

            function callbackfun_ra(mysrc,~)
                obj.ra=str2double(mysrc.String);
            end
            function callbackfun_maxra(mysrc,~)
                obj.max_ra=str2double(mysrc.String);
            end
            function callbackfun_minval(mysrc,~)
                obj.minValid = str2double(mysrc.String);
            end
        end
    end
    
    methods(Static)
        function [evsel, okPressed]=quickshow(writeToGlobal,ni,ra,min_valid)
            %QUICKSHOW will produce a simple ZmapDialog, writing
            % selcrit = evsel.quickshow() get parameters into the output
            % evsel.QUICKSHOW(true) writes results back to ZmapGlobal
            % QUICKSHOW(writeToGlobal,ni,ra,min_valid)
            % QUICKSHOW(writeToGlobal,evenSelectionStruct)
            
            f=figure('Name','EventSelectionChoice',...
                'Menubar','none',...
                'InnerPosition',position_in_current_monitor( EventSelectionChoice.GROUPWIDTH+5, EventSelectionChoice.GROUPHEIGHT+50),...
                'Numbertitle','off'...
                );
            t='esc'; lcp=[5 50]; 
            ZG=ZmapGlobal.Data;
            if nargin==2 && isstruct(ni)
                
                % ni is actually an eventselection-style struct
                esc=EventSelectionChoice(f,t,lcp,ni);
            elseif nargin<2 && ~isempty(ZG.GridSelector) && isstruct(ZG.GridSelector)
                
                % no struct or other options provided, but default exists, so use that
                esc=EventSelectionChoice(f,t,lcp, ZG.GridSelector);
            else
                
                if ~exist('ni','var')
                    ni=ZG.ni;
                end
                if ~exist('ra','var')
                    ra=ZG.ra;
                end
                if ~exist('min_valid','var')
                    min_valid=1;
                end
                esc=EventSelectionChoice(f,t,lcp,ni, ra, min_valid);
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
                assert(~isempty(evsel.NumNearbyEvents));
                ZG.ni=evsel.NumNearbyEvents;
                assert(~isempty(evsel.RadiusKm));
                ZG.ra=evsel.RadiusKm;
                ZG.GridSelector = evsel;
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
            if isfield(ev,'UseNumNearbyEvents') && ev.UseNumNearbyEvents
                tf = tf && (isfield(ev,'NumNearbyEvents') && ev.NumNearbyEvents > 0);
            end
            
            % if using events in radius, make sure the radius is specified
            if isfield(ev,'UseEventsInRadius') && ev.UseEventsInRadius
                tf = tf && (isfield(ev,'RadiusKm') && ev.RadiusKm >=0);
            end
            
            % make sure that in any case, either the number of events or the radius is specified
            tf = tf && (isfield(ev,'NumNearbyEvents') || isfield(ev,'RadiusKm'));
            
        end
        
        function mustBeEventSelector(ev)
            assert(EventSelectionChoice.isValidSelector(ev),'Value does not look like a valid Event Selector');
        end
    end

end