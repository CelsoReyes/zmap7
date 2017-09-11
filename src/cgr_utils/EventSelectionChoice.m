classdef EventSelectionChoice < handle
    % GridParameterChoice adds control to figure that describes how to choose a grid.
    %
    % Example usage:
    %
    
    properties
        ni % number of nearby events to consider
        ra % radius in km
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
        
    end
    
    properties(Constant)
        GROUPWIDTH=315
        GROUPHEIGHT=77;
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
        end
        
        function obj=EventSelectionChoice(fig,tag, lowerCornerPosition, ni,ra)
            % choose_grid adds controls to describe how to choose a grid.
            
            % Grid options
            
            % Create, Load, or use Previous grid choice
            obj.ni=ni;
            obj.ra=ra;
            
            if isempty(lowerCornerPosition)
                X0 = 22;
                Y0 = 144;
            else
                X0 = lowerCornerPosition(1);
                Y0 = lowerCornerPosition(2);
            end
            
            enable_ra = ~isempty(ra);
            enable_ni = ~isempty(ni);
            obj.ubg1=uibuttongroup(fig,'Title','Event Selection',...
                'Units','pixels','Position',[X0 Y0 315 77], 'Tag',tag);
            
            obj.hUseNevents = uicontrol(obj.ubg1,'Style','radiobutton',...
                'Units','pixels','Position',[17 38 280 22],...
                'String','Number of Nearest Events',...
                'Enable',logical2OnOff(enable_ni));
            
            obj.hUseRadius =  uicontrol(obj.ubg1,'Style','radiobutton',...
                'Units','pixels','Position',[17 7 280 22],...
                'String','Events within Constant Radius (km)',...
                'Enable',logical2OnOff(enable_ra));
            
            obj.hNi=uicontrol(obj.ubg1,'Style','edit',...
                'Units','pixels','Position',[234 38 72 22],...
                'String',num2str(ni),'callback',@callbackfun_ni, 'ToolTipString','# closest events to include');
            obj.hRa=uicontrol(obj.ubg1,'Style','edit',...
                'Units','pixels','Position',[234 7 72 22],...
                'String',num2str(ra),'callback',@callbackfun_ra, 'ToolTipString','event selection radius');
                
            % deactivate one or the other input fields depending on what is allowed
            if enable_ni
                obj.hRa.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseNevents;
            else
                obj.hNi.Enable='off';
                obj.ubg1.SelectedObject=obj.hUseRadius;
            end
            obj.ubg1.SelectionChangedFcn=@callback_selectioncontrol;
            
            
            function callback_selectioncontrol(mysrc,~)
                if mysrc.SelectedObject == obj.hUseNevents
                    set([obj.hRa],'Enable','off');
                    set([obj.hNi],'Enable','on');
                else
                    set([obj.hNi],'Enable','off');
                    set([obj.hRa],'Enable','on');
                end
            end
            
            function callbackfun_ni(mysrc,~)
                obj.ni=str2double(mysrc.String);
            end

            function callbackfun_ra(mysrc,~)
                obj.ra=str2double(mysrc.String);
            end
        end
    end
end

function out=isempty2OnOff(val)
    % returns 'off' for empty values and 'on' otherwise
    if isempty(val)
        out= 'off';
    else
        out= 'on';
    end
end
function out = logical2OnOff(val)
    if val
        out = 'on';
    else
        out = 'off';
    end
end