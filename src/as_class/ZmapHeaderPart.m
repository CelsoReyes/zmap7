classdef ZmapHeaderPart < ZmapDialogPart
    %ZmapHeaderPart base class for items in a popup menu
    %
    %
    % this inherits from matlab.mixin.Heterogenous to allow one to create an array of
    % ZmapDialogPart.
    properties
        text
        alignment
    end
    
    methods(Access=public)
        function obj=ZmapHeaderPart(text,alignment, tooltip)
            obj.text=text;
            if ~exist('alignment','var') || isempty('alignment')
                alignment='center';
            end
            assert(ismember(alignment,{'left','center','right'}));
            obj.alignment=alignment;
            
            if exist('tooltip','var')
                obj.tooltip=tooltip;
            end
        end
        
        function obj=draw(obj,fig, minx, miny)
            
            obj.h=uicontrol('parent',fig,'Style','text',...
                'String',[obj.text, ' : '],...
                'FontWeight','bold',...
                'HorizontalAlignment',obj.alignment,...
                'Position',[minx miny obj.width, obj.height]);
            obj.height=obj.h.Extent(4);
        end
        
        function v=Value(obj)
            v=[];
        end
    end
end