classdef ZmapRadioPart < ZmapDialogPart
    %ZmapRadioPart base class for items in a popup menu
    %
    %
    % this inherits from matlab.mixin.Heterogenous to allow one to create an array of
    % ZmapDialogPart.
    properties
        choices
        choicetips
        choicetags
        defaultchoice
        groupTitle
    end
    
    methods(Access=public)
        function obj=ZmapRadioPart(groupTag, groupTitle,choiceTags, choices, defaultchoice, tooltips)
            %ZMAPRADIOPART group of radio buttons
            % obj=ZmapRadioPart(groupTag, groupTitle,choiceTags, choices, defaultchoice, tooltips)
            % obj.Value % returns the TAG associated with the chosen radio button
            
            assert(numel(choices)==numel(choiceTags))
            assert(~exist('tooltips','var') || numel(tooltips)==numel(choices));
            assert(defaultchoice<=numel(choices) && defaultchoice>0);
            
            obj.tag=groupTag;
            obj.groupTitle=groupTitle;
            obj.choicetags=choiceTags;
            obj.choices=choices;
            obj.defaultchoice=defaultchoice;
            obj.choicetips=tooltips;
        end
        
        function obj = draw(obj,fig, minx, miny)
            % drawing will set obj.h and obj.height;
            assert(nargout>0);
            padding=6;
            totalheight=padding;
            
            % create the button group
            obj.h = uibuttongroup(fig,'Units','pixels',...
                'visible','off',...
                'Title',obj.groupTitle,...
                'Tag',obj.tag);
            obj.h.Position(3)=obj.width;
            
            %draw radio buttons within the group
            for n = numel(obj.choices):-1:1
              htmp(n)=uicontrol('Parent',obj.h,'style','radiobutton',...
                  'String',obj.choices{n},'tag',obj.choicetags{n});
              
              htmp(n).Position(2)=totalheight;
              htmp(n).Position(3)=obj.width-10;
              
              if ~isempty(obj.choicetips)
                  htmp(n).TooltipString=obj.choicetips{n};
              end
              
              totalheight= totalheight + htmp(n).Position(4)+padding;
              
            end
            
            %resize the button group
            obj.h.Position=[minx, miny, obj.width, totalheight+(padding*1.2)];
            obj.h.SelectedObject=htmp(obj.defaultchoice);
            obj.h.Visible='on';
            obj.height=ceil(obj.h.Position(4));
        end
        
        function v=Value(obj)
            try
                v=obj.h.SelectedObject.Tag;
            catch
                warning('either prematurely deleted object, or never drawn')
                v=obj.defaultchoice;
            end
        end
        
        function enable(obj)
            set(obj.h.Children,'Enable','on');
        end
        
        function disable(obj)
            set(obj.h.Children,'Enable','off');
        end
    end
end