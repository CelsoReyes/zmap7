classdef EventSelectionChoice < handle
    % EventSelectionChoice widget allowing user to determine how samples are selected
    %
    % options this can control:
    %   1. Select all events within Radius R of a point?
    %       useEventsInRadius = true
    %       radius_km = [some value]
    %
    %   2. Select the closest N events to a point, up to a max radius?
    %       useNumNearbyEvents =  true
    %       numNearbyEvents = [some value]
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
        ni % number of nearby events to consider
        max_ra % maximum radius when sampling specific number of events
        ra % radius in km for RADIUS sampling
        minValid% minimum number of selected events to consider point measureable
        ubg1
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
            %  numNearbyEvents, radius_km, useNumNearbyEvents, useEventsInRadius
            out.numNearbyEvents=obj.ni;
            out.radius_km=obj.ra;
            out.useNumNearbyEvents=obj.UseNumNearbyEvents;
            out.useEventsInRadius=obj.UseEventsInRadius;
            if obj.UseNumNearbyEvents
                out.maxRadiusKm = obj.max_ra;
            else
                out.maxRadiusKm = obj.ra;
            end
            out.requiredNumEvents = obj.minValid;
        end
        
        function obj=EventSelectionChoice(fig,tag, lowerCornerPosition, ni,ra, min_valid)
            % choose_grid adds controls to describe how to choose a grid.
            % obj=EventSelectionChoice(fig,tag, lowerCornerPosition, ni,ra, min_valid)
            % Grid options
            
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
            if enable_ni
                obj.hRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.hNi.Enable='off';
                obj.hMaxRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            obj.ubg1.SelectionChangedFcn=@callback_selectioncontrol;
            
            
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
            %quickhow will produce a simple ZmapDialog, writing
            % selcrit = evsel.quickshow() get parameters into the output
            % evsel.quickshow(true) writes results back to ZmapGlobal
            f=figure('Name','EventSelectionChoice example',...
                'Menubar','none',...
                'InnerPosition',position_in_current_monitor( EventSelectionChoice.GROUPWIDTH+5, EventSelectionChoice.GROUPHEIGHT+50),...
                'Numbertitle','off'...
                );
            t='esc'; lcp=[5 50]; 
            if ~exist('ni','var')
                ZG=ZmapGlobal.Data;
                ni=ZG.ni; 
            end
            if ~exist('ra','var')
                ZG=ZmapGlobal.Data;
                ra=ZG.ra;
            end
            if ~exist('min_valid','var')
                min_valid=1;
            end
            esc=EventSelectionChoice(f,t,lcp,ni, ra, min_valid);
            evsel=esc.toStruct;
            inwidth=f.Position(3);
            uicontrol('style','pushbutton','string','OK','callback',@ok_cb,'Position',[inwidth-140 10 60 25]);
            
            uicontrol('style','pushbutton','string','Cancel','callback',@cancel_cb,'Position',[inwidth-70 10 60 25]);
            uiwait(f);
            if exist('writeToGlobal','var') && writeToGlobal
                ZG.ni=evsel.numNearbyEvents;
                ZG.ra=evsel.radius_km;
            end
            % TODO set another global saying which method to use?
            
            function ok_cb(src,~)
                evsel=esc.toStruct;
                okPressed=true;
                delete(f)
            end
            function cancel_cb(src,~)
                okPressed=false;
                delete(f);
            end
        end
        
    end

end