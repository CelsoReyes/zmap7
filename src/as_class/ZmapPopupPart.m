classdef ZmapPopupPart < ZmapDialogPart
    %ZMAPPOPUPPART base class for items in a popup menu
    %
    %
    % this inherits from matlab.mixin.Heterogenous to allow one to create an array of
    % ZmapDialogPart.
    properties
        choices
        defaultchoice
        label
        hlabel % handle for the label
    end
    
    methods(Access=public)
        function obj=ZmapPopupPart(tag, label, choices, default, tooltip)
            
            %AddPopup represents a pop-up menu
            % AddPopup(obj,tag, label, choices, defaultChoice,tooltip)
            obj.tag=tag;
            obj.label=label;
            obj.choices=choices;
            obj.defaultchoice=default;
            obj.tooltip=tooltip;
        end
        
        function obj=draw(obj,fig, minx, miny, label2fieldratio)
            % DRAW
            % obj=draw(obj,fig, minx, miny)
            % obj=draw(obj,fig, minx, miny, label2fieldratio)
            assert(nargout>0);
            
            if ~exist('label2fieldratio','var')
                label2fieldratio=1/3;
            end
            labelwidth=ceil(obj.width * label2fieldratio);
            popx = labelwidth + minx + 20;
            popwidth=floor( obj.width * (1-label2fieldratio) ) - 20;
            
            obj.hlabel=uicontrol('parent',fig,'Style','text',...
                'String',[obj.label, ' : '],...
                'HorizontalAlignment','right',...
                'Position',[minx miny labelwidth obj.height]);
            obj.height=ceil(obj.hlabel.Extent(4)*1.6);
            obj.hlabel.Position(4)=obj.height;
            obj.h=uicontrol('parent',fig,'Style','popupmenu',...
                'Value',obj.defaultchoice,...
                'String',obj.choices,...
                'Tag',obj.tag,...
                'ToolTipString',obj.tooltip,...
                'Position',[popx miny popwidth obj.height]);
            
        end
        
        function enable(obj)
            set([obj.h obj.hlabel],'Enable','on');
        end
        function disable(obj)
            set([obj.h obj.hlabel],'Enable','off');
        end
        
        function [text,n]=Value(obj)
            % VALUE
            % [popupText, positionInPopup]=Value(obj)
            try
                n=obj.h.Value;
            catch
                warning('either prematurely deleted object, or never drawn')
                n=obj.defaultchoice;
            end
            text=obj.choices{n};
        end
    end
end